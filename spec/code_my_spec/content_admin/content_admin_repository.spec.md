# ContentAdminRepository

Provides multi-tenant data access for ContentAdmin entities with account and project scoping. Handles retrieval of content admin records for validation and preview workflows, applying strict multi-tenant filtering via Scope.

Note: This repository applies account_id and project_id filtering for administrative access. ContentRepository handles published content access without multi-tenant filtering.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.ContentAdmin.ContentAdmin
- CodeMySpec.Users.Scope

## Functions

### list_content/1

Returns all content admin records for the given scope, ordered by insertion date descending.

```elixir
@spec list_content(Scope.t()) :: [ContentAdmin.t()]
```

**Process**:
1. Filter by account_id from scope.active_account.id
2. Filter by project_id from scope.active_project.id
3. Order by inserted_at descending (newest first)
4. Execute query and return all matching records

**Test Assertions**:
- returns content admin records for the given scope
- filters by account_id correctly (excludes records from other accounts)
- filters by project_id correctly (excludes records from other projects)
- orders results by inserted_at descending (newest first)
- returns empty list when no content exists for scope
- returns multiple records when they exist

### list_content_with_errors/1

Returns content admin records that have parse errors for the given scope, ordered by insertion date descending.

```elixir
@spec list_content_with_errors(Scope.t()) :: [ContentAdmin.t()]
```

**Process**:
1. Filter by account_id from scope.active_account.id
2. Filter by project_id from scope.active_project.id
3. Filter by parse_status == :error
4. Order by inserted_at descending (newest first)
5. Execute query and return all matching records

**Test Assertions**:
- returns only content with parse_status :error
- excludes content with parse_status :success
- filters by account_id correctly
- filters by project_id correctly
- orders results by inserted_at descending
- returns empty list when no errored content exists

### get_content!/2

Gets a single content admin record by ID for the given scope. Raises if not found or not accessible within scope.

```elixir
@spec get_content!(Scope.t(), integer()) :: ContentAdmin.t()
```

**Process**:
1. Filter by id matching the provided id
2. Filter by account_id from scope.active_account.id
3. Filter by project_id from scope.active_project.id
4. Execute query with Repo.one! (raises on not found)

**Test Assertions**:
- returns content admin record when id exists within scope
- raises Ecto.NoResultsError when id does not exist
- raises Ecto.NoResultsError when id exists but belongs to different account
- raises Ecto.NoResultsError when id exists but belongs to different project
- returns complete ContentAdmin struct with all fields