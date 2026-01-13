# CodeMySpec.Sessions.OrchestratorBehaviour

**Type**: module (behaviour)

Defines the contract for session type orchestrators. Orchestrators determine the next interaction step based on session state and whether a session is complete. They are stateless - all state lives in the Session record and its embedded Interactions. State transitions are handled by SessionsRepository and ResultHandler, not orchestrators.

## Delegates

None - this module defines callbacks only.

## Functions

### steps/0

Returns the ordered list of step modules for this orchestrator type.

```elixir
@callback steps() :: [module()]
```

**Process**:
1. Return a list of step modules in execution order
2. Each module in the list represents a discrete workflow step
3. The order defines the default progression through the workflow

**Test Assertions**:
- returns a non-empty list of modules
- all returned values are valid Elixir modules
- modules are ordered according to workflow progression

### get_next_interaction/1

Determines the next interaction module for the given session based on its current state.

```elixir
@callback get_next_interaction(session :: Session.t()) ::
  {:ok, module()} | {:error, :session_complete | atom()}
```

**Process**:
1. Examine the session's interaction history to find the last completed interaction
2. Extract the status and module from the last completed interaction
3. Based on the status and current step, determine the next step module
4. Return `{:ok, module}` with the next step to execute
5. Return `{:error, :session_complete}` if all steps are finished
6. Return `{:error, reason}` for invalid states or unknown modules

**Test Assertions**:
- returns `{:ok, first_step_module}` for session with no completed interactions
- returns `{:ok, next_step_module}` based on last completed interaction status
- returns `{:error, :session_complete}` when final step completes successfully
- returns `{:error, :invalid_state}` for unrecognized state combinations
- returns `{:error, :invalid_interaction}` for modules not in steps list
- handles retry logic by returning same step on non-ok status

### complete?/1

Checks if the session is complete based on its current state.

```elixir
@callback complete?(session_or_interaction :: Session.t() | Interaction.t()) :: boolean()
```

**Process**:
1. Accept either a Session struct or an Interaction struct
2. When given a Session, extract the last interaction and delegate to interaction check
3. When given an Interaction, check if it represents the final step with successful status
4. Return true only if the session has reached its terminal successful state
5. Return false for incomplete sessions or failed final steps

**Test Assertions**:
- returns false for session with no interactions
- returns false for session with pending interactions
- returns true when final step has :ok status
- returns false when final step has :error status
- accepts Session struct and delegates to last interaction
- accepts Interaction struct and checks directly
- returns false for intermediate steps regardless of status

## Dependencies

- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.Interaction
