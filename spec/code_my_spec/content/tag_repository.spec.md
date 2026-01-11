# CodeMySpec.Content.TagRepository

Query builder module for tag upsert and lookup.

Handles tag normalization and conflict resolution on unique constraints.
Tags are single-tenant (no account_id/project_id scoping) and shared globally
across the deployed content system.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Content.Tag

## Functions

### upsert_tag/1

Creates a new tag or returns existing tag if slug already exists.

```elixir
@spec upsert_tag(String.t()) :: {:ok, Tag.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Generate slug from name using slugify helper (lowercase, remove special chars, replace spaces with hyphens)
2. Look up existing tag by slug
3. If no existing tag, create new tag with name and slug via changeset
4. If tag exists, return the existing tag

**Test Assertions**:
- creates new tag with normalized name and slug
- normalizes uppercase names to lowercase slugs
- normalizes mixed case names to lowercase slugs
- generates URL-safe slug from special characters
- returns existing tag when slug already exists globally
- returns existing tag when different case matches existing slug
- enforces global uniqueness - same slug cannot exist twice
- returns error for invalid tag name (empty string)
- returns error for tag name exceeding max length (51+ chars)
- handles tag name at max length boundary (50 chars)

### list_tags/0

Returns all tags ordered alphabetically by name.

```elixir
@spec list_tags() :: [Tag.t()]
```

**Process**:
1. Build query from Tag schema
2. Order by name ascending
3. Execute query and return all results

**Test Assertions**:
- returns all tags ordered alphabetically
- returns empty list when no tags exist
- returns all tags globally - no scoping

### get_tag_by_slug/1

Retrieves a tag by its slug, returning nil if not found.

```elixir
@spec get_tag_by_slug(String.t()) :: Tag.t() | nil
```

**Process**:
1. Build query from Tag schema
2. Apply slug filter using by_slug/2
3. Execute query expecting zero or one result

**Test Assertions**:
- returns tag when slug exists
- returns nil when slug does not exist
- returns tag globally - no scoping

### get_tag_by_slug!/1

Retrieves a tag by its slug, raising if not found.

```elixir
@spec get_tag_by_slug!(String.t()) :: Tag.t()
```

**Process**:
1. Build query from Tag schema
2. Apply slug filter using by_slug/2
3. Execute query expecting exactly one result, raises Ecto.NoResultsError otherwise

**Test Assertions**:
- returns tag when slug exists
- raises Ecto.NoResultsError when slug does not exist

### by_slug/2

Query fragment that filters tags by slug. Composable with other query functions.

```elixir
@spec by_slug(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
```

**Process**:
1. Add where clause filtering by slug field

**Test Assertions**:
- filters query by slug
- returns empty result when slug does not exist
- can be composed with other query functions