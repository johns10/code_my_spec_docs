# ContentSync Context

## Purpose

Orchestrates the content sync pipeline from Git repository to database, coordinating frontmatter parsing, content processing (markdown/HTML/EEx), and atomic database transactions. Implements a 'delete all and recreate' strategy where flat files are the source of truth and broadcasts PubSub events on sync completion for real-time LiveView updates.

## Entity Ownership

This context owns no entities.

## Scope Integration

- All sync operations scoped to `account_id` and `project_id` from scope
- Synced content inherits scope foreign keys for multi-tenant isolation
- PubSub broadcasts scoped to account and project topics
- File watcher configured from application config with scope determined at sync time
- Scope validates project access before sync operations

## Public API

```elixir
# Sync Operations
@spec sync_project_content(Scope.t(), opts :: keyword()) :: {:ok, sync_result()} | {:error, term()}
@spec sync_from_git(Scope.t()) :: {:ok, sync_result()} | {:error, term()}

# Sync Status
@spec list_content_errors(Scope.t()) :: [Content.t()]
```

## Components

### ContentSync.FrontmatterParser

| field | value |
| ----- | ----- |
| type  | other |

Uses YamlFrontMatter library to parse YAML frontmatter from content files. Extracts metadata (title, slug, type, publish_at, expires_at, SEO fields, tags) and returns structured map for content creation.

### ContentSync.MarkdownProcessor

| field | value |
| ----- | ----- |
| type  | other |

Converts markdown content to HTML using configured markdown library. Populates `processed_content` field. Catches parsing errors and returns error tuples with details for `parse_errors` field.

### ContentSync.HtmlProcessor

| field | value |
| ----- | ----- |
| type  | other |

Validates and sanitizes HTML content for XSS prevention. Copies validated HTML to `processed_content` field. Returns validation errors for improper HTML with details for `parse_errors` field.

### ContentSync.EexProcessor

| field | value |
| ----- | ----- |
| type  | other |

Validates EEx template syntax without rendering via `EEx.compile_string/1`. Stores raw EEx in `raw_content` and moves it to `processed_content` after it passes checks. Returns syntax errors for invalid templates with details for `parse_errors` field.

### ContentSync.FileWatcher

| field | value     |
| ----- | --------- |
| type  | genserver |

GenServer using FileSystem library that monitors content directories configured in application config (development only). Retrieves scope from user preferences and triggers `sync_project_content/2` on file events. Started conditionally based on Mix.env().

### ContentSync.GitSync

| field | value |
| ----- | ----- |
| type  | other |

Handles Git repository operations for content sync. Clones project's `content_repo` to temporary directory or pulls latest changes if already cloned. Returns local directory path for sync operations. Manages cleanup of cloned repositories.

## Dependencies

- Content
- Projects

## Execution Flow

### Full Content Sync Pipeline

1. **Scope Validation**: Verify scope has access to target project and account
2. **Sync Start Broadcast**: Publish `{:sync_started, project_id}` via Broadcaster
3. **Transaction Start**: Begin database transaction for atomic operation
4. **Content Deletion**: Delete all existing content via `Content.delete_all_content/1`
5. **File Discovery**: Scan configured content directories for files (*.md, *.html, *.eex)
6. **File Processing Loop**: For each file:
   - Read file contents from filesystem
   - Parse frontmatter via FrontmatterParser
   - Determine content type from file extension
   - Route to appropriate processor (MarkdownProcessor/HtmlProcessor/EexProcessor)
   - Build content attributes with `parse_status` and `parse_errors`
7. **Batch Insert**: Insert all content via `Content.create_many/2` (includes errors)
8. **Project Update**: Update project's `last_synced_at` timestamp
9. **Transaction Commit**: Commit if successful, rollback on failure
10. **Completion Broadcast**: Publish `{:sync_completed, sync_result}`
11. **Result Return**: Return sync_result with counts

### File Watcher Initialization (Development Only)

1. **Environment Check**: Verify Mix.env() == :dev
2. **Config Loading**: Read watched directories from application config
3. **FileSystem Start**: Start FileSystem backend with directory paths
4. **Event Subscription**: Subscribe to :file_event messages
5. **Supervisor Integration**: Add to supervision tree for automatic restart

### Markdown Content Processing

1. **Frontmatter Extraction**: FrontmatterParser splits YAML frontmatter from content
2. **Markdown Parsing**: MarkdownProcessor converts markdown to HTML
3. **Error Handling**: Catch exceptions, populate `parse_errors` map
4. **Attribute Building**: Construct map with:
   - slug, content_type (:blog/:page/:landing), raw_content
   - processed_content (HTML or nil on error)
   - SEO fields, timestamps from frontmatter
   - parse_status (:success or :error)
   - parse_errors (error details if failed)
5. **Return Result**: Always return `{:ok, attrs}` (errors captured in attrs)

### EEx Template Processing

1. **Frontmatter Extraction**: FrontmatterParser splits YAML from template
2. **Syntax Validation**: EexProcessor validates via `EEx.compile_string/1`
3. **Error Detection**: Catch compilation errors for syntax issues
4. **Attribute Building**: Construct map with:
   - slug, content_type, raw_content (EEx source)
   - processed_content = nil (rendered at request time)
   - frontmatter metadata
   - parse_status (:success or :error)
   - parse_errors (syntax error details if failed)
5. **Return Result**: Always return `{:ok, attrs}` (errors captured in attrs)

### Git-Based Sync (Production)

1. **Scope Validation**: Verify scope has access to target project
2. **Project Loading**: Load project to retrieve `content_repo` URL
3. **Repository Check**: Check if repo already cloned in temp directory
4. **Clone or Pull**:
   - If not cloned: `git clone project.content_repo /tmp/content_sync/project_id`
   - If cloned: `git pull` in existing directory
5. **Sync Delegation**: Call `sync_project_content(scope, directory: cloned_path)`
6. **Result Return**: Return sync_result from sync operation

## Access Patterns

- File watcher scope determined from user preferences' active project
- Content directories specified in config.exs per environment
- All database operations filtered by scope's account_id and project_id
- Sync errors queried via existing Content context using `parse_status: :error` filter

## State Management Strategy

### Configuration-Based File Watching

- Content directories configured in config.exs: `config :code_my_spec, :content_dirs, ["content/posts", "content/pages", "content/landing"]`
- FileWatcher started only when `config :code_my_spec, :watch_content` is true
- Development environment defaults to watching enabled
- Production disables file watching entirely

### Transaction Atomicity

- All sync operations wrapped in Repo.transaction
- Delete-and-recreate ensures database matches filesystem exactly
- Rollback on transaction failure preserves previous content state
- Individual content errors don't abort transaction - stored in parse_errors

### Sync History

- Project schema has `last_synced_at` timestamp field
- Updated on successful sync completion within transaction
- Content's `parse_status` and `parse_errors` provide per-file error details
- Query Content context for error content via `list_content_with_status(scope, %{parse_status: "error"})`

### PubSub Integration

- LiveView pages subscribe to content sync topics on mount
- Broadcasts trigger automatic content reload without manual refresh
- Messages: `{:sync_started, project_id}` and `{:sync_completed, sync_result}`
- Scoped to `"account:#{account_id}:project:#{project_id}:content_sync"`

### Git Repository Management

- Cloned repositories stored in `/tmp/content_sync/:project_id` or configured cache directory
- GitSync module uses System.cmd/3 to execute git commands
- Repositories persist across syncs to enable fast pulls
- Optional cleanup job can remove old cloned repositories
- Project's `content_repo` field stores Git repository URL