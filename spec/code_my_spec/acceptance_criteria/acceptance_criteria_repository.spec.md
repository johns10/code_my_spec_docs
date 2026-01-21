# CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository

Repository for acceptance criteria CRUD operations with direct database access. Provides query composables for filtering by story and verification status filtering. All operations respect project and account scoping. The context module delegates read operations directly to this repository and wraps write operations with PubSub broadcasting.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Users.Scope
- Ecto.Query

## Functions

### list_story_criteria/2

Returns all acceptance criteria for a specific story, ordered by creation time.

```elixir
@spec list_story_criteria(Scope.t(), integer()) :: [Criterion.t()]
```

**Process**:
1. Query criteria where story_id matches provided ID
2. Filter by scope's active_project.id
3. Order by inserted_at ascending
4. Return list of criteria

**Test Assertions**:

- returns all criteria for the story ordered by inserted_at
- returns empty list when story has no criteria
- respects project scope, excluding criteria from other projects

### get_criterion!/2

Gets a single criterion by ID within scope. Raises if not found or not in scope.

```elixir
@spec get_criterion!(Scope.t(), integer()) :: Criterion.t()
```

**Process**:
1. Query criterion by ID where project_id matches scope
2. Return criterion or raise Ecto.NoResultsError

**Test Assertions**:

- returns criterion when it exists in project
- raises Ecto.NoResultsError when criterion doesn't exist
- raises Ecto.NoResultsError when criterion exists but belongs to different project

### get_criterion/2

Gets a single criterion by ID within scope. Returns nil if not found.

```elixir
@spec get_criterion(Scope.t(), integer()) :: Criterion.t() | nil
```

**Process**:
1. Query criterion by ID where project_id matches scope
2. Return criterion or nil

**Test Assertions**:

- returns criterion when it exists in project
- returns nil when criterion doesn't exist
- returns nil when criterion exists but belongs to different project

### create_criterion/1

Creates a new acceptance criterion with the provided attributes.

```elixir
@spec create_criterion(map()) :: {:ok, Criterion.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Build new Criterion struct with changeset
2. Insert into database
3. Return criterion or error changeset

**Test Assertions**:

- creates criterion with valid attributes including description, story_id, project_id, account_id
- returns error changeset for invalid attributes (nil description)
- validates required fields: description, story_id, project_id, account_id

### update_criterion/2

Updates an existing acceptance criterion with the provided attributes.

```elixir
@spec update_criterion(Criterion.t(), map()) :: {:ok, Criterion.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Apply changeset with new attributes to criterion
2. Update in database
3. Return updated criterion or error changeset

**Test Assertions**:

- updates criterion with valid attributes (description)
- returns error changeset for invalid attributes (nil description)

### delete_criterion/1

Deletes an acceptance criterion.

```elixir
@spec delete_criterion(Criterion.t()) :: {:ok, Criterion.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Delete criterion from database
2. Return deleted criterion or error

**Test Assertions**:

- deletes criterion successfully
- returns deleted criterion with all fields intact
- criterion is no longer retrievable after deletion

