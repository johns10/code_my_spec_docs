# CodeMySpec.Sessions.CommandResolver

Resolves and advances session interactions by determining and creating the next command for a session workflow. Acts as the entry point for progressing sessions through their interaction sequence.

## Dependencies

- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.SessionsRepository
- CodeMySpec.Sessions.Interaction
- CodeMySpec.Sessions.InteractionsRepository
- CodeMySpec.Sessions.SessionsBroadcaster

## Delegates

None

## Functions

### next_command/3

Advances a session to its next interaction by resolving and creating the next command. Handles the complete workflow of validating session state, clearing stale interactions, determining the next step, and broadcasting progress.

```elixir
@spec next_command(Scope.t(), integer(), keyword()) :: {:ok, Session.t()} | {:error, atom()}
```

**Process**:

1. Retrieve the session by ID using `get_session/2`
2. Validate the session status is not `:complete` or `:failed`
3. Clear any pending (incomplete) interaction from the session
4. Call the session type module's `get_next_interaction/1` to determine the next interaction module
5. Call the interaction module's `get_command/3` to generate the command
6. Create a new `Interaction` struct with the command
7. Persist the interaction via `InteractionsRepository.create/2`
8. Refresh the session from the repository
9. Broadcast `step_started` event via `SessionsBroadcaster`
10. Return the refreshed session

**Test Assertions**:

- returns `{:error, :session_not_found}` when session does not exist
- returns `{:error, :complete}` when session status is `:complete`
- returns `{:error, :failed}` when session status is `:failed`
- clears pending interaction (nil result) before creating new one
- preserves completed interactions when clearing pending
- creates new interaction with command from next interaction module
- broadcasts step_started event after creating interaction
- returns `{:ok, session}` with existing pending interaction without creating duplicate
- returns refreshed session with preloaded interactions on success

### get_session/2

Retrieves a session by ID, returning an ok/error tuple for pattern matching in the command resolution pipeline.

```elixir
@spec get_session(Scope.t(), integer()) :: {:ok, Session.t()} | {:error, :session_not_found}
```

**Process**:

1. Query `SessionsRepository.get_session/2` with scope and session ID
2. Return `{:error, :session_not_found}` if nil
3. Return `{:ok, session}` if session exists

**Test Assertions**:

- returns `{:ok, session}` when session exists for scope
- returns `{:error, :session_not_found}` when session does not exist
- returns `{:error, :session_not_found}` when session exists but belongs to different user/project
