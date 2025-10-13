# ContentRepository

## Purpose

Provides data access functions for Content entities (published content). Handles content retrieval with optional scope filtering - passing a Scope allows access to protected content for authenticated users, while nil scope only returns public content. NO multi-tenant filtering by account_id/project_id.

**Note**: This repository is for published content access. ContentAdminRepository handles validation/preview with multi-tenant scoping.

## Public API

```elixir
# List Operations (scope OR nil)
@spec list_published_content(Scope.t() | nil, content_type :: String.t()) :: [Content.t()]

# Get Operations (scope OR nil)
@spec get_content_by_slug(Scope.t() | nil, slug :: String.t(), content_type :: String.t()) :: Content.t() | nil
@spec get_content_by_slug!(Scope.t() | nil, slug :: String.t(), content_type :: String.t()) :: Content.t()

# Preloading
@spec preload_tags(Content.t() | [Content.t()]) :: Content.t() | [Content.t()]
```

## Function Descriptions

### list_published_content/2

**With Scope**: Returns published content (publish_at <= now, expires_at > now or null) including both public AND protected content.

**With nil**: Returns ONLY public published content (protected = false).

Filters by content_type (blog, page, landing, documentation).

### get_content_by_slug/2 and get_content_by_slug!/2

**With Scope**: Fetches content by slug and content_type, returns both public and protected content if published.

**With nil**: Fetches ONLY public content (protected = false) by slug and content_type if published.

Bang version returns nil for nil scope (non-raising), raises Ecto.NoResultsError for Scope.

### preload_tags/1

Preloads the tags association for a single content struct or list of content structs. Use to avoid N+1 queries when displaying tags.

## Scope Behavior

**Key Distinction**: Scope is NOT for multi-tenancy (no account_id/project_id filtering). Scope is for authentication:

- **With %Scope{}**: User is authenticated → can access protected content
- **With nil**: Anonymous visitor → can only access public content (protected = false)

All queries filter by:
- publish_at <= now OR publish_at IS NULL
- expires_at > now OR expires_at IS NULL
- content_type = requested type
- protected = false (if scope is nil)

## Error Handling

- **Ecto.NoResultsError** - Raised by bang functions when scope is provided and content not found
- **nil** - Returned by non-bang and bang functions when scope is nil and content not found
- **Database errors** - Connection or constraint violations propagated from Repo layer
