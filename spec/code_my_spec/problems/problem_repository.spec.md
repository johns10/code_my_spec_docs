# CodeMySpec.Problems.ProblemRepository

Repository module providing scoped data access operations for problems. Handles database queries with proper scope filtering and user/project isolation.

## Dependencies

- CodeMySpec.Problems.Problem
- CodeMySpec.Repo
- Ecto.Query

## Functions

### list_project_problems/2

Retrieves problems for the active project in scope, optionally filtered by source, source_type, file_path, category, or severity.

```elixir
@spec list_project_problems(Scope.t(), keyword()) :: [Problem.t()]
```

**Process**:
1. Extract project_id from scope
2. Build query filtering by project_id and scope
3. Apply optional filters from keyword list (source, source_type, file_path, category, severity)
4. Return list of problem structs ordered by severity, file_path, line

**Test Assertions**:
- returns empty list when no problems exist for project
- returns all problems scoped to the project when no filters provided
- filters out problems from other projects
- filters by source when source filter provided
- filters by source_type when source_type filter provided
- filters by file_path when file_path filter provided (supports pattern matching)
- filters by category when category filter provided
- filters by severity when severity filter provided
- supports multiple filters combined
- orders results by severity (error, warning, info) then file path

### create_problems/2

Stores a list of problems for the active project without clearing existing problems.

```elixir
@spec create_problems(Scope.t(), [Problem.t() | map()]) :: {:ok, [Problem.t()]} | {:error, term()}
```

**Process**:
1. Validate scope has active project
2. Transform input structs/maps to changesets with project_id from scope
3. Insert all problems in a transaction
4. Return inserted records or error tuple

**Test Assertions**:
- successfully inserts valid problems
- associates problems with project from scope
- rejects problems without required fields
- handles empty list gracefully
- rolls back transaction on validation errors

### replace_project_problems/2

Performs atomic wipe-and-replace operation for project problems. Clears all existing problems for the project then stores the new set.

```elixir
@spec replace_project_problems(Scope.t(), [Problem.t() | map()]) :: {:ok, [Problem.t()]} | {:error, term()}
```

**Process**:
1. Validate scope has active project
2. Begin database transaction
3. Delete all existing problems for project_id
4. Insert new problems with project_id from scope
5. Commit transaction or rollback on error

**Test Assertions**:
- removes all existing problems and stores new ones atomically
- rolls back both delete and insert on error
- handles transition from many problems to zero
- handles transition from zero problems to many
- maintains problems for other projects unchanged

### clear_project_problems/1

Removes all problems for the active project in scope.

```elixir
@spec clear_project_problems(Scope.t()) :: {:ok, integer()} | {:error, term()}
```

**Process**:
1. Extract project_id from scope
2. Delete all problems matching project_id
3. Return count of deleted records

**Test Assertions**:
- deletes all problems for the project
- returns count of deleted records
- does not affect problems from other projects
- handles case when no problems exist
