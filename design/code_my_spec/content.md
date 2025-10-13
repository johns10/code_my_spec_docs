# Content Context

## Purpose

The Content Context manages published content for public and authenticated viewing. This is the production-ready content system that serves blog posts, pages, landing pages, and documentation to end users. Content is single-tenant (no account_id/project_id), and access control is based on authentication (scope vs nil) rather than multi-tenancy.

**Architectural Note**: Content is distinct from ContentAdmin:
- **ContentAdmin**: Multi-tenant validation/preview layer where developers test content synced from Git
- **Content**: Single-tenant published content layer where end users view finalized content

Content is NOT copied from ContentAdmin. Instead, publishing triggers a fresh Git pull, processes content, and POSTs to the Content endpoint.

## Entity Ownership

- Content entities (blog posts, pages, landing pages, documentation) with publishing lifecycle
- Tags and content-tag associations for organization
- SEO metadata and flexible JSONB metadata storage
- Content protection flags for authentication gates

## Scope Integration

**Scope is for authentication, NOT multi-tenancy**:

- **With %Scope{}**: User is authenticated → can access both public and protected content
- **With nil**: Anonymous visitor → can only access public content (protected = false)

NO account_id or project_id filtering. All queries are unscoped from a multi-tenant perspective.

## Public API

```elixir
# Content Retrieval (scope OR nil)
@spec list_published_content(Scope.t() | nil, content_type :: String.t()) :: [Content.t()]
@spec get_content_by_slug(Scope.t() | nil, slug :: String.t(), content_type :: String.t()) :: Content.t() | nil
@spec get_content_by_slug!(Scope.t() | nil, slug :: String.t(), content_type :: String.t()) :: Content.t()

# Content Sync (from publishing flow)
@spec sync_content(content_list :: [map()]) :: {:ok, [Content.t()]} | {:error, term()}
@spec delete_all_content() :: {:ok, count :: integer()}

# Tag Management
@spec list_all_tags() :: [Tag.t()]
@spec get_content_tags(Content.t()) :: [Tag.t()]
```

## State Management Strategy

### Database Persistence

- Content stored in `content` table WITHOUT account_id/project_id
- Schema fields: slug, title, content_type, content (rendered HTML/HEEx), protected, publish_at, expires_at, SEO fields, metadata (JSONB)
- Tags stored in `tags` table (no multi-tenancy)
- Content-tag associations in `content_tags` join table
- All bulk writes wrapped in transactions for consistency

### Protected Content Access

Content protection is based on authentication status:

- **protected = false**: Accessible to all visitors (scope can be nil)
- **protected = true**: Requires authentication (scope must be %Scope{})

LiveView layer checks content.protected:
- If protected = false: render content immediately
- If protected = true && scope present: render content
- If protected = true && scope nil: redirect to login or show paywall

### Publishing Flow

**Content is NOT copied from ContentAdmin.** Publishing works as follows:

1. **Developer validates in ContentAdmin**: Sync from Git to ContentAdmin for preview/validation
2. **Developer clicks "Publish"**: Triggers server-side action:
   - Fresh pull from GitHub repository
   - Process content files (markdown → HTML, parse frontmatter, etc.)
   - Generate tags from content
   - POST processed content to `/api/content/sync` endpoint
3. **Content Sync Endpoint**: Receives payload and:
   - Deletes all existing content (clean slate)
   - Creates new content records
   - Upserts tags
   - Creates content-tag associations
   - Returns success/failure

This ensures Content always reflects the GitHub source of truth, not ContentAdmin preview data.

## Components

### Content.Content

| field | value  |
| ----- | ------ |
| type  | schema |

Ecto schema with fields: slug, title, content_type, content (rendered), protected, publish_at, expires_at, SEO fields, metadata (JSONB). NO parse_status, parse_errors, account_id, or project_id.

### Content.Tag

| field | value  |
| ----- | ------ |
| type  | schema |

Ecto schema with fields: name, slug. NO account_id or project_id.

### Content.ContentTag

| field | value  |
| ----- | ------ |
| type  | schema |

Join table associating content_id with tag_id.

### Content.ContentRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

Query builder providing unscoped queries. Accepts Scope OR nil - Scope grants access to protected content, nil only returns public content. NO multi-tenant filtering.

### Content.TagRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

Query builder for tag operations without scoping.

## Dependencies

None - standalone context for public content serving.

## Execution Flow

### Content Retrieval for Viewing

1. **Check Scope**: Determine if user is authenticated (scope present) or anonymous (scope nil)
2. **Query Building**: Build query filtering by:
   - publish_at <= now OR publish_at IS NULL
   - expires_at > now OR expires_at IS NULL
   - content_type = requested type
   - slug = requested slug (for individual content)
   - protected = false (if scope is nil)
3. **Database Query**: Execute query with Repo
4. **Result Return**: Return content struct(s)
5. **LiveView Check**: Examine content.protected and redirect/render accordingly

### Publishing Content from Git

1. **Developer Action**: Click "Publish" in ContentAdmin UI
2. **Server Processing**:
   - Pull latest from GitHub repository
   - Parse content files (markdown, frontmatter)
   - Process markdown to HTML
   - Extract/generate tags
   - Build sync payload (list of content maps with all fields)
3. **POST to Sync Endpoint**: Send payload to `/api/content/sync`
4. **Sync Handler**:
   - Authenticate request
   - Begin transaction
   - Delete all existing content
   - Create content records
   - Upsert tags
   - Create content-tag associations
   - Commit transaction
5. **Return Result**: Success or error

### Tag-based Content Queries

1. **Find Tag**: Query tags table by slug
2. **Query Content**: Join through content_tags to find published content
3. **Apply Scope Filter**: If scope nil, filter to protected = false
4. **Return Results**: Return list of content structs
