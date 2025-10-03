# Content Context

## Purpose

The Content Context manages all content entities (blog posts, pages, landing pages), their lifecycle (scheduling, expiration), SEO metadata, and tag associations. It encapsulates content CRUD operations, tag management, and content-tag relationships while enforcing account and project-based multi-tenancy through scope filtering. Content protection is handled at the entity level via boolean flag, enabling flexible marketing gates and authentication requirements at the LiveView layer.

## Entity Ownership

- Content entities (blog posts, pages, landing pages) with full lifecycle management
- Tags and content-tag associations for content organization
- Content sync status and error tracking
- SEO metadata and flexible JSONB metadata storage
- Content protection and access control flags

## Scope Integration

- All queries filtered by `account_id` and `project_id` foreign keys for multi-tenant isolation
- Scope struct passed to all public functions to enforce account and project boundaries
- Content visibility controlled by scope + publish_at/expires_at timestamps
- Protected content accessible via same routes as public content - protection enforced at LiveView layer
- Tag creation and lookup scoped to account_id and project_id
- Content-tag associations respect boundaries through content relationship

## Public API

```elixir
# Content Queries
@spec list_published_content(Scope.t(), content_type :: String.t()) :: [Content.t()]
@spec list_scheduled_content(Scope.t()) :: [Content.t()]
@spec list_expired_content(Scope.t()) :: [Content.t()]
@spec list_all_content(Scope.t()) :: [Content.t()]
@spec get_content_by_slug!(Scope.t(), slug :: String.t(), content_type :: String.t()) :: Content.t()
@spec get_content!(Scope.t(), id :: integer()) :: Content.t()

# Content CRUD
@spec create_content(Scope.t(), attrs :: map()) :: {:ok, Content.t()} | {:error, Changeset.t()}
@spec create_many(Scope.t(), content_list :: [map()]) :: {:ok, [Content.t()]} | {:error, term()}
@spec update_content(Scope.t(), Content.t(), attrs :: map()) :: {:ok, Content.t()} | {:error, Changeset.t()}
@spec delete_content(Scope.t(), Content.t()) :: {:ok, Content.t()} | {:error, Changeset.t()}
@spec delete_all_content(Scope.t()) :: {:ok, count :: integer()}

# Bulk Operations
@spec purge_expired_content(Scope.t()) :: {:ok, count :: integer()}

# Tag Management
@spec list_tags(Scope.t()) :: [Tag.t()]
@spec upsert_tag(Scope.t(), name :: String.t()) :: {:ok, Tag.t()} | {:error, Changeset.t()}
@spec get_content_tags(Scope.t(), Content.t()) :: [Tag.t()]
@spec sync_content_tags(Scope.t(), Content.t(), tag_names :: [String.t()]) :: {:ok, Content.t()} | {:error, term()}

# Status Queries
@spec list_content_with_status(Scope.t(), filters :: map()) :: [Content.t()]
@spec count_by_sync_status(Scope.t()) :: %{success: integer(), error: integer()}
```

## State Management Strategy

### Database Persistence
- Content stored in `content` table with account_id and project_id foreign keys
- Tags stored in `tags` table with account_id and project_id foreign keys
- Content-tag associations in `content_tags` join table
- All bulk writes wrapped in transactions for consistency
- Static content cached in `processed_content` column
- Flexible metadata stored in JSONB `metadata` column

### Protected Content Access
- `protected` boolean field stored on content entity
- Context returns all published content regardless of protected flag
- LiveView layer enforces authentication checks based on `content.protected`
- Enables flexible marketing flows: content preview, soft gates, login redirects
- Same URL works for both anonymous (redirect/teaser) and authenticated (full access) users

### Real-time Updates
- Broadcasts via PubSub when content is created/updated/deleted
- LiveView subscribers update content listings automatically
- Expiration handled by query-time filtering, background job for cleanup

## Components

### Content.Content

| field | value  |
| ----- | ------ |
| type  | schema |

Ecto schema representing content entities with fields: slug, type, content_type, content, processed_content, protected (boolean), project_id, account_id, publish_at, expires_at, sync_status, sync_errors, SEO fields (meta_title, meta_description, og_image, og_title, og_description), and metadata (JSONB).

### Content.Tag

| field | value  |
| ----- | ------ |
| type  | schema |

Ecto schema representing tags with fields: name, slug, project_id, account_id. Normalized to lowercase slugified format for consistency.

### Content.ContentTag

| field | value  |
| ----- | ------ |
| type  | schema |

Join table schema associating content_id with tag_id for many-to-many relationships.

### Content.ContentRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

Query builder module providing scoped query functions for content filtering by publish_at, expires_at, sync_status, content_type, and protected flag. All queries enforce account_id and project_id scoping.

### Content.TagRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

Query builder module for tag upsert and lookup with account_id and project_id scoping. Handles tag normalization and conflict resolution on unique constraints.

### Content.ContentBroadcaster

| field | value |
| ----- | ----- |
| type  | other |

PubSub wrapper for broadcasting content change events to LiveView subscribers. Encapsulates topic naming and message formatting.

## Content.Dependencies

- Projects
- Scopes

## Execution Flow

### Bulk Content Creation
1. **Scope Validation**: Verify scope has access to target account and project
2. **Transaction Start**: Begin database transaction for atomic operation
3. **Content Insertion**: Insert content records with account_id and project_id from scope
4. **Transaction Commit**: Commit all changes atomically
5. **Broadcast**: Notify LiveView subscribers of content changes via ContentBroadcaster
6. **Result Return**: Return list of created content structs or error

### Content Retrieval for Display
1. **Scope Validation**: Verify scope has access to requested project
2. **Query Building**: Build query via ContentRepository filtering by:
   - account_id = scope.account_id
   - project_id = scope.project_id
   - sync_status = "success"
   - publish_at <= current_timestamp OR publish_at IS NULL
   - expires_at > current_timestamp OR expires_at IS NULL
   - type = requested content_type (blog/page/landing)
3. **Database Query**: Execute scoped query with Repo
4. **Result Return**: Return content struct with protected flag (or raise if not found)
5. **LiveView Protection Check**: LiveView examines content.protected:
   - If protected = false: render content immediately
   - If protected = true && user authenticated: render content
   - If protected = true && no user: redirect to login or show teaser/paywall

### Tag Synchronization
1. **Scope Validation**: Verify scope has access to content's project
2. **Tag Normalization**: Lowercase and slugify tag names
3. **Tag Upsert**: For each tag, upsert with account_id and project_id (on conflict do nothing)
4. **Association Sync**: Delete existing content_tags, insert new content_tags records
5. **Preload Update**: Reload content with preloaded tags
6. **Result Return**: Return updated content struct with tags

### Expired Content Cleanup
1. **Scope Validation**: Verify scope has access to project
2. **Query Building**: Find content where expires_at <= current_timestamp AND account_id = scope.account_id AND project_id = scope.project_id
3. **Deletion**: Delete content records and cascade to content_tags
4. **Broadcast**: Notify subscribers of content removal
5. **Result Return**: Return count of deleted records
