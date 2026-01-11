# ContentRepository

Provides data access functions for published Content entities. Handles content retrieval with optional scope filtering - passing a Scope allows access to protected content for authenticated users, while nil scope only returns public content. Does NOT apply multi-tenant filtering by account_id/project_id.

Note: This repository is for published content access only. ContentAdminRepository handles validation/preview with multi-tenant scoping.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Content.Content
- CodeMySpec.Users.Scope

## Functions

### list_published_content/2

Returns published content filtered by content_type with scope-aware visibility.

```elixir
@spec list_published_content(Scope.t() | nil, content_type()) :: [Content.t()]
```

**Process**:
1. Build base query filtered by content_type
2. Filter to published content where publish_at <= now (or nil)
3. Filter to non-expired content where expires_at > now (or nil)
4. If scope is provided, return both public and protected content
5. If scope is nil, additionally filter to only public content (protected = false)
6. Execute query and preload tags association

**Test Assertions**:
- returns only published content (excludes scheduled and expired)
- filters by content_type correctly
- includes content with publish_at in past and no expires_at
- includes content with expires_at in future
- with scope: includes both public and protected content
- with scope: returns content from all accounts/projects (no multi-tenant filtering)
- with nil scope: returns only public content (protected = false)
- with nil scope: excludes scheduled and expired content

### get_content_by_slug/3

Fetches a single content item by slug and content_type with scope-aware visibility.

```elixir
@spec get_content_by_slug(Scope.t() | nil, String.t(), content_type()) :: Content.t() | nil
```

**Process**:
1. Build query filtered by slug and content_type
2. Filter to published content where publish_at <= now (or nil)
3. Filter to non-expired content where expires_at > now (or nil)
4. If scope is provided, return content regardless of protected status
5. If scope is nil, additionally filter to only public content (protected = false)
6. Execute query returning single result or nil

**Test Assertions**:
- returns published content when slug and content_type match
- returns nil when slug does not exist
- returns nil when content_type does not match
- returns nil for unpublished content (scheduled in future)
- returns nil for expired content
- with scope: returns both public and protected content
- enforces slug uniqueness per content_type (same slug allowed across different types)
- with nil scope: returns only public content
- with nil scope: returns nil for protected content

### get_content_by_slug!/3

Bang version of get_content_by_slug with asymmetric behavior based on scope.

```elixir
@spec get_content_by_slug!(Scope.t() | nil, String.t(), content_type()) :: Content.t() | nil
```

**Process**:
1. If scope is provided, delegate to Repo.one! which raises Ecto.NoResultsError when not found
2. If scope is nil, delegate to get_content_by_slug/3 (non-raising, returns nil)

**Test Assertions**:
- with scope: returns content when slug and content_type exist
- with scope: raises Ecto.NoResultsError when slug does not exist
- with scope: raises Ecto.NoResultsError when content_type does not match
- with nil scope: returns nil when content not found (non-raising)
- with nil scope: returns public content when exists
- with nil scope: returns nil for protected content (non-raising)

### preload_tags/1

Preloads the tags association for content structs to avoid N+1 queries.

```elixir
@spec preload_tags(Content.t() | [Content.t()]) :: Content.t() | [Content.t()]
```

**Process**:
1. Delegate to Repo.preload with :tags association

**Test Assertions**:
- preloads tags for single content
- preloads tags for list of content
- handles content with no tags (returns empty list)
- handles empty list input
- avoids N+1 queries when loading tags for multiple content items