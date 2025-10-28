# ContentSync Context

## Purpose

Orchestrates content sync pipelines in two different contexts:

1. **Server-Side (CodeMySpec SaaS)**: Syncs from Git → ContentAdmin for validation and preview. Shows parse status to developers.
2. **Client-Side (Client Appliances)**: Syncs from Git → Content with full schema. Triggered by server push.

Both use the **agnostic Sync module** for file processing, but handle database operations differently. Git repository is always the source of truth.

## Entity Ownership

This context owns no entities. It provides orchestration services that consume:
- **ContentAdmin** entities (multi-tenant validation layer)
- **Content** entities (single-tenant production layer)

## Scope Integration

**Server-Side (CodeMySpec SaaS)**:
- Sync operations scoped to `account_id` and `project_id` from scope
- ContentAdmin records inherit scope foreign keys
- Scope validates project access before sync operations

**Client-Side (Client Appliances)**:
- NO scoping - client apps are single-tenant
- No Scope struct needed for sync operations

## Public API

```elixir
# Server-Side API (syncs to ContentAdmin)
@spec sync_to_content_admin(Scope.t()) :: {:ok, sync_result()} | {:error, term()}
@spec list_content_admin_errors(Scope.t()) :: [ContentAdmin.t()]

# Client-Side API (syncs to Content with full schema)
@spec sync_to_content(repo_url :: String.t(), directory :: String.t()) :: {:ok, sync_result()} | {:error, term()}

# Shared - Push from Server to Client
@spec push_to_client(Scope.t(), client_api_url :: String.t(), deploy_key :: String.t()) ::
  {:ok, push_result()} | {:error, term()}

# Type Definitions
@type sync_result :: %{
  total_files: integer(),
  successful: integer(),
  errors: integer(),
  duration_ms: integer()
}

@type push_result :: %{
  synced_content_count: integer(),
  client_response: map()
}
```

## Components

### ContentSync.Sync

| field | value |
| ----- | ----- |
| type  | other |

**Agnostic file processing pipeline** that reads content files from filesystem and returns attribute maps. Does NOT handle database operations, multi-tenant scoping, transactions, or broadcasting. Returns generic maps that can be consumed by either ContentAdmin or Content changesets.

**Key Characteristics:**
- Pure data transformation layer
- No database dependencies
- No Scope parameter required
- Returns `{:ok, [%{slug: ..., content: ..., processed_content: ..., parse_status: ..., ...}]}`
- Callers handle all database operations

See `docs/design/code_my_spec/content_sync/sync.md` for detailed design.

### ContentSync.MetaDataParser

| field | value |
| ----- | ----- |
| type  | other |

Parses metadata from YAML sidecar files (e.g., `post.yaml` for `post.md`). Extracts metadata like title, slug, content_type, tags, publish_at, SEO fields, etc. Returns parsed metadata map or error with details.

**Note**: Uses sidecar files instead of frontmatter for cleaner separation of content and metadata.

### ContentSync.ProcessorResult

| field | value |
| ----- | ----- |
| type  | other |

Shared result structure for all content processors. Contains `raw_content`, `processed_content` (HTML or nil), `parse_status` (:success/:error), and `parse_errors` (error details map).

### ContentSync.MarkdownProcessor

| field | value |
| ----- | ----- |
| type  | other |

Converts markdown content to HTML using Earmark library. Populates `processed_content` field. Catches parsing errors and returns success tuples with embedded error details for `parse_errors` field.

### ContentSync.HtmlProcessor

| field | value |
| ----- | ----- |
| type  | other |

Validates HTML content structure and sanitizes disallowed elements (script tags, etc.). Copies validated HTML to `processed_content` field. Returns success tuples with embedded validation errors for improper HTML.

### ContentSync.HeexProcessor

| field | value |
| ----- | ----- |
| type  | other |

Validates HEEx template syntax without rendering via `Phoenix.LiveView.HTMLEngine`. Stores raw HEEx in `content` with `processed_content` set to nil (rendered at request time). Returns success tuples with embedded syntax errors for invalid templates.

### ContentSync.FileWatcher

| field | value |
| ----- | ----- |
| type  | other |

GenServer that monitors local content directories for file changes during development. Watches configured filesystem paths and triggers ContentAdmin sync operations when files are modified. Provides immediate validation feedback without manual sync button clicking. Started conditionally based on environment configuration (development only).

See `docs/design/code_my_spec/content_sync/file_watcher.md` for detailed design.

## Dependencies

**Server-Side**:
- ContentAdmin (for `create_many/2`, `delete_all_content/1`)
- Projects (for retrieving `content_repo` field)
- Git (for `clone/3` with authenticated credentials)
- Sync (agnostic file processor)

**Client-Side**:
- Content (for creating Content records with tags)
- Git (for `clone/3` if client has independent sync capability)
- Sync (agnostic file processor)

## Execution Flow

### Server-Side: Sync to ContentAdmin (Validation)

*Called when admin clicks "Sync from Git" in UI, or automatically via FileWatcher in development*

1. **Scope Validation**: Verify scope has access to target project
2. **Load Project**: Load project via `Projects.get_project/2` to retrieve `content_repo` URL
3. **Clone Git Repo**: Create temp dir and clone repo to local filesystem
4. **Process Directory**: Call `Sync.process_directory(content_dir)` to get attribute maps
5. **Transaction Start**: Begin database transaction
6. **Delete All ContentAdmin**: Remove existing records for this project via `ContentAdmin.delete_all_content(scope)`
7. **Add Multi-Tenant Scoping**: Merge `account_id` and `project_id` into each attribute map
8. **Batch Insert**: Insert all ContentAdmin records via `ContentAdmin.create_many(scope, attrs_list)`
9. **Transaction Commit**: Commit atomically
10. **Calculate Statistics**: Count total, successful, errors from `parse_status` field
11. **Broadcast**: Notify admin UI via PubSub on topic `account:{account_id}:project:{project_id}:content_admin`
12. **Cleanup**: Briefly removes temp directory
13. **Return Result**: Return `sync_result` with counts and duration

**Key Implementation Detail**: ContentAdmin records include `parse_status` and `parse_errors` fields for developer feedback. Errors don't block sync - they're stored in the database for visibility.

### Server-Side: Push to Client

*Called when admin clicks "Push to Client" button*

1. **Verify No Errors**: Check `ContentAdmin.count_by_parse_status(scope)` - must have 0 errors
2. **Load Project Config**: Get `client_api_url` and `deploy_key` from project settings
3. **Clone Git Repo**: Fresh clone to temp directory (Git is source of truth, not ContentAdmin)
4. **Process Directory**: Call `Sync.process_directory(content_dir)` to get attribute maps
5. **Filter Valid Content**: Only include items with `parse_status: :success`
6. **Map to Content Fields**: Filter attribute maps to only Content schema fields (no `parse_status`/`parse_errors`)
7. **Build Push Payload**: Array of content maps ready for client
8. **Authenticate Request**: Sign request with `deploy_key`
9. **POST to Client**: Send to `client_api_url/api/content/sync`
10. **Handle Response**: Return success/error to admin
11. **Cleanup**: Briefly removes temp directory

**Key Implementation Detail**: We re-sync from Git (not ContentAdmin) because Git is source of truth. ContentAdmin might be stale, and we need full Content schema fields (not just validation fields).

### Client-Side: Receive Content from Server

*Triggered by POST to `/api/content/sync` from server*

1. **Authenticate Request**: Verify `deploy_key` in Authorization header
2. **Parse Payload**: Extract content list from JSON
3. **Transaction Start**: Begin atomic sync
4. **Delete All Content**: Clean slate via `Content.delete_all_content()`
5. **Process Each Content Item**:
   - Extract tags array from content metadata
   - Upsert tags (create if not exists)
   - Create Content record with all fields
   - Create ContentTag associations
6. **Transaction Commit**: Commit atomically
7. **Return Success**: Return `{:ok, stats}`

**Key Implementation Detail**: Client trusts server validation. No re-validation on client side since server already ensured content is valid.

### Development: FileWatcher Auto-Sync

*Automatically triggered when content files change during development*

1. **File Change Detection**: FileSystem library detects changes in watched directory
2. **Debounce**: Wait 1 second to batch rapid changes
3. **Process Directory**: Call `Sync.process_directory(watched_dir)` to get attribute maps
4. **Transaction Start**: Begin database transaction
5. **Delete All ContentAdmin**: Remove existing records for this project
6. **Add Multi-Tenant Scoping**: Merge `account_id` and `project_id` into each attribute map
7. **Batch Insert**: Insert all ContentAdmin records via `ContentAdmin.create_many(scope, attrs_list)`
8. **Transaction Commit**: Commit atomically
9. **Calculate Statistics**: Count total, successful, errors
10. **Broadcast**: Notify LiveView via PubSub
11. **Log Result**: Log sync statistics for developer visibility

**Key Implementation Detail**: FileWatcher only syncs to ContentAdmin (validation layer), never to Content (production layer). Publishing still requires explicit "Push to Client" action.

## Architecture Notes

### Agnostic Sync Design

The `Sync` module is intentionally agnostic and reusable:

**What Sync Does**:
- Reads files from filesystem
- Parses metadata (YAML sidecar files)
- Processes content (Markdown, HTML, HEEx)
- Returns generic attribute maps
- Tracks parse errors in returned data

**What Sync Does NOT Do**:
- Create database records
- Handle multi-tenant scoping (no account_id/project_id)
- Manage transactions
- Broadcast PubSub events
- Delete existing records
- Validate business rules

**Why Agnostic?**
- **Reusability**: Same file processing logic for both ContentAdmin and Content
- **Testability**: Easy to test without database (pure functions)
- **Flexibility**: Callers control database operations, transactions, broadcasting
- **Separation of Concerns**: Sync handles data transformation, callers handle persistence

### ContentAdmin vs Content

**ContentAdmin** (SaaS Validation Layer):
- Multi-tenant with `account_id` and `project_id` scoping
- Stores in `content_admin` table
- Includes `parse_status` and `parse_errors` fields
- Used for validation and preview in SaaS platform
- Developer sees parse errors immediately during development
- FileWatcher syncs here during local development
- "Sync from Git" button syncs here for preview

**Content** (Client Production Layer):
- Single-tenant, no account/project scoping
- Stores in `contents` table
- No `parse_status`/`parse_errors` fields (only valid content deployed)
- Used for serving published content to end users
- Only successfully parsed content gets published
- Receives content via HTTP POST from SaaS when developer clicks "Publish"

**Key Principle**: ContentAdmin is NEVER copied to Content. Publishing always pulls fresh from Git and processes through Sync.

### Why Re-sync from Git on Push?

When pushing to client, we re-sync from Git (don't use ContentAdmin as source) because:
1. **Git is source of truth**, not ContentAdmin
2. **ContentAdmin might be stale** (dev pushed to Git since last sync)
3. **Need full Content schema fields**, which ContentAdmin doesn't store (ContentAdmin only has validation-specific fields)
4. **Simpler architecture** than maintaining two parallel data flows

### Metadata Format

Uses **YAML sidecar files** instead of frontmatter:

```
content/
  my-post.md          # Markdown content
  my-post.yaml        # Metadata
  about.html          # HTML content
  about.yaml          # Metadata
  hero.heex           # HEEx template
  hero.yaml           # Metadata
```

Example metadata file (`my-post.yaml`):
```yaml
title: My Blog Post
slug: my-blog-post
type: blog
tags: [elixir, phoenix, testing]
publish_at: 2025-01-15T10:00:00Z
protected: false
meta_title: My Blog Post - Best Practices
meta_description: Learn about testing in Phoenix
```

**Why sidecar files?**
- Cleaner separation of content and metadata
- Easier to validate YAML independently
- Content files are pure content (no frontmatter delimiters)
- Allows non-markdown files (HTML, HEEx) to have metadata too

### Transaction Atomicity

- All sync operations wrapped in `Repo.transaction`
- Delete-and-recreate ensures database matches Git exactly
- Rollback on failure preserves previous state
- Individual content parse errors don't abort transaction - stored in `parse_status`/`parse_errors`

### Authentication

Client API endpoint requires `deploy_key` for authentication:
- Stored in project settings on server
- Configured in client application environment
- Sent in `Authorization` header: `Bearer <deploy_key>`
- Client verifies key before accepting sync

### Development Workflow

**Typical Development Flow**:
```
[Dev edits content locally]
    ↓
[FileWatcher detects change]
    ↓
[Auto-sync to ContentAdmin]
    ↓
[LiveView shows validation results]
    ↓
[Dev fixes any errors]
    ↓
[Dev clicks "Sync from Git" to refresh ContentAdmin]
    ↓
[Dev reviews content in preview]
    ↓
[Dev clicks "Push to Client"]
    ↓
[Server pulls fresh from Git]
    ↓
[Server POSTs to client API]
    ↓
[Client updates Content table]
    ↓
[End users see published content]
```

**No Automatic Publishing**: ContentAdmin changes do NOT automatically deploy to production. Publishing is an explicit action requiring:
1. ContentAdmin has 0 parse errors
2. Admin clicks "Push to Client" button
3. Server pulls fresh from Git (not ContentAdmin)
4. Server validates and POSTs to client