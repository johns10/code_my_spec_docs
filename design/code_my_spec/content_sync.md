# ContentSync Context

## Purpose

Orchestrates content sync pipelines in two different contexts:

1. **Server-Side (CodeMySpec SaaS)**: Syncs from Git → ContentAdmin for validation only. Shows parse status to developers.
2. **Client-Side (Client Appliances)**: Syncs from Git → Content with full schema. Triggered by server push.

Both use the same parsing/processing logic but write to different schemas. Git repository is always the source of truth.

## Entity Ownership

This context owns no entities.

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
@spec sync_to_content(repo_url :: String.t()) :: {:ok, sync_result()} | {:error, term()}

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

### ContentSync.FrontmatterParser

| field | value |
| ----- | ----- |
| type  | other |

Parses frontmatter from markdown files (YAML between `---` delimiters). Extracts metadata like title, slug, tags, publish_at, SEO fields, etc. Returns parsed metadata map or error with details.

### ContentSync.ProcessorResult

| field | value |
| ----- | ----- |
| type  | other |

Shared result structure for all content processors. Contains `content` (raw), `processed_content` (HTML/HEEx), `parse_status` (:success/:error), and `parse_errors` (error details map).

### ContentSync.MarkdownProcessor

| field | value |
| ----- | ----- |
| type  | other |

Converts markdown content to HTML using Earmark library. Populates `processed_content` field. Catches parsing errors and returns success tuples with embedded error details for `parse_errors` field.

### ContentSync.HtmlProcessor

| field | value |
| ----- | ----- |
| type  | other |

Validates HTML content structure. Copies validated HTML to `processed_content` field. Returns success tuples with embedded validation errors for improper HTML.

### ContentSync.HeexProcessor

| field | value |
| ----- | ----- |
| type  | other |

Validates HEEx template syntax without rendering via `Phoenix.LiveView.HTMLEngine`. Stores raw HEEx in `content` with `processed_content` set to nil (rendered at request time). Returns success tuples with embedded syntax errors for invalid templates.

### ContentSync.Sync

| field | value |
| ----- | ----- |
| type  | other |

Core sync orchestrator that processes a directory of content files. Discovers files, parses frontmatter, routes to appropriate processors, validates using Content.changeset, and performs atomic database operations via transaction. Works with both ContentAdmin (server) and Content (client) schemas.

### ContentSync.GitClone

| field | value |
| ----- | ----- |
| type  | other |

Handles Git repository cloning. Uses Briefly for automatic temp directory cleanup. Returns local directory path for sync operations.

### ContentSync.ClientPusher

| field | value |
| ----- | ----- |
| type  | other |

Handles pushing content from server to client appliances. Clones Git repo, parses all content with full schema, builds payload, and POSTs to client's `/api/content/sync` endpoint with authentication.

## Dependencies

**Server-Side**:
- ContentAdmin (for `create_many/2`, `delete_all_content/1`)
- Content (for changeset validation only)
- Projects (for retrieving `content_repo` field)
- Git (for `clone/3` with authenticated credentials)

**Client-Side**:
- Content (for `sync_content_from_server/1` - creates Content records with tags)
- Git (for `clone/3` if client has independent sync capability)

## Execution Flow

### Server-Side: Sync to ContentAdmin (Validation)

*Called when admin clicks "Sync from Git" in UI*

1. **Scope Validation**: Verify scope has access to target project
2. **Load Project**: Load project via `Projects.get_project/2` to retrieve `content_repo` URL
3. **Clone Git Repo**: GitClone creates temp dir and clones repo
4. **Discover Files**: Scan `content/` directory for *.md, *.html, *.heex files
5. **Transaction Start**: Begin database transaction
6. **Delete All ContentAdmin**: Remove existing records for scope
7. **Parse and Validate Each File**:
   - Parse frontmatter (title, slug, tags, SEO, etc.)
   - Route to processor based on extension (Markdown/Html/Heex)
   - Get processor result (content, processed_content, parse_status, parse_errors)
   - **Validate using Content.changeset** (reuse Content validation rules)
   - If changeset invalid → set parse_status: :error, parse_errors: changeset errors
   - Build ContentAdmin attrs: %{content, processed_content, parse_status, parse_errors, metadata: frontmatter}
8. **Batch Insert**: Insert all ContentAdmin via `ContentAdmin.create_many/2`
9. **Transaction Commit**: Commit atomically
10. **Broadcast**: Notify admin UI of sync completion
11. **Cleanup**: Briefly removes temp directory
12. **Return Result**: Return sync_result with counts

### Server-Side: Push to Client

*Called when admin clicks "Push to Client" button*

1. **Verify No Errors**: Check ContentAdmin.count_by_parse_status - must have 0 errors
2. **Load Project Config**: Get client_api_url and deploy_key from project settings
3. **Clone Git Repo**: Fresh clone to temp directory (Git is source of truth)
4. **Discover Files**: Scan `content/` directory
5. **Parse All Files with Full Schema**:
   - Parse frontmatter (all fields: title, slug, tags, SEO, publish_at, etc.)
   - Route to processor for content rendering
   - Validate using Content.changeset
   - Build full Content payload (NOT ContentAdmin minimal schema)
   - Include tags array from frontmatter
6. **Build Push Payload**: Array of content maps ready for client
7. **Authenticate Request**: Sign request with deploy_key
8. **POST to Client**: Send to `client_api_url/api/content/sync`
9. **Handle Response**: Return success/error to admin
10. **Cleanup**: Briefly removes temp directory

### Client-Side: Receive Content from Server

*Triggered by POST to `/api/content/sync` from server*

1. **Authenticate Request**: Verify deploy_key in headers
2. **Parse Payload**: Extract content list from JSON
3. **Transaction Start**: Begin atomic sync
4. **Delete All Content and Tags**: Clean slate
5. **Process Each Content Item**:
   - Extract tags array from content
   - Upsert tags (create if not exists)
   - Create Content record with all fields
   - Create ContentTag associations
6. **Transaction Commit**: Commit atomically
7. **Return Success**: Return {:ok, stats}

## Architecture Notes

### Why Re-sync from Git on Push?

When pushing to client, we re-sync from Git (don't use ContentAdmin as source) because:
1. Git is the source of truth, not ContentAdmin
2. ContentAdmin might be stale (dev pushed to Git since last sync)
3. Client needs full Content schema with tags, which ContentAdmin doesn't store properly
4. Simpler than maintaining two parallel sync code paths

### Validation Reuse

Both ContentAdmin and Content use the same `Content.changeset/2` for validation:
- Server validates against Content rules, stores errors in ContentAdmin
- Push to client validates again before sending (ensures clean data)
- Client doesn't need validation (server already validated)

### Frontmatter Format

Example markdown file with frontmatter:
```markdown
---
title: My Blog Post
slug: my-blog-post
content_type: blog
tags: [elixir, phoenix, testing]
publish_at: 2025-01-15T10:00:00Z
protected: false
meta_title: My Blog Post - Best Practices
meta_description: Learn about testing in Phoenix
---

# Content starts here
This is the markdown content...
```

### Transaction Atomicity

- All sync operations wrapped in Repo.transaction
- Delete-and-recreate ensures database matches Git exactly
- Rollback on failure preserves previous state
- Individual content errors don't abort transaction - stored in parse_errors

### Authentication

Client API endpoint requires deploy_key for authentication:
- Stored in project settings on server
- Configured in client application environment
- Sent in `Authorization` header: `Bearer <deploy_key>`
- Client verifies key before accepting sync