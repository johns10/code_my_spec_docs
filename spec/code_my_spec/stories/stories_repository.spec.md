# CodeMySpec.Stories.StoriesRepository

Repository for managing Story entities within a project scope. Provides CRUD operations, scoped queries, composable query functions for filtering and sorting, lock management for concurrent editing, and component assignment tracking.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Stories.Story
- CodeMySpec.Users.Scope
- CodeMySpec.Projects.Project
- CodeMySpec.Accounts.Account
- PaperTrail

## Functions

### list_stories/1

Returns all stories for the scope's active project.

```elixir
@spec list_stories(Scope.t()) :: [Story.t()]
```

**Process**:
1. Query stories where project_id matches scope's active_project.id
2. Return list of stories

**Test Assertions**:

- returns all stories for the project
- excludes stories from other projects

### list_project_stories/1

Returns all stories for the scope's active project.

```elixir
@spec list_project_stories(Scope.t()) :: [Story.t()]
```

**Process**:
1. Query stories where project_id matches scope's active_project.id
2. Return list of stories

**Test Assertions**:

- returns all stories for the project
- excludes stories from other projects

### list_project_stories_by_component_priority/1

Returns all project stories ordered by component priority, with unassigned stories last.

```elixir
@spec list_project_stories_by_component_priority(Scope.t()) :: [Story.t()]
```

**Process**:
1. Query stories with left join on component association
2. Filter by scope's active_project.id
3. Order by: stories without components last, then component priority ascending, then title ascending
4. Preload component association
5. Return ordered list of stories

**Test Assertions**:

- returns stories ordered by component priority
- places stories without components at the end
- preloads component association

### list_unsatisfied_stories/1

Returns stories that have no component assigned.

```elixir
@spec list_unsatisfied_stories(Scope.t()) :: [Story.t()]
```

**Process**:
1. Query stories where project_id matches scope and component_id is nil
2. Return list of unsatisfied stories

**Test Assertions**:

- returns only stories without component assignment
- excludes stories with component assignment
- respects project scope

### list_component_stories/2

Returns all stories assigned to a specific component.

```elixir
@spec list_component_stories(Scope.t(), integer()) :: [Story.t()]
```

**Process**:
1. Query stories where component_id matches and project_id matches scope
2. Return list of component stories

**Test Assertions**:

- returns stories assigned to the component
- respects project scope

### get_story/2

Gets a single story by ID within scope. Returns nil if not found.

```elixir
@spec get_story(Scope.t(), integer()) :: Story.t() | nil
```

**Process**:
1. Query story by ID where project_id matches scope
2. Return story or nil

**Test Assertions**:

- returns story when it exists in project
- returns nil when story doesn't exist
- returns nil when story exists but belongs to different project

### get_story!/2

Gets a single story by ID within scope. Raises if not found or not in scope.

```elixir
@spec get_story!(Scope.t(), integer()) :: Story.t()
```

**Process**:
1. Query story by ID where project_id matches scope
2. Return story or raise Ecto.NoResultsError

**Test Assertions**:

- returns story when it exists in project
- raises Ecto.NoResultsError when story doesn't exist
- raises Ecto.NoResultsError when story exists but belongs to different project

### create_story/2

Creates a new story within scope with PaperTrail audit tracking.

```elixir
@spec create_story(Scope.t(), map()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Build new Story struct with changeset
2. If scope has active_project and active_account, put project_id and account_id
3. Insert with PaperTrail for audit tracking
4. Extract model from PaperTrail result
5. Return story or error changeset

**Test Assertions**:

- creates story with valid attributes
- sets project_id from scope's active_project
- sets account_id from scope's active_account
- creates audit trail via PaperTrail
- returns error with invalid attributes (nil title)

### update_story/3

Updates an existing story with PaperTrail audit tracking.

```elixir
@spec update_story(Scope.t(), Story.t(), map()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Apply changeset with attributes
2. Update with PaperTrail for audit tracking
3. Extract model from PaperTrail result
4. Return updated story or error changeset

**Test Assertions**:

- updates story with valid attributes
- creates audit trail via PaperTrail
- returns error with invalid attributes

### delete_story/2

Deletes a story with PaperTrail audit tracking.

```elixir
@spec delete_story(Scope.t(), Story.t()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Delete story with PaperTrail for audit tracking
2. Extract model from PaperTrail result
3. Return deleted story or error

**Test Assertions**:

- deletes story successfully
- creates audit trail via PaperTrail

### by_project/2

Composable query function that filters stories by project.

```elixir
@spec by_project(Ecto.Query.t() | Story, integer()) :: Ecto.Query.t()
```

**Process**:
1. Add where clause filtering by project_id
2. Return modified query

**Test Assertions**:

- filters stories by project_id
- can be composed with other query functions

### by_status/2

Composable query function that filters stories by status.

```elixir
@spec by_status(Ecto.Query.t() | Story, atom()) :: Ecto.Query.t()
```

**Process**:
1. Add where clause filtering by status
2. Return modified query

**Test Assertions**:

- filters stories by status
- can be composed with other query functions

### by_component_priority/2

Composable query function that filters stories by minimum component priority.

```elixir
@spec by_component_priority(Ecto.Query.t() | Story, integer()) :: Ecto.Query.t()
```

**Process**:
1. Join with component association
2. Add where clause filtering by component priority >= min_priority
3. Return modified query

**Test Assertions**:

- filters stories by component priority threshold
- requires join with component

### search_text/2

Composable query function that searches stories by title or description.

```elixir
@spec search_text(Ecto.Query.t() | Story, String.t()) :: Ecto.Query.t()
```

**Process**:
1. Build search term with wildcards
2. Add where clause with ILIKE on title or description
3. Return modified query

**Test Assertions**:

- matches stories by title
- matches stories by description
- search is case insensitive

### locked_by/2

Composable query function that filters stories by lock owner.

```elixir
@spec locked_by(Ecto.Query.t() | Story, integer()) :: Ecto.Query.t()
```

**Process**:
1. Add where clause filtering by locked_by user_id
2. Return modified query

**Test Assertions**:

- filters stories by lock owner

### lock_expired/1

Composable query function that filters stories with expired locks.

```elixir
@spec lock_expired(Ecto.Query.t() | Story) :: Ecto.Query.t()
```

**Process**:
1. Add where clause filtering for non-nil lock_expires_at that is in the past
2. Return modified query

**Test Assertions**:

- returns stories with expired locks
- excludes stories with future lock expiration

### ordered_by_name/1

Composable query function that orders stories by title ascending.

```elixir
@spec ordered_by_name(Ecto.Query.t() | Story) :: Ecto.Query.t()
```

**Process**:
1. Add order_by clause for title ascending
2. Return modified query

**Test Assertions**:

- orders stories alphabetically by title

### ordered_by_status/1

Composable query function that orders stories by status then inserted_at.

```elixir
@spec ordered_by_status(Ecto.Query.t() | Story) :: Ecto.Query.t()
```

**Process**:
1. Add order_by clause for status ascending, then inserted_at ascending
2. Return modified query

**Test Assertions**:

- orders stories by status then insertion time

### paginate/3

Composable query function that applies limit and offset for pagination.

```elixir
@spec paginate(Ecto.Query.t() | Story, integer(), integer()) :: Ecto.Query.t()
```

**Process**:
1. Calculate offset as (page - 1) * per_page
2. Add limit and offset clauses
3. Return modified query

**Test Assertions**:

- limits results to per_page count
- offsets results based on page number
- different pages return different results

### with_preloads/2

Composable query function that preloads specified associations.

```elixir
@spec with_preloads(Ecto.Query.t() | Story, list()) :: Ecto.Query.t()
```

**Process**:
1. Add preload clause for specified associations
2. Return modified query

**Test Assertions**:

- preloads specified associations

### acquire_lock/3

Acquires an edit lock on a story for the scope's user.

```elixir
@spec acquire_lock(Scope.t(), Story.t(), integer()) :: {:ok, Story.t()} | {:error, :already_locked}
```

**Process**:
1. Calculate lock expiration time (default 30 minutes)
2. Check if story is already locked
3. If locked, return {:error, :already_locked}
4. If not locked, update lock fields with user_id, locked_at, lock_expires_at
5. Return updated story

**Test Assertions**:

- acquires lock on unlocked story
- sets locked_by to scope's user id
- sets locked_at to current time
- sets lock_expires_at based on expires_in_minutes
- fails with :already_locked when story has active lock

### release_lock/2

Releases an edit lock on a story.

```elixir
@spec release_lock(Scope.t(), Story.t()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Update lock fields to nil (locked_by, locked_at, lock_expires_at)
2. Return updated story

**Test Assertions**:

- clears all lock fields
- story is no longer locked after release

### extend_lock/3

Extends an existing lock if the scope's user is the lock owner.

```elixir
@spec extend_lock(Scope.t(), Story.t(), integer()) :: {:ok, Story.t()} | {:error, :not_lock_owner}
```

**Process**:
1. Check if scope's user is the lock owner
2. If not owner, return {:error, :not_lock_owner}
3. If owner, update lock_expires_at with new expiration time
4. Return updated story

**Test Assertions**:

- extends lock expiration for lock owner
- fails with :not_lock_owner when different user attempts extension

### is_locked?/1

Checks if a story has an active (non-expired) lock.

```elixir
@spec is_locked?(Story.t()) :: boolean()
```

**Process**:
1. Check locked_by is not nil
2. Check lock_expires_at is not nil
3. Check lock_expires_at is in the future
4. Return true if all conditions met, false otherwise

**Test Assertions**:

- returns true for story with active lock
- returns false for story without lock
- returns false for story with expired lock

### lock_owner/1

Returns the user_id of the lock owner, or nil if not locked.

```elixir
@spec lock_owner(Story.t()) :: integer() | nil
```

**Process**:
1. Return story.locked_by

**Test Assertions**:

- returns user_id when locked
- returns nil when not locked

### set_story_component/3

Assigns a component to a story with PaperTrail audit tracking.

```elixir
@spec set_story_component(Scope.t(), Story.t(), integer()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Apply changeset with component_id
2. Update with PaperTrail for audit tracking
3. Extract model from PaperTrail result
4. Return updated story or error

**Test Assertions**:

- assigns component to story
- creates audit trail via PaperTrail

### clear_story_component/2

Removes component assignment from a story with PaperTrail audit tracking.

```elixir
@spec clear_story_component(Scope.t(), Story.t()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Apply changeset with component_id set to nil
2. Update with PaperTrail for audit tracking
3. Extract model from PaperTrail result
4. Return updated story or error

**Test Assertions**:

- removes component assignment
- creates audit trail via PaperTrail