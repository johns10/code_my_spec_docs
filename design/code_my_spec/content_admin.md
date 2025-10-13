# ContentAdmin Context

## Purpose

The ContentAdmin Context manages content validation and preview within the CodeMySpec SaaS platform. It provides a minimal sync target for Git content that shows parse status and errors to developers. This is a validation layer - when content is ready to publish, we re-sync from Git directly to the client application with full Content schema.

**Architectural Role**: ContentAdmin is for validation only. Developers sync from Git to see if their content parses correctly. When ready to publish, they click "Push to Client" which triggers a fresh sync from Git ’ Client (bypassing ContentAdmin).

## Entity Ownership

- ContentAdmin entities with minimal fields: content, processed_content, parse_status, parse_errors, metadata
- Parse validation results for developer feedback
- No tags, no SEO fields, no lifecycle fields - just validation state

## Scope Integration

- All queries filtered by `account_id` and `project_id` foreign keys for multi-tenant isolation
- Scope struct passed to all public functions to enforce account and project boundaries
- No public/unscoped access - you must have a Scope to access ContentAdmin

## Public API

```elixir
# ContentAdmin Queries
@spec list_all_content(Scope.t()) :: [ContentAdmin.t()]
@spec list_content_with_errors(Scope.t()) :: [ContentAdmin.t()]
@spec get_content!(Scope.t(), id :: integer()) :: ContentAdmin.t()

# ContentAdmin CRUD (mostly for sync operations)
@spec create_many(Scope.t(), content_list :: [map()]) :: {:ok, [ContentAdmin.t()]} | {:error, term()}
@spec delete_all_content(Scope.t()) :: {:ok, count :: integer()}

# Status Queries
@spec count_by_parse_status(Scope.t()) :: %{success: integer(), error: integer()}
```

## State Management Strategy

### Database Persistence
- ContentAdmin stored in `content_admin` table with account_id and project_id foreign keys
- All bulk writes wrapped in transactions for consistency
- Minimal schema - just what's needed for validation feedback

### ContentAdmin Schema Fields

```elixir
schema "content_admin" do
  # Raw and processed content
  field :content, :string              # Raw markdown/source
  field :processed_content, :string    # Rendered HTML/HEEx (for preview)

  # Validation state
  field :parse_status, Ecto.Enum, values: [:success, :error]
  field :parse_errors, :map            # JSONB for error details

  # Everything else (slug, title, type, etc.)
  field :metadata, :map                # JSONB - parsed frontmatter goes here

  # Multi-tenancy
  belongs_to :project, Project
  belongs_to :account, Account

  timestamps(type: :utc_datetime)
end
```

**Note**: `metadata` contains the parsed frontmatter (slug, title, content_type, tags, publish_at, protected, SEO fields, etc.) but we don't query by these fields in ContentAdmin. It's just for display in admin UI.

### Real-time Updates
- Broadcasts via PubSub when content sync completes
- LiveView subscribers in admin UI update validation status automatically

## Components

### ContentAdmin.ContentAdmin

| field | value  |
| ----- | ------ |
| type  | schema |

Minimal Ecto schema with: content, processed_content, parse_status, parse_errors, metadata, project_id, account_id.

### ContentAdmin.ContentAdminRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

Simple query builder for listing all content or filtering by parse_status. All queries enforce account_id and project_id scoping.

## Dependencies

- Projects
- Accounts
- Scopes

## Execution Flow

### Git Sync to ContentAdmin (Validation)
1. **Scope Validation**: Verify scope has access to target account and project
2. **Git Clone**: ContentSync clones project's content_repo to temp directory
3. **Content Discovery**: Find all markdown/content files in `content/` directory
4. **Transaction Start**: Begin database transaction
5. **Delete All**: Delete all existing ContentAdmin records for scope (clean slate)
6. **Parse and Validate**: For each file:
   - Parse frontmatter
   - Validate using Content.changeset (reuse existing validation logic)
   - Process markdown to HTML/HEEx
   - Set parse_status to :success or :error with parse_errors
   - Store parsed frontmatter in metadata JSONB
7. **ContentAdmin Insertion**: Insert minimal ContentAdmin records
8. **Transaction Commit**: Commit atomically
9. **Broadcast**: Notify LiveView of sync completion
10. **Result Return**: Return sync statistics

### View Validation Status in Admin UI
1. **Scope Validation**: Verify scope access
2. **Query All**: List all ContentAdmin for scope
3. **Display**: Show list with:
   - Title from metadata.title
   - Type from metadata.content_type
   - Parse status (success/error)
   - Error details if parse_status = :error
4. **Preview**: Show processed_content in preview pane

### Push to Client (Re-sync from Git)
*This is triggered by admin clicking "Push to Client" button*

1. **Verify No Errors**: Check that count_by_parse_status shows 0 errors
2. **Load Project Config**: Get client API endpoint and deploy key
3. **Clone Git Repo Again**: Fresh clone to temp directory
4. **Parse All Files**: Parse frontmatter and content (full Content schema this time)
5. **Build Payload**: Transform to client format with tags, SEO, all fields
6. **POST to Client**: Send to client's `/api/content/sync` endpoint
7. **Client Handles**: Client does delete_all + create_many with full Content schema
8. **Return Result**: Success or error

## Architecture Notes

### Why So Minimal?

ContentAdmin exists only to show developers "does my content parse?" They need:
- A list of their content files
- Success/error status for each
- Error messages to fix issues
- Preview of rendered content

They don't need to query by slug, filter by type, or manage tags in ContentAdmin. That all happens in the client application.

### Re-sync on Publish

When pushing to client, we re-sync from Git because:
1. Git is source of truth, not ContentAdmin
2. ContentAdmin might be stale (developer pushed to Git since last sync)
3. Client needs full schema with tags, which ContentAdmin doesn't store properly
4. Simpler than maintaining two parallel sync paths

### Validation Reuse

Use the existing `Content.changeset/2` for validation:
```elixir
# In ContentSync when parsing files
parsed_data = parse_frontmatter_and_content(file)

changeset = Content.changeset(%Content{}, parsed_data)

if changeset.valid? do
  create_content_admin(scope, %{
    content: parsed_data.content,
    processed_content: render_markdown(parsed_data.content),
    parse_status: :success,
    parse_errors: nil,
    metadata: parsed_data
  })
else
  create_content_admin(scope, %{
    content: parsed_data.content,
    processed_content: nil,
    parse_status: :error,
    parse_errors: format_changeset_errors(changeset),
    metadata: parsed_data
  })
end
```

This ensures ContentAdmin validation matches Content validation exactly.