# ContentRepository

## Purpose

Provides data access functions for Content entities with proper scope filtering by account_id and project_id. Handles content retrieval filtered by publish_at, expires_at, parse_status, content_type, and protected flag while enforcing multi-tenant isolation.

## Public API

```elixir
# List Operations
@spec list_content(Scope.t()) :: [Content.t()]
@spec list_published_content(Scope.t(), content_type :: String.t()) :: [Content.t()]
@spec list_scheduled_content(Scope.t()) :: [Content.t()]
@spec list_expired_content(Scope.t()) :: [Content.t()]
@spec list_content_by_type(Scope.t(), content_type :: String.t()) :: [Content.t()]
@spec list_content_by_parse_status(Scope.t(), parse_status :: String.t()) :: [Content.t()]

# Get Operations
@spec get_content(Scope.t(), id :: integer()) :: Content.t() | nil
@spec get_content!(Scope.t(), id :: integer()) :: Content.t()
@spec get_content_by_slug(Scope.t(), slug :: String.t(), content_type :: String.t()) :: Content.t() | nil
@spec get_content_by_slug!(Scope.t(), slug :: String.t(), content_type :: String.t()) :: Content.t()

# Preloading
@spec preload_tags(Content.t() | [Content.t()]) :: Content.t() | [Content.t()]
```

## Function Descriptions

### list_content/1
Returns all content for the scope's account_id and project_id without filtering by publication status or parse status.

### list_published_content/2
Returns content currently published (publish_at <= now, expires_at > now or null) for the specified content_type with parse_status = "success".

### list_scheduled_content/1
Returns content scheduled for future publication where publish_at > current timestamp.

### list_expired_content/1
Returns content that has passed its expiration date where expires_at <= current timestamp.

### list_content_by_type/2
Returns all content for a specific content_type (blog, page, landing) regardless of publication or parse status.

### list_content_by_parse_status/2
Returns all content filtered by parse_status (success, error, pending). Useful for debugging sync issues.

### get_content/1 and get_content!/1
Fetches a single content record by id with scope filtering. Bang version raises Ecto.NoResultsError if not found.

### get_content_by_slug/2 and get_content_by_slug!/2
Fetches content by slug and content_type with scope filtering. Slug uniqueness is enforced per content_type. Bang version raises if not found.

### preload_tags/1
Preloads the tags association for a single content struct or list of content structs. Use to avoid N+1 queries when displaying tags.

## Error Handling

- **Ecto.NoResultsError** - Raised by bang functions when content not found
- **nil** - Returned by non-bang functions when content not found
- **Database errors** - Connection or constraint violations propagated from Repo layer
