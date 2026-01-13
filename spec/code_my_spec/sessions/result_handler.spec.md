# CodeMySpec.Sessions.ResultHandler

**Type**: module

Handles processing of command results within session workflows. Coordinates updating interaction records with results, invoking command-specific result handlers, and determining session completion status via orchestrators.

## Functions

### handle_result/5

Process a result for a specific interaction within a session.

```elixir
@spec handle_result(Scope.t(), integer(), binary(), map(), keyword()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Retrieve the session by ID using `get_session/2`
2. Create a Result struct from the provided result attributes via `Sessions.create_result/2`
3. Find the interaction within the session's interactions list using `find_interaction/2`
4. Invoke the command module's `handle_result/4` callback to process the result and get session attribute updates
5. Check if session should be marked complete via `maybe_add_completion_status/4`
6. Complete the interaction by storing the final result via `InteractionsRepository.complete/2`
7. Optionally update the session with new attributes via `maybe_update_session/3`
8. Refresh and return the updated session

**Test Assertions**:
- returns `{:ok, session}` when result is processed successfully
- returns `{:error, :session_not_found}` when session does not exist
- returns `{:error, :interaction_not_found}` when interaction is not in session
- invokes the command module's `handle_result/4` callback
- updates the interaction with the final result
- updates session attributes when command handler returns changes
- does not update session when command handler returns empty map
- marks session as complete when orchestrator's `complete?/1` returns true
- refreshes and returns the updated session

### get_session/2

Retrieve a session by ID with preloaded associations.

```elixir
@spec get_session(Scope.t(), integer()) :: {:ok, Session.t()} | {:error, :session_not_found}
```

**Process**:
1. Query the sessions repository for the session by ID
2. Return `{:ok, session}` if found
3. Return `{:error, :session_not_found}` if not found

**Test Assertions**:
- returns `{:ok, session}` when session exists
- returns `{:error, :session_not_found}` when session does not exist
- preloads interactions association

### find_interaction/2

Find an interaction within a session's interactions list.

```elixir
@spec find_interaction(Session.t(), binary()) :: {:ok, Interaction.t()} | {:error, :interaction_not_found}
```

**Process**:
1. Search the session's interactions list for matching interaction ID
2. Return `{:ok, interaction}` if found
3. Return `{:error, :interaction_not_found}` if not found

**Test Assertions**:
- returns `{:ok, interaction}` when interaction exists in session
- returns `{:error, :interaction_not_found}` when interaction is not in session
- matches interaction by ID

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Sessions
- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.SessionsRepository
- CodeMySpec.Sessions.Interaction
- CodeMySpec.Sessions.InteractionsRepository
