# CodeMySpec.Stories

**Type**: context

Phoenix context for managing user stories within projects. Provides the public API for story CRUD operations, component assignments, and PubSub notifications. Supports pluggable implementations for local database access (StoriesRepository) or remote HTTP API (RemoteClient) based on configuration.

## Delegates

- list_stories/1: StoriesRepository.list_stories/1
- list_project_stories/1: StoriesRepository.list_project_stories/1
- list_project_stories_by_component_priority/1: StoriesRepository.list_project_stories_by_component_priority/1
- list_unsatisfied_stories/1: StoriesRepository.list_unsatisfied_stories/1
- list_component_stories/2: StoriesRepository.list_component_stories/2
- get_story!/2: StoriesRepository.get_story!/2
- get_story/2: StoriesRepository.get_story/2

## Functions

### subscribe_stories/1

Subscribe to scoped notifications about story changes for an account.

```elixir
@spec subscribe_stories(Scope.t()) :: :ok | {:error, term()}
```

**Process**:
1. Extract account_id from scope's active_account
2. Subscribe to PubSub topic "user:{account_id}:stories"

**Test Assertions**:
- subscribes to account-scoped story events
- receives {:created, story}, {:updated, story}, {:deleted, story} messages

### list_stories/1

Returns all stories for the active project in scope.

```elixir
@spec list_stories(Scope.t()) :: [Story.t()]
```

**Process**:
1. Delegate to configured implementation module (StoriesRepository or RemoteClient)
2. Return list of stories for the project

**Test Assertions**:
- returns all stories for the project
- returns empty list when no stories exist
- respects project scope

### list_project_stories/1

Returns all stories for the active project.

```elixir
@spec list_project_stories(Scope.t()) :: [Story.t()]
```

**Process**:
1. Delegate to configured implementation module
2. Return list of project stories

**Test Assertions**:
- returns stories for the active project
- excludes stories from other projects

### list_project_stories_by_component_priority/1

Returns stories ordered by their assigned component's priority.

```elixir
@spec list_project_stories_by_component_priority(Scope.t()) :: [Story.t()]
```

**Process**:
1. Query stories with left join on component
2. Order by: unassigned stories last, then component priority ascending, then story title
3. Preload component associations
4. Return ordered list

**Test Assertions**:
- returns stories ordered by component priority
- places unassigned stories at the end
- preloads component association

### list_unsatisfied_stories/1

Returns stories that have no component assigned.

```elixir
@spec list_unsatisfied_stories(Scope.t()) :: [Story.t()]
```

**Process**:
1. Query stories where component_id is nil
2. Filter by active project
3. Return unassigned stories

**Test Assertions**:
- returns only stories without component assignment
- excludes stories with component_id set
- respects project scope

### list_component_stories/2

Returns stories assigned to a specific component.

```elixir
@spec list_component_stories(Scope.t(), binary()) :: [Story.t()]
```

**Process**:
1. Query stories where component_id matches
2. Filter by active project
3. Return matching stories

**Test Assertions**:
- returns stories assigned to the component
- returns empty list when component has no stories
- respects project scope

### get_story!/2

Gets a single story by ID within scope. Raises if not found.

```elixir
@spec get_story!(Scope.t(), integer()) :: Story.t()
```

**Process**:
1. Delegate to configured implementation
2. Return story or raise Ecto.NoResultsError

**Test Assertions**:
- returns story when it exists in project
- raises Ecto.NoResultsError when story doesn't exist
- raises Ecto.NoResultsError when story exists but in different project

### get_story/2

Gets a single story by ID within scope. Returns nil if not found.

```elixir
@spec get_story(Scope.t(), integer()) :: Story.t() | nil
```

**Process**:
1. Delegate to configured implementation
2. Return story or nil

**Test Assertions**:
- returns story when it exists in project
- returns nil when story doesn't exist
- returns nil when story exists but in different project

### create_story/2

Creates a new story within scope.

```elixir
@spec create_story(Scope.t(), map()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Delegate to configured implementation with scope and attrs
2. On success, broadcast {:created, story} event
3. Return result tuple

**Test Assertions**:
- creates story with valid attributes
- sets project_id and account_id from scope
- broadcasts created event on success
- returns changeset error for invalid attributes
- validates required fields (title, description, acceptance_criteria)

### update_story/3

Updates an existing story.

```elixir
@spec update_story(Scope.t(), Story.t(), map()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify story belongs to scope's account (assert account_id matches)
2. Delegate to configured implementation
3. On success, broadcast {:updated, story} event
4. Return result tuple

**Test Assertions**:
- updates story with valid attributes
- verifies ownership via account_id
- broadcasts updated event on success
- returns changeset error for invalid attributes

### delete_story/2

Deletes a story.

```elixir
@spec delete_story(Scope.t(), Story.t()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify story belongs to scope's account
2. Delegate to configured implementation
3. On success, broadcast {:deleted, story} event
4. Return result tuple

**Test Assertions**:
- deletes story successfully
- verifies ownership via account_id
- broadcasts deleted event on success

### change_story/3

Returns an Ecto.Changeset for tracking story changes.

```elixir
@spec change_story(Scope.t(), Story.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Verify story belongs to scope's account
2. Build changeset from Story.changeset/2
3. Return changeset (does not persist)

**Test Assertions**:
- returns changeset for valid story
- validates ownership before returning changeset
- does not persist changes

### set_story_component/3

Sets the component that satisfies a story.

```elixir
@spec set_story_component(Scope.t(), Story.t(), binary()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify story belongs to scope's account
2. Delegate to configured implementation
3. On success, broadcast {:updated, story} event
4. Return result tuple

**Test Assertions**:
- assigns component to story
- broadcasts updated event on success
- returns error for invalid component_id
- verifies foreign key constraint on component

### clear_story_component/2

Clears the component assignment from a story.

```elixir
@spec clear_story_component(Scope.t(), Story.t()) :: {:ok, Story.t()}
```

**Process**:
1. Verify story belongs to scope's account
2. Delegate to configured implementation (sets component_id to nil)
3. On success, broadcast {:updated, story} event
4. Return result tuple

**Test Assertions**:
- clears component assignment
- broadcasts updated event on success
- story remains valid after clearing

### story_fully_verified?/2

Checks if all acceptance criteria for a story are verified.

```elixir
@spec story_fully_verified?(Scope.t(), Story.t()) :: boolean()
```

**Process**:
1. Query AcceptanceCriteria.list_story_criteria/2 for the story
2. Return true if all criteria have verified: true, false otherwise
3. Return true if story has no criteria

**Test Assertions**:
- returns true when all criteria are verified
- returns false when any criterion is not verified
- returns true when story has no criteria

## Dependencies

- CodeMySpec.AcceptanceCriteria
- CodeMySpec.Stories.Story
- CodeMySpec.Stories.StoriesRepository
- CodeMySpec.Stories.RemoteClient
- CodeMySpec.Users.Scope
- Phoenix.PubSub

## Components

### Stories.Story

Ecto schema representing a user story with title, description, acceptance criteria, and optional component assignment. Supports locking for concurrent editing.

### Stories.StoriesRepository

Repository for story CRUD operations with direct database access. Provides query composables for filtering, searching, and pagination. Includes pessimistic locking support with time-based expiration.

### Stories.RemoteClient

HTTP client for Stories API using Req. Used in CLI/VSCode environments to communicate with remote server via OAuth2 authentication.

### Stories.Markdown

Handles parsing and formatting of user stories in markdown format for import/export functionality. Converts between markdown documents and story attribute maps.