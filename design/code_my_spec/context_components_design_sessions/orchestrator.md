# Orchestrator

## Purpose

Stateless orchestrator managing the sequence of context component design steps, determining workflow progression based on completed interactions. Implements the OrchestratorBehaviour to coordinate multi-step workflows including child session spawning, validation loops, and pull request creation. All workflow state persists through the Sessions context with no in-memory state maintained by the orchestrator.

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

The workflow consists of 4 steps with validation performed in each step's handle_result:

**Initialize Step**
- `:ok` status → proceed to `SpawnComponentDesignSessions`
- Any other status → retry `Initialize`

**SpawnComponentDesignSessions Step**
- `:ok` status → proceed to `SpawnReviewSession`
- `:error` status → loop back to `SpawnComponentDesignSessions` (validation failed in handle_result)
- Any other status → retry `SpawnComponentDesignSessions`

Note: This step's handle_result validates all child sessions are complete and files exist before returning :ok

**SpawnReviewSession Step**
- `:ok` status → proceed to `Finalize`
- `:error` status → loop back to `SpawnReviewSession` (validation failed in handle_result)
- Any other status → retry `SpawnReviewSession`

Note: This step's handle_result validates review session is complete and document exists before returning :ok

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

1. **SpawnComponentDesignSessions Validation Loop**
   - handle_result validates all child sessions are complete and files exist
   - On `:error`: Orchestrator returns `SpawnComponentDesignSessions` to retry
   - Allows time for human intervention to fix failed sessions or missing files
   - Breaks loop when handle_result returns `:ok` status to proceed to review

2. **SpawnReviewSession Validation Loop**
   - handle_result validates review session is complete and document exists
   - On `:error`: Orchestrator returns `SpawnReviewSession` to retry
   - Enables manual corrections or review session restarts
   - Breaks loop when handle_result returns `:ok` status to proceed to finalization

These loops provide natural pause points for human oversight and intervention. Validation logic lives in each step's handle_result rather than in separate validation steps.
