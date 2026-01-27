# CodeMySpec.Sessions.SessionsRepository

Repository module providing data access operations for Session entities with user and project scoping. Handles session retrieval, completion, and preloading of associated data including interactions, components, and child sessions.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.Interaction
- CodeMySpec.Users.Scope

## Delegates

None.

## Functions

### get_session!/2

Retrieves a session by ID with all associated preloads, raising if not found.

```elixir
@spec get_session!(Scope.t(), integer()) :: Session.t()
```

**Process**:
1. Build query for Session with preloads for project, component, interactions (ordered by inserted_at desc), component's parent_component, and child_sessions with their components
2. Fetch session by ID and user_id from scope, raising Ecto.NoResultsError if not found
3. Populate the virtual display_name field from session type

**Test Assertions**:
- returns session with all preloads when session exists for user
- raises Ecto.NoResultsError when session does not exist
- raises Ecto.NoResultsError when session belongs to different user
- populates display_name virtual field
- orders interactions by inserted_at descending

### get_session/2

Retrieves a session by ID with all associated preloads, returning nil if not found.

```elixir
@spec get_session(Scope.t(), integer()) :: Session.t() | nil
```

**Process**:
1. Build query for Session with preloads for project, component, interactions (ordered by inserted_at desc), component's parent_component, and child_sessions with their components
2. Fetch session by ID, project_id, and user_id from scope
3. Return nil if not found, otherwise populate display_name and return session

**Test Assertions**:
- returns session with all preloads when session exists for user and project
- returns nil when session does not exist
- returns nil when session belongs to different user
- returns nil when session belongs to different project
- populates display_name virtual field
- orders interactions by inserted_at descending

### preload_session/2

Preloads all standard associations on an existing session struct.

```elixir
@spec preload_session(Scope.t(), Session.t()) :: Session.t()
```

**Process**:
1. Apply Repo.preload with standard preload list: project, component, interactions (ordered), component's parent_component, and child_sessions with their components
2. Return the preloaded session

**Test Assertions**:
- preloads project association
- preloads component association
- preloads interactions ordered by inserted_at descending
- preloads component's parent_component
- preloads child_sessions with their components

### complete_session/2

Marks a session as complete, validating ownership first.

```elixir
@spec complete_session(Scope.t(), Session.t()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Assert session belongs to the active account and user via pattern matching (raises on mismatch)
2. Create changeset updating status to :complete
3. Persist update and return {:ok, session} on success

**Test Assertions**:
- updates session status to :complete when user owns session
- raises MatchError when session account_id does not match scope
- raises MatchError when session user_id does not match scope
- returns {:error, changeset} on validation failure

### update_external_conversation_id/3

Updates the external_conversation_id field on a session.

```elixir
@spec update_external_conversation_id(Scope.t(), integer(), String.t()) ::
  {:ok, Session.t()} | {:error, :session_not_found} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Attempt to retrieve session by ID using get_session/2
2. Return {:error, :session_not_found} if session is nil
3. Create changeset with new external_conversation_id value
4. Persist update and return result

**Test Assertions**:
- updates external_conversation_id when session exists
- returns {:error, :session_not_found} when session does not exist
- returns {:error, :session_not_found} when session belongs to different user

### populate_display_name/1

Populates the virtual display_name field on a session struct.

```elixir
@spec populate_display_name(Session.t()) :: Session.t()
```

**Process**:
1. Call Session.format_display_name/1 to generate display name from session type
2. Return session with display_name field set

**Test Assertions**:
- sets display_name from session type
- handles nil type gracefully

### populate_display_names/1

Populates the virtual display_name field on a list of session structs.

```elixir
@spec populate_display_names([Session.t()]) :: [Session.t()]
```

**Process**:
1. Map over list of sessions applying populate_display_name/1 to each
2. Return list of sessions with display_name fields populated

**Test Assertions**:
- populates display_name on all sessions in list
- returns empty list for empty input

### add_edited_file/2

Add a file path to the session's edited_files list.

```elixir
@spec add_edited_file(integer(), Path.t()) :: :ok | {:error, :session_not_found}
```

**Process**:
1. Find session by ID
2. Return `{:error, :session_not_found}` if not found
3. Check if file path already exists in edited_files (dedup)
4. If not present, append file path to edited_files array
5. Persist update
6. Return `:ok`

**Test Assertions**:
- adds file path to empty edited_files list
- appends file path to existing edited_files list
- does not add duplicate file paths
- returns :ok on success
- returns {:error, :session_not_found} when session does not exist

### get_edited_files/1

Get the list of edited file paths for a session.

```elixir
@spec get_edited_files(integer()) :: {:ok, [Path.t()]} | {:error, :session_not_found}
```

**Process**:
1. Find session by ID
2. Return `{:error, :session_not_found}` if not found
3. Return `{:ok, edited_files}` with the list (empty list if nil)

**Test Assertions**:
- returns {:ok, []} for session with no edited files
- returns {:ok, paths} for session with edited files
- returns {:error, :session_not_found} when session does not exist

### clear_edited_files/1

Clear all edited file paths for a session.

```elixir
@spec clear_edited_files(integer()) :: :ok | {:error, :session_not_found}
```

**Process**:
1. Find session by ID
2. Return `{:error, :session_not_found}` if not found
3. Set edited_files to empty list
4. Persist update
5. Return `:ok`

**Test Assertions**:
- clears edited_files list
- returns :ok on success
- returns {:error, :session_not_found} when session does not exist
- is idempotent (clearing empty list succeeds)
