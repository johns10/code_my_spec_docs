# GitSync

## Purpose

Clones a project's docs repository to a temporary directory using Briefly for automatic cleanup. Returns the local directory path for downstream sync operations. Handles repository validation and delegates authentication to the Git context. Each sync creates a fresh clone - no persistent caching or pull operations.

## Public API

```elixir
# Repository Operations
@spec clone_to_temp(Scope.t()) :: {:ok, path()} | {:error, error_reason()}

# Type Definitions
@type path :: String.t()
@type error_reason ::
  :project_not_found |
  :no_docs_repo |
  :not_connected |
  :unsupported_provider |
  term()
```

## Execution Flow

### Clone to Temporary Directory

1. **Scope Validation**: Verify scope has `active_project_id` set
2. **Project Loading**: Load project via `Projects.get_project/2` to retrieve `docs_repo` URL
3. **Docs Repo Check**: Verify project has non-nil `docs_repo` field
4. **Temp Directory Creation**: Create temporary directory via `Briefly.create(directory: true)`
5. **Git Clone**: Delegate to `Git.clone/3` with scope, repo URL, and temp path
6. **Path Return**: Return `{:ok, path}` with absolute path to cloned repository

## Implementation Notes

### Briefly Integration

GitSync uses the Briefly library for automatic temporary directory management:

- Briefly creates unique temporary directories
- Directories are automatically cleaned up when the calling process exits
- No manual cleanup logic required
- No persistent storage or caching

**Example:**
```elixir
def clone_to_temp(%Scope{} = scope) do
  with {:ok, project} <- Projects.get_project(scope, scope.active_project_id),
       {:ok, docs_repo} <- validate_docs_repo(project),
       {:ok, temp_dir} <- Briefly.create(directory: true),
       {:ok, _path} <- Git.clone(scope, docs_repo, temp_dir) do
    {:ok, temp_dir}
  end
end
```

### Authentication Delegation

GitSync does NOT handle authentication directly. It delegates all credential management to the `Git` context:

- `Git.clone/3` retrieves integration credentials via scope
- `Git.clone/3` injects credentials into repository URL
- GitSync remains authentication-agnostic

See `lib/code_my_spec/git.ex` and `lib/code_my_spec/git/cli.ex` for authentication implementation.

### Error Handling Strategy

GitSync uses error tuples exclusively:

- **Project errors**: `{:error, :project_not_found}` - when project lookup fails
- **Configuration errors**: `{:error, :no_docs_repo}` - when project lacks docs_repo URL
- **Git errors**: Propagated from Git context (`:not_connected`, `:unsupported_provider`, etc.)
- **Temp directory errors**: Propagated from Briefly

All errors preserve context for upstream error logging and user feedback.

### Lifecycle Management

**Creation:**
- Briefly creates temp directory when `clone_to_temp/1` is called
- Directory exists for duration of calling process

**Cleanup:**
- Automatic when calling process exits (normal or crash)
- No manual cleanup required
- No orphaned directories

### Integration with ContentSync

GitSync is called by the ContentSync context for user-triggered syncs:

```elixir
# In ContentSync
def sync_from_git(scope) do
  with {:ok, temp_dir} <- ContentSync.GitSync.clone_to_temp(scope),
       {:ok, sync_result} <- ContentSync.Sync.sync_directory(scope, temp_dir) do
    {:ok, sync_result}
  end
  # Briefly automatically cleans up temp_dir when this process exits
end
```

### Performance Considerations

Every sync performs a full clone:
- No caching or pull optimization
- Suitable for infrequent user-triggered syncs
- Fresh state on every sync (no git state corruption)
- Higher bandwidth and time cost than pull-based approach

This tradeoff favors simplicity and correctness over performance for production syncs.

### Separation of Concerns

GitSync handles only git operations for production/user-triggered syncs. It does NOT:
- Handle file watching (FileWatcher does this)
- Process content files (Sync does this)
- Manage persistent repositories
- Cache or optimize repeated syncs

It's a simple helper that clones to temp and returns a path.
