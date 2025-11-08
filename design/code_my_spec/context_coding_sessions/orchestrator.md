# Orchestrator

## Purpose

Stateless orchestrator managing the sequence of context implementation steps, determining workflow progression based on completed interactions. Implements the OrchestratorBehaviour to coordinate multi-step workflows including child ComponentCodingSession spawning, validation loops for component completion, and finalization. All workflow state persists through the Sessions context with no in-memory state maintained by the orchestrator.

## Public API

```elixir
@behaviour CodeMySpec.Sessions.OrchestratorBehaviour

# Returns ordered list of step modules for this workflow
@spec steps() :: [module()]

# Determines the next step module based on session state
@spec get_next_interaction(session :: Session.t()) ::
  {:ok, module()} | {:error, :session_complete | atom()}

# Checks if session has reached completion
@spec complete?(session_or_interaction :: Session.t() | Interaction.t()) :: boolean()
```

## Execution Flow

### Step Progression Logic

1. **Initialization Check**: Extract last completed interaction from session
   - If no completed interactions exist → return `Steps.Initialize`
   - If completed interactions exist → proceed to step resolution

2. **Status Extraction**: Extract result status from last completed interaction
   - Status values: `:ok`, `:error`, `:warning`
   - Module reference identifies which step was last executed

3. **Step Resolution**: Determine next step based on (status, module) tuple
   - Use pattern matching to encode workflow state machine
   - Handle validation loops for retryable failures
   - Return appropriate step module or completion signal

### State Machine Transitions

The workflow consists of 3 steps with validation performed in SpawnComponentCodingSessions's handle_result:

**Initialize Step**
- `:ok` status → proceed to `SpawnComponentCodingSessions`
- Any other status → retry `Initialize`

**SpawnComponentCodingSessions Step**
- `:ok` status → proceed to `Finalize`
- `:error` status → loop back to `SpawnComponentCodingSessions` (validation failed in handle_result)
- Any other status → retry `SpawnComponentCodingSessions`

Note: This step's handle_result validates all child ComponentCodingSession records are complete, implementation files exist, and unit tests pass before returning :ok. This is the validation loop that replaces a separate ValidateComponentImplementations step.

**Finalize Step**
- `:ok` status → return `{:error, :session_complete}`
- Any other status → retry `Finalize`

**Invalid State Handling**
- Unknown module → return `{:error, :invalid_interaction}`
- Unexpected (status, module) combination → return `{:error, :invalid_state}`

### Completion Detection

**Session-Level Completion**
- Extract most recent interaction from session
- Delegate to interaction-level completion check

**Interaction-Level Completion**
- Session is complete when: `module == Steps.Finalize AND status == :ok`
- All other interaction states → session not complete

### Validation Loop Behavior

The orchestrator implements retry-until-success validation loops through handle_result:

**SpawnComponentCodingSessions Validation Loop**
- handle_result validates all child ComponentCodingSession records completed successfully
- Verifies all implementation files exist on filesystem
- Verifies all unit tests pass
- On `:error`: Orchestrator returns `SpawnComponentCodingSessions` to retry
- Allows time for human intervention to fix failed child sessions or test failures
- Breaks loop when handle_result returns `:ok` status to proceed to finalization

This loop provides a natural pause point for human oversight and intervention. The client monitors child sessions until all reach terminal state (:complete, :failed, :cancelled), then calls handle_result on the parent session. If validation fails, the orchestrator loops back to SpawnComponentCodingSessions, and the client can restart failed child sessions or fix issues before retrying.

### Child Session Coordination

The workflow delegates component implementation to child sessions:

1. **SpawnComponentCodingSessions** returns command with `child_session_ids` array in metadata
2. Client starts all child ComponentCodingSession sessions in parallel (autonomous execution)
3. Client monitors child sessions until all reach terminal state (:complete, :failed, :cancelled)
4. Client calls handle_result on parent session when all children are done
5. Parent session's handle_result validates all children completed successfully
6. If validation fails → orchestrator loops back to SpawnComponentCodingSessions for retry
7. If validation passes → orchestrator proceeds to Finalize

This coordination pattern enables parallel component implementation while maintaining parent-level validation and retry capability.

## Test Assertions

- describe "steps/0"
  - test "returns list of all step modules in correct order"
  - test "includes Initialize, SpawnComponentCodingSessions, and Finalize"
  - test "steps are ordered from first to last"

- describe "get_next_interaction/1 with no completed interactions"
  - test "returns Initialize step when session has no interactions"
  - test "returns Initialize step when session has only pending interaction"

- describe "get_next_interaction/1 from Initialize step"
  - test "returns SpawnComponentCodingSessions when Initialize completes successfully"
  - test "retries Initialize when Initialize fails"
  - test "retries Initialize when Initialize has unexpected status"

- describe "get_next_interaction/1 from SpawnComponentCodingSessions step"
  - test "returns Finalize when SpawnComponentCodingSessions completes successfully"
  - test "loops back to SpawnComponentCodingSessions when validation fails with error status"
  - test "retries SpawnComponentCodingSessions when step has unexpected status"

- describe "get_next_interaction/1 from Finalize step"
  - test "returns session_complete error when Finalize completes successfully"
  - test "retries Finalize when Finalize fails"
  - test "retries Finalize when Finalize has unexpected status"

- describe "get_next_interaction/1 with invalid interactions"
  - test "returns invalid_interaction error when module is not in steps list"
  - test "returns invalid_state error when status/module combination is unexpected"

- describe "complete?/1 with Session"
  - test "returns true when last interaction is Finalize with ok status"
  - test "returns false when last interaction is Finalize with error status"
  - test "returns false when last interaction is not Finalize"
  - test "returns false when session has no interactions"

- describe "complete?/1 with Interaction"
  - test "returns true when interaction is Finalize with ok status"
  - test "returns false when interaction is Finalize with error status"
  - test "returns false when interaction is not Finalize step"
  - test "returns false when interaction is any non-terminal step"
