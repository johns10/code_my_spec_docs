# ContentSync Context

## Purpose

Orchestrates the content sync pipeline from Git repository to database, coordinating metadata parsing from sidecar YAML files, content processing (markdown/HTML/HEEx), and atomic database transactions. Implements a 'delete all and recreate' strategy where flat files are the source of truth and broadcasts PubSub events on sync completion for real-time LiveView updates.

## Entity Ownership

This context owns no entities.

## Scope Integration

- All sync operations scoped to `account_id` and `project_id` from scope
- Synced content inherits scope foreign keys for multi-tenant isolation
- PubSub broadcasts scoped to account and project topics via existing Content context broadcasting
- File watcher configured from application config with scope from config
- Scope validates project access before sync operations

## Public API

```elixir
# Sync Operations
@spec sync_from_git(Scope.t()) :: {:ok, sync_result()} | {:error, term()}

# Sync Status
@spec list_content_errors(Scope.t()) :: [Content.t()]

# Type Definitions
@type sync_result :: %{
  total_files: integer(),
  successful: integer(),
  errors: integer(),
  duration_ms: integer(),
  content_types: %{blog: integer(), page: integer(), landing: integer()}
}
```

## Components

### ContentSync.MetaDataParser

| field | value |
| ----- | ----- |
| type  | other |

Parses sidecar `.yaml` files to extract structured metadata for content files. Returns success tuples with parsed metadata maps or error tuples with details when files are missing, contain invalid YAML syntax, or have malformed structure.

### ContentSync.ProcessorResult

| field | value |
| ----- | ----- |
| type  | other |

Shared result structure for all content processors. Contains `raw_content`, `processed_content`, `parse_status`, and `parse_errors` fields.

### ContentSync.MarkdownProcessor

| field | value |
| ----- | ----- |
| type  | other |

Converts markdown content to HTML using Earmark library. Populates `processed_content` field. Catches parsing errors and returns success tuples with embedded error details for `parse_errors` field.

### ContentSync.HtmlProcessor

| field | value |
| ----- | ----- |
| type  | other |

Validates HTML content structure and checks for disallowed JavaScript elements. Copies validated HTML to `processed_content` field. Returns success tuples with embedded validation errors for improper HTML.

### ContentSync.HeexProcessor

| field | value |
| ----- | ----- |
| type  | other |

Validates HEEx template syntax without rendering via `Phoenix.LiveView.HTMLEngine`. Stores raw HEEx in `raw_content` with `processed_content` set to nil (rendered at request time). Returns success tuples with embedded syntax errors for invalid templates.

### ContentSync.Sync

| field | value |
| ----- | ----- |
| type  | other |

Core sync orchestrator that processes a directory of content files. Discovers files, routes to appropriate processors and MetaDataParser, assembles content attributes, and performs atomic database operations via transaction.

### ContentSync.FileWatcher

| field | value     |
| ----- | --------- |
| type  | genserver |

GenServer using FileSystem library that monitors content directories configured in application config (development only). Gets scope from application config and triggers `Sync.sync_directory/2` on file events with timer-based debouncing. Started conditionally based on environment configuration.

### ContentSync.GitSync

| field | value |
| ----- | ----- |
| type  | other |

Handles Git repository operations for content sync. Clones project's `content_repo` to temporary directory using Briefly for automatic cleanup. Returns local directory path for sync operations.

## Dependencies

- Content (for `create_many/2`, `delete_all_content/1`, PubSub broadcasting)
- Projects (for retrieving `content_repo` field)
- Git (for `clone/3` with authenticated credentials)

## Execution Flow

### Git-Based Sync (Public API)

1. **Scope Validation**: Verify scope has access to target project
2. **Project Loading**: Load project via `Projects.get_project/2` to retrieve `content_repo` URL
3. **Temp Directory Creation**: Call `GitSync.clone_to_temp/1` which uses Briefly to create temp directory
4. **Git Clone**: GitSync delegates to `Git.clone/3` with authenticated credentials
5. **Sync Delegation**: Call `Sync.sync_directory(scope, temp_directory_path)`
6. **Automatic Cleanup**: Briefly cleans up temp directory when process exits
7. **Result Return**: Return sync_result from sync operation

### Sync Directory Pipeline (Internal)

1. **Directory Validation**: Verify directory exists and is readable
2. **Transaction Start**: Begin database transaction for atomic operation
3. **Content Deletion**: Delete all existing content via `Content.delete_all_content/1`
4. **File Discovery**: Scan directory (flat, non-recursive) for files (*.md, *.html, *.heex)
5. **File Processing Loop**: For each file:
   - Read file contents from filesystem
   - Parse metadata from sidecar `.yaml` file via MetaDataParser
   - Determine content type from file extension
   - Route to appropriate processor (MarkdownProcessor/HtmlProcessor/HeexProcessor)
   - Build content attributes merging metadata + processor result
6. **Batch Insert**: Insert all content via `Content.create_many/2` (includes errors)
7. **Transaction Commit**: Commit if successful, rollback on failure
8. **Completion Broadcast**: Publish `{:sync_completed, sync_result}` via Content context broadcasting
9. **Result Return**: Return sync_result with counts

### File Content Processing

1. **Metadata Loading**: MetaDataParser reads corresponding `.yaml` file (e.g., `post.md` → `post.yaml`)
2. **Content Reading**: Read raw content from file (markdown/HTML/HEEx source)
3. **Processor Routing**: Route to processor based on extension:
   - `.md` → MarkdownProcessor
   - `.html` → HtmlProcessor
   - `.heex` → HeexProcessor
4. **Processor Execution**: Processor returns `{:ok, ProcessorResult.t()}` with:
   - `raw_content`: original file contents
   - `processed_content`: converted HTML or nil
   - `parse_status`: `:success` or `:error`
   - `parse_errors`: error details map or nil
5. **Attribute Assembly**: Merge metadata + processor result into content attributes
6. **Error Handling**: If MetaDataParser returns `{:error, reason}`, wrap in ProcessorResult with `:error` status

### File Watcher Event Handling (Development Only)

1. **Initialization**: FileWatcher GenServer starts with scope from config
2. **File Event**: Receive `{:file_event, _pid, {path, events}}` message
3. **Timer Check**: Cancel existing debounce timer if present
4. **Timer Start**: Start new debounce timer via `Process.send_after/3` (1000ms)
5. **Debounce Complete**: On timer expiration, call `Sync.sync_directory(scope, watched_directory)`
6. **Result Logging**: Log sync result for developer visibility

## Access Patterns

- File watcher scope configured in config.exs with `account_id` and `project_id`
- Content directories specified in config.exs per environment
- All database operations filtered by scope's account_id and project_id
- Sync errors queried via `Content.list_content_with_status(scope, %{parse_status: "error"})`

## State Management Strategy

### Configuration-Based File Watching

Development configuration example:
```elixir
# config/dev.exs
config :code_my_spec,
  watch_content: true,
  content_watch_directory: "/Users/developer/my_project/content",
  content_watch_scope: %{
    account_id: "dev_account",
    project_id: "dev_project"
  }
```

- FileWatcher started only when `:watch_content` is true
- Development environment defaults to watching enabled
- Production disables file watching entirely
- Scope (account_id/project_id) configured per environment

### Transaction Atomicity

- All sync operations wrapped in Repo.transaction
- Delete-and-recreate ensures database matches filesystem exactly
- Rollback on transaction failure preserves previous content state
- Individual content errors don't abort transaction - stored in parse_errors

### Per-File Error Tracking

- Content's `parse_status` field tracks processing success/failure
- Content's `parse_errors` map field stores detailed error information
- Query errors via `Content.list_content_with_status(scope, %{parse_status: "error"})`
- No aggregate sync history stored - rely on content records themselves

### PubSub Integration

- Uses existing Content context broadcasting infrastructure
- Topic format: `"account:#{account_id}:project:#{project_id}:content"`
- Messages broadcast: `{:sync_completed, sync_result}`
- LiveView pages subscribe to content topic and react to sync events

### Git Repository Management

- Uses Briefly library for automatic temporary directory cleanup
- Each sync creates fresh temp directory via `Briefly.create(directory: true)`
- GitSync clones repository to temp directory using `Git.clone/3`
- Temp directory automatically cleaned up when process exits
- No persistent cloned repositories or caching
- Project's `content_repo` field stores Git repository URL