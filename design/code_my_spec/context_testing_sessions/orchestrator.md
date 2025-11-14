# Orchestrator

## Purpose

Stateless orchestrator managing the sequence of context testing steps, determining workflow progression based on completed interactions. Implements the OrchestratorBehaviour to coordinate child ComponentTestingSession spawning, validation loops, and finalization for comprehensive context-level test completion.

## Public API

```elixir
# OrchestratorBehaviour implementation
@spec steps() :: [module()]
@spec get_next_interaction(session :: Session.t()) ::
        {:ok, module()} | {:error, :session_complete | atom()}
@spec complete?(session_or_interaction :: Session.t() | Interaction.t()) :: boolean()
```

## Execution Flow

### Workflow State Machine

1. **Session Initialization**
   - If no interactions exist, return first step (Initialize)
   - Otherwise, find last completed interaction to determine current state

2. **Next Step Determination**
   - Extract result status from last completed interaction
   - Extract step module from last completed interaction command
   - Apply state machine rules to determine next step

3. **State Machine Rules**
   - **Initialize**:
     - Status `:ok` → Proceed to SpawnComponentTestingSessions
     - Any other status → Retry Initialize

   - **SpawnComponentTestingSessions**:
     - Status `:ok` → Validation passed, proceed to Finalize
     - Status `:error` → Validation failed, loop back to SpawnComponentTestingSessions
     - Any other status → Retry SpawnComponentTestingSessions

   - **Finalize**:
     - Status `:ok` → Return `{:error, :session_complete}` (workflow complete)
     - Any other status → Retry Finalize

4. **Completion Detection**
   - Session is complete when last interaction is Finalize step with `:ok` status
   - Can check either Session (uses last interaction) or specific Interaction

### Child Session Coordination

The orchestrator manages child ComponentTestingSession lifecycle through SpawnComponentTestingSessions step:

1. **Spawning Phase**: SpawnComponentTestingSessions.get_command/3 creates child sessions
2. **Monitoring Phase**: Client monitors child sessions until all reach terminal state
3. **Validation Phase**: SpawnComponentTestingSessions.handle_result/4 validates outcomes
4. **Loop Decision**:
   - All children `:complete` and tests pass → Return `:ok`, advance to Finalize
   - Any failures detected → Return `:error`, loop back to spawn new attempts

## Test Assertions

- describe "steps/0"
  - test "returns ordered list of step modules"
  - test "includes Initialize, SpawnComponentTestingSessions, and Finalize"

- describe "get_next_interaction/1"
  - test "returns Initialize when session has no interactions"
  - test "returns SpawnComponentTestingSessions after successful Initialize"
  - test "returns Finalize after successful SpawnComponentTestingSessions"
  - test "returns session_complete error after successful Finalize"
  - test "retries Initialize on Initialize failure"
  - test "loops back to SpawnComponentTestingSessions on validation failure"
  - test "retries Finalize on Finalize failure"
  - test "returns invalid_interaction error for unknown step module"
  - test "returns invalid_state error for unexpected status/module combination"

- describe "complete?/1 with Session"
  - test "returns true when last interaction is Finalize with :ok status"
  - test "returns false when last interaction is Initialize"
  - test "returns false when last interaction is SpawnComponentTestingSessions"
  - test "returns false when Finalize has non-ok status"
  - test "returns false when session has no interactions"

- describe "complete?/1 with Interaction"
  - test "returns true for Finalize interaction with :ok status"
  - test "returns false for Finalize interaction with :error status"
  - test "returns false for Initialize interaction"
  - test "returns false for SpawnComponentTestingSessions interaction"
  - test "returns false for any non-Finalize interaction"
