# CodeMySpec.Issues.IssuesRepository

## Type

repository

Repository for issue CRUD operations with direct database access. Provides query composables for filtering by status, severity, story, and project. Includes severity ordering and upsert support for deduplication when creating issues from QA results.

## Dependencies

- Ecto.Query
- CodeMySpec.Repo
- CodeMySpec.Issues.Issue
- CodeMySpec.Users.Scope

## Functions

### list_issues/1

Returns all issues for the active project.

```elixir
@spec list_issues(Scope.t()) :: [Issue.t()]
```

**Process**:
1. Query issues where project_id matches scope
2. Order by severity index ascending, then inserted_at descending
3. Return list

**Test Assertions**:
- returns all issues for the project
- returns empty list when no issues exist
- orders by severity (critical first) then newest first
- excludes issues from other projects

### list_by_status/2

Returns issues filtered by status for the active project.

```elixir
@spec list_by_status(Scope.t(), atom()) :: [Issue.t()]
```

**Process**:
1. Query issues where project_id and status match
2. Order by severity index ascending, then inserted_at descending
3. Return list

**Test Assertions**:
- returns only issues with matching status
- returns empty list when none match
- respects project scope

### list_by_story/2

Returns issues for a specific story.

```elixir
@spec list_by_story(Scope.t(), integer()) :: [Issue.t()]
```

**Process**:
1. Query issues where project_id and story_id match
2. Order by severity index ascending, then inserted_at descending
3. Return list

**Test Assertions**:
- returns issues for the given story
- returns empty list when story has no issues
- respects project scope

### get_issue!/2

Gets a single issue by ID within project scope. Raises if not found.

```elixir
@spec get_issue!(Scope.t(), binary()) :: Issue.t()
```

**Process**:
1. Query by id and project_id
2. Return issue or raise Ecto.NoResultsError

**Test Assertions**:
- returns issue when it exists
- raises when not found
- raises when issue is in different project

### create_issue/2

Creates a new issue.

```elixir
@spec create_issue(Scope.t(), map()) :: {:ok, Issue.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Build changeset from attrs
2. Put project_id and account_id from scope
3. Insert to database

**Test Assertions**:
- creates issue with valid attrs
- sets project_id and account_id from scope
- returns error for invalid attrs

### upsert_issue/2

Creates an issue or skips if one already exists with the same title + story_id + project_id.

```elixir
@spec upsert_issue(Scope.t(), map()) :: {:ok, Issue.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Build changeset from attrs
2. Put project_id and account_id from scope
3. Insert with on_conflict: :nothing, conflict_target: [:title, :story_id, :project_id]
4. If conflict (no insert), fetch existing record
5. Return the issue

**Test Assertions**:
- creates issue when no conflict
- returns existing issue on duplicate title + story_id + project_id
- does not overwrite existing issue data on conflict

### update_status/3

Updates issue status and optional resolution.

```elixir
@spec update_status(Issue.t(), atom(), String.t() | nil) :: {:ok, Issue.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Build status_changeset with new status and optional resolution
2. Update in database

**Test Assertions**:
- updates status successfully
- sets resolution when provided
- returns error for invalid status transition

### count_by_status_and_min_severity/3

Counts issues matching a status with severity at or above a threshold.

```elixir
@spec count_by_status_and_min_severity(Scope.t(), atom(), atom()) :: integer()
```

**Process**:
1. Query issues where project_id, status, and severity match
2. Severity comparison uses the severity index (lower index = more severe)
3. Return count

**Test Assertions**:
- counts issues at or above minimum severity
- returns 0 when no matching issues
- respects project scope

### delete_issue/1

Deletes an issue.

```elixir
@spec delete_issue(Issue.t()) :: {:ok, Issue.t()} | {:error, Ecto.Changeset.t()}
```

**Test Assertions**:
- deletes issue successfully
- returns error for non-existent issue
