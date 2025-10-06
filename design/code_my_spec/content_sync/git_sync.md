# GitSync

## Purpose

Handles Git repository operations for content synchronization. Clones a project's content repository to a temporary directory or pulls latest changes if already cloned. Manages repository lifecycle including directory path resolution, authentication delegation, and cleanup operations. Returns local directory paths for downstream sync operations.

## Public API

```elixir
# Repository Operations
@spec sync_repository(Scope.t()) :: {:ok, path()} | {:error, error_reason()}
@spec cleanup_repository(Scope.t()) :: :ok | {:error, error_reason()}
@spec repository_path(Scope.t()) :: {:ok, path()} | {:error, :not_cloned}

# Type Definitions
@type path :: String.t()
@type error_reason ::
  :project_not_found |
  :no_content_repo |
  :git_operation_failed |
  :directory_error |
  :not_connected |
  :unsupported_provider |
  term()
```

## Execution Flow

### Initial Clone Operation

1. **Scope Validation**: Verify scope has `active_project_id` set
2. **Project Loading**: Load project via `Projects.get_project/2` to retrieve `content_repo` URL
3. **Content Repo Check**: Verify project has non-nil `content_repo` field
4. **Path Resolution**: Determine target path using `repository_base_path/0` and project ID
5. **Directory Check**: Verify target directory does not already exist
6. **Parent Directory**: Ensure parent directory exists, create if needed
7. **Git Clone**: Delegate to `Git.clone/3` with scope, repo URL, and target path
8. **Path Return**: Return `{:ok, path}` with absolute path to cloned repository

### Pull Operation (Repository Exists)

1. **Scope Validation**: Verify scope has `active_project_id` set
2. **Project Loading**: Load project to get `content_repo` URL
3. **Path Resolution**: Determine repository path from base path and project ID
4. **Directory Verification**: Confirm directory exists and is a git repository
5. **Git Pull**: Delegate to `Git.pull/2` with scope and repository path
6. **Path Return**: Return `{:ok, path}` with absolute path to updated repository

### Repository Cleanup

1. **Scope Validation**: Verify scope has `active_project_id` set
2. **Path Resolution**: Determine repository path from base path and project ID
3. **Directory Check**: Verify directory exists before attempting removal
4. **Recursive Delete**: Remove repository directory and all contents via `File.rm_rf/1`
5. **Confirmation**: Return `:ok` on successful deletion

### Path Query

1. **Scope Validation**: Verify scope has `active_project_id` set
2. **Path Resolution**: Calculate expected repository path
3. **Existence Check**: Verify directory exists using `File.dir?/1`
4. **Path Return**: Return `{:ok, path}` if exists, `{:error, :not_cloned}` otherwise

## Implementation Notes

### Repository Storage Location

Repositories are stored in a consistent location based on environment configuration:

```elixir
# Default base path (can be overridden in config)
def repository_base_path do
  Application.get_env(:code_my_spec, :content_repo_base_path,
    Path.join(System.tmp_dir!(), "code_my_spec_content"))
end

# Per-project path structure
def repository_path(project_id) do
  Path.join(repository_base_path(), "project_#{project_id}")
end
```

**Path Structure:**
- Development: `/tmp/code_my_spec_content/project_123`
- Production: Configurable via `:content_repo_base_path` application env

### Authentication Delegation

GitSync does NOT handle authentication directly. It delegates all credential management to the `Git` context:

- `Git.clone/3` handles retrieving integration credentials via scope
- `Git.pull/2` manages temporary credential injection for pull operations
- GitSync remains authentication-agnostic, focusing solely on repository lifecycle

See `lib/code_my_spec/git.ex` and `lib/code_my_spec/git/cli.ex` for authentication implementation.

### Clone vs Pull Decision Logic

The `sync_repository/1` function determines whether to clone or pull:

```elixir
def sync_repository(%Scope{} = scope) do
  with {:ok, project} <- Projects.get_project(scope, scope.active_project_id),
       :ok <- validate_content_repo(project),
       {:ok, path} <- resolve_repository_path(scope) do
    if File.dir?(path) do
      pull_repository(scope, path)
    else
      clone_repository(scope, project.content_repo, path)
    end
  end
end
```

### Error Handling Strategy

GitSync uses error tuples exclusively for all operations:

- **Project errors**: `{:error, :project_not_found}` - when project lookup fails
- **Configuration errors**: `{:error, :no_content_repo}` - when project lacks content_repo URL
- **Git errors**: Propagated from Git context (`:not_connected`, `:unsupported_provider`, etc.)
- **Filesystem errors**: Wrapped as `{:error, :directory_error}` with details

All errors preserve context for upstream error logging and user feedback.

### Idempotent Operations

- **sync_repository/1**: Can be called repeatedly - pulls if exists, clones if not
- **cleanup_repository/1**: Returns `:ok` even if directory doesn't exist
- **repository_path/1**: Pure function, always safe to call

### Repository Lifecycle Management

**When to Clone:**
- First content sync for a project
- After cleanup operation
- When repository directory is missing

**When to Pull:**
- Subsequent sync operations
- Scheduled content updates
- Manual sync triggers from UI

**When to Cleanup:**
- Project deletion
- Content repo URL change (cleanup + re-clone)
- Scheduled cache cleanup jobs
- Manual admin operations

### Concurrent Access Considerations

GitSync is stateless but filesystem operations are not atomic:

- **Multiple processes syncing same project**: Git operations will queue at filesystem level
- **Concurrent clone attempts**: First succeeds, subsequent calls error with `:path_exists`
- **Pull during active sync**: Git will handle locking via `.git/index.lock`

For production with high concurrency, consider adding distributed locks around sync operations at the ContentSync orchestration level.

### Directory Permissions

Ensure the application has appropriate permissions:

- **Read/Write**: Repository base path must be writable by application user
- **Execute**: Required for git operations and directory traversal
- **Cleanup**: Sufficient permissions to remove repository directories

### Integration with ContentSync

GitSync is called by the ContentSync context:

```elixir
# In ContentSync
def sync_from_git(scope) do
  with {:ok, local_path} <- ContentSync.GitSync.sync_repository(scope),
       {:ok, sync_result} <- sync_project_content(scope, directory: local_path) do
    {:ok, sync_result}
  end
end
```

GitSync provides the local directory path, then ContentSync.FileScanner takes over to process files.