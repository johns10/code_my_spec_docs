# CodeMySpec.Sessions.InteractionsRepository

**Type**: module

Repository for managing Interaction records with persistent database storage. Provides CRUD operations for interactions within sessions, including creation, retrieval, completion with results, deletion, and session-scoped listing.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Sessions.Interaction
- CodeMySpec.Sessions.Result

## Functions

### create/2

Creates a new interaction for a session.

```elixir
@spec create(integer(), Interaction.t()) :: {:ok, Interaction.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Apply changeset to interaction with session_id
2. Insert interaction into database
3. Return {:ok, interaction} or {:error, changeset}

**Test Assertions**:
- creates interaction with valid session and interaction struct
- returns error when session_id is invalid
- associates interaction with the correct session

### get/1

Gets an interaction by ID.

```elixir
@spec get(binary()) :: Interaction.t() | nil
```

**Process**:
1. Query interaction by primary key
2. Return interaction or nil if not found

**Test Assertions**:
- returns interaction when it exists
- returns nil when interaction doesn't exist
- returns nil for invalid ID format

### get!/1

Gets an interaction by ID, raises if not found.

```elixir
@spec get!(binary()) :: Interaction.t()
```

**Process**:
1. Query interaction by primary key
2. Return interaction or raise Ecto.NoResultsError

**Test Assertions**:
- returns interaction when it exists
- raises Ecto.NoResultsError when interaction doesn't exist

### complete/2

Updates an interaction with a result, marking it as completed.

```elixir
@spec complete(Interaction.t(), Result.t()) :: {:ok, Interaction.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Convert Result struct to map attributes
2. Apply changeset with result attributes
3. Update interaction in database
4. Return {:ok, interaction} or {:error, changeset}

**Test Assertions**:
- updates interaction with success result
- updates interaction with error result
- sets completed_at timestamp when result is added
- returns error for invalid result data

### delete/1

Deletes an interaction.

```elixir
@spec delete(Interaction.t()) :: {:ok, Interaction.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Delete interaction from database
2. Return {:ok, interaction} or {:error, changeset}

**Test Assertions**:
- deletes interaction successfully
- returns error when interaction has constraint violations

### list_for_session/1

Lists all interactions for a session, ordered by most recent first.

```elixir
@spec list_for_session(integer()) :: [Interaction.t()]
```

**Process**:
1. Query interactions where session_id matches
2. Order by inserted_at descending (most recent first)
3. Return list of interactions

**Test Assertions**:
- returns all interactions for session ordered by most recent first
- returns empty list when session has no interactions
- excludes interactions from other sessions
