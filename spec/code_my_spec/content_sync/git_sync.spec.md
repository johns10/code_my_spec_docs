# CodeMySpec.ContentSync.GitSync

Handles Git repository operations for content sync. Clones project's docs_repo to temporary directory for sync operations. Each sync creates a fresh clone - no persistent caching or pull operations.

## Delegates

None.

## Functions

### clone_to_temp/1

Clones a project's content repository to a temporary directory.

```elixir
@spec clone_to_temp(Scope.t()) :: {:ok, path()} | {:error, error_reason()}
```

**Process**:
1. Guard clause returns `{:error, :project_not_found}` if scope has nil `active_project_id`
2. Fetch the project using `Projects.get_project/2` with scope and project ID
3. Validate that project has a non-nil, non-empty `docs_repo` URL (trimming whitespace)
4. Generate unique temporary directory path using timestamp and random bytes
5. Clone repository to temporary directory using `Git.clone/3`
6. Return `{:ok, temp_dir}` on success, or propagate any error from the pipeline

**Test Assertions**:
- successfully clones repository to temporary directory
- returns absolute path to temporary directory (starts with system tmp dir)
- trims whitespace from docs_repo URL
- returns error when scope has no active_project_id
- returns error when project does not exist
- returns error when active_project_id is nil
- returns error when project has no docs_repo configured
- returns error when project docs_repo is empty string
- returns error when project docs_repo is whitespace only
- returns error when git integration is not connected
- returns error for invalid URL format
- returns error for unsupported provider
- propagates git clone errors
- each clone creates unique temporary directory

## Dependencies

- CodeMySpec.Projects
- CodeMySpec.Git
- CodeMySpec.Users.Scope