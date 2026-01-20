# CodeMySpec.AcceptanceCriteria

**Type**: context

Phoenix context for managing acceptance criteria as first-class entities. Acceptance criteria belong to stories and represent testable conditions that define when a story is complete. This context extracts acceptance criteria from embedded strings within stories into proper domain entities with ordering, status tracking, and verification capabilities.

## Delegates

- list_story_criteria/2: AcceptanceCriteria.AcceptanceCriteriaRepository.list_story_criteria/2
- get_criterion!/2: AcceptanceCriteria.AcceptanceCriteriaRepository.get_criterion!/2
- get_criterion/2: AcceptanceCriteria.AcceptanceCriteriaRepository.get_criterion/2

## Functions

### subscribe_criteria/1

Subscribe to scoped notifications about acceptance criteria changes for an account.

```elixir
@spec subscribe_criteria(Scope.t()) :: :ok | {:error, term()}
```

**Process**:
1. Extract account_id from scope's active_account
2. Subscribe to PubSub topic "user:{account_id}:acceptance_criteria"

**Test Assertions**:
- subscribes to account-scoped criteria events
- receives {:created, criterion}, {:updated, criterion}, {:deleted, criterion} messages

### list_story_criteria/2

Returns all acceptance criteria for a given story ordered by position.

```elixir
@spec list_story_criteria(Scope.t(), integer()) :: [Criterion.t()]
```

**Process**:
1. Delegate to AcceptanceCriteriaRepository.list_story_criteria/2
2. Return ordered list of criteria for the story

**Test Assertions**:
- returns all criteria for the story ordered by position
- returns empty list when story has no criteria
- respects project scope

### get_criterion!/2

Gets a single acceptance criterion by ID within scope. Raises if not found.

```elixir
@spec get_criterion!(Scope.t(), integer()) :: Criterion.t()
```

**Process**:
1. Delegate to AcceptanceCriteriaRepository.get_criterion!/2
2. Return criterion or raise Ecto.NoResultsError

**Test Assertions**:
- returns criterion when it exists in project
- raises Ecto.NoResultsError when criterion doesn't exist
- raises Ecto.NoResultsError when criterion exists but in different project

### get_criterion/2

Gets a single acceptance criterion by ID within scope. Returns nil if not found.

```elixir
@spec get_criterion(Scope.t(), integer()) :: Criterion.t() | nil
```

**Process**:
1. Delegate to AcceptanceCriteriaRepository.get_criterion/2
2. Return criterion or nil

**Test Assertions**:
- returns criterion when it exists in project
- returns nil when criterion doesn't exist
- returns nil when criterion exists but in different project

### create_criterion/3

Creates a new acceptance criterion for a story within scope.

```elixir
@spec create_criterion(Scope.t(), Story.t(), map()) :: {:ok, Criterion.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify story belongs to scope's account
2. Set story_id, project_id, and account_id from context
3. If position not provided, set to next available position for the story
4. Delegate to AcceptanceCriteriaRepository.create_criterion/2
5. On success, broadcast {:created, criterion} event
6. Return result tuple

**Test Assertions**:
- creates criterion with valid attributes
- sets story_id from provided story
- sets project_id and account_id from scope
- auto-assigns next position when not provided
- broadcasts created event on success
- returns changeset error for invalid attributes
- validates required fields (description)

### update_criterion/3

Updates an existing acceptance criterion.

```elixir
@spec update_criterion(Scope.t(), Criterion.t(), map()) :: {:ok, Criterion.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify criterion belongs to scope's account
2. Delegate to AcceptanceCriteriaRepository.update_criterion/2
3. On success, broadcast {:updated, criterion} event
4. Return result tuple

**Test Assertions**:
- updates criterion with valid attributes
- verifies ownership via account_id
- broadcasts updated event on success
- returns changeset error for invalid attributes

### delete_criterion/2

Deletes an acceptance criterion and reorders remaining criteria.

```elixir
@spec delete_criterion(Scope.t(), Criterion.t()) :: {:ok, Criterion.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify criterion belongs to scope's account
2. Delete the criterion via AcceptanceCriteriaRepository.delete_criterion/1
3. Reorder remaining criteria for the story to close gaps
4. On success, broadcast {:deleted, criterion} event
5. Return result tuple

**Test Assertions**:
- deletes criterion successfully
- verifies ownership via account_id
- broadcasts deleted event on success
- reorders remaining criteria to close position gaps

### change_criterion/3

Returns an Ecto.Changeset for tracking criterion changes.

```elixir
@spec change_criterion(Scope.t(), Criterion.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Verify criterion belongs to scope's account
2. Build changeset from Criterion.changeset/2
3. Return changeset (does not persist)

**Test Assertions**:
- returns changeset for valid criterion
- validates ownership before returning changeset
- does not persist changes

### reorder_criteria/3

Reorders acceptance criteria for a story based on a list of criterion IDs.

```elixir
@spec reorder_criteria(Scope.t(), Story.t(), [integer()]) :: {:ok, [Criterion.t()]} | {:error, term()}
```

**Process**:
1. Verify story belongs to scope's account
2. Validate all criterion IDs belong to the story
3. Update positions based on list order (1-indexed)
4. Broadcast {:reordered, criteria} event on success
5. Return updated criteria list

**Test Assertions**:
- reorders criteria based on ID list
- assigns positions starting from 1
- broadcasts reordered event on success
- returns error when criterion ID doesn't belong to story
- returns error when not all story criteria are included

### mark_verified/2

Marks an acceptance criterion as verified.

```elixir
@spec mark_verified(Scope.t(), Criterion.t()) :: {:ok, Criterion.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify criterion belongs to scope's account
2. Update criterion with verified: true and verified_at timestamp
3. Broadcast {:updated, criterion} event on success
4. Return result tuple

**Test Assertions**:
- marks criterion as verified
- sets verified_at timestamp
- broadcasts updated event on success
- idempotent when already verified

### mark_unverified/2

Marks an acceptance criterion as not verified.

```elixir
@spec mark_unverified(Scope.t(), Criterion.t()) :: {:ok, Criterion.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify criterion belongs to scope's account
2. Update criterion with verified: false and clear verified_at
3. Broadcast {:updated, criterion} event on success
4. Return result tuple

**Test Assertions**:
- marks criterion as unverified
- clears verified_at timestamp
- broadcasts updated event on success
- idempotent when already unverified

### import_from_strings/3

Imports acceptance criteria from a list of strings, creating criterion records for each.

```elixir
@spec import_from_strings(Scope.t(), Story.t(), [String.t()]) :: {:ok, [Criterion.t()]} | {:error, term()}
```

**Process**:
1. Verify story belongs to scope's account
2. Create criterion for each string with auto-assigned positions
3. Broadcast {:created, criterion} for each created criterion
4. Return list of created criteria

**Test Assertions**:
- creates criterion for each string
- assigns sequential positions
- handles empty list gracefully
- broadcasts created event for each criterion

### export_to_strings/2

Exports acceptance criteria for a story as a list of description strings.

```elixir
@spec export_to_strings(Scope.t(), Story.t()) :: [String.t()]
```

**Process**:
1. Load all criteria for the story ordered by position
2. Extract description from each criterion
3. Return list of description strings

**Test Assertions**:
- returns descriptions in position order
- returns empty list when story has no criteria
- respects project scope

## Dependencies

- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository
- CodeMySpec.Stories.Story
- CodeMySpec.Users.Scope
- Phoenix.PubSub

## Components

### AcceptanceCriteria.Criterion

Ecto schema representing a single acceptance criterion. Contains the description text, ordering position, verification status, and belongs to a story. Scoped to account and project for multi-tenancy.

### AcceptanceCriteria.AcceptanceCriteriaRepository

Repository for acceptance criteria CRUD operations with direct database access. Provides query composables for filtering by story, ordering by position, and verification status filtering.
