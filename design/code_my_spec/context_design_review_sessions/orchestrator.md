# Orchestrator

## Purpose

Stateless orchestrator managing the sequence of context design review steps. Implements the OrchestratorBehaviour to coordinate the execution flow between ExecuteReview and Finalize steps, determining the next interaction based on session state and handling session completion logic. All workflow state is persisted through the Sessions context via embedded Interactions in Session records.

## Public API

```elixir
# OrchestratorBehaviour callbacks
@spec steps() :: [module()]
@spec get_next_interaction(session :: Session.t()) :: {:ok, module()} | {:error, :session_complete | atom()}
@spec complete?(session_or_interaction :: Session.t() | Interaction.t()) :: boolean()
```

## Execution Flow

### steps/0

1. **Return Step Modules List**: Returns ordered list of step modules for the context review workflow
   - `[Steps.ExecuteReview, Steps.Finalize]`
   - Order matters: defines the sequence of execution

### get_next_interaction/1

1. **Find Last Completed Interaction**: Use `Utils.find_last_completed_interaction/1` to get the most recent completed interaction
   - Returns `nil` if no interactions exist or session is complete/failed
   - Returns `%Interaction{}` with completed result otherwise

2. **Handle No Interactions**: If no completed interaction exists
   - This is the start of the session workflow
   - Return `{:ok, Steps.ExecuteReview}` to begin with first step

3. **Extract Status and Module**: From the last completed interaction
   - Get `result.status` (`:ok` or `:error`)
   - Get `command.module` to determine which step just completed

4. **Determine Next Step**: Based on status and current module
   - **After ExecuteReview**:
     - If status is `:ok` → Return `{:ok, Steps.Finalize}`
     - If status is `:error` → Return `{:ok, Steps.ExecuteReview}` (retry)
   - **After Finalize**:
     - If status is `:ok` → Return `{:error, :session_complete}`
     - If status is `:error` → Return `{:error, :session_complete}` (failed but complete)
   - **Unknown Module**: If module is not in steps list
     - Return `{:error, :invalid_interaction}`

### complete?/1 (with Session)

1. **Extract Last Interaction**: Get the first interaction from session.interactions list
   - Interactions are ordered newest first
   - If no interactions exist, session is not complete

2. **Delegate to complete?/1 (with Interaction)**: Call overloaded function with the last interaction

### complete?/1 (with Interaction)

1. **Check Finalize Completion**: Determine if interaction represents workflow completion
   - Check if `command.module` is `Steps.Finalize`
   - Check if `result.status` is `:ok`
   - Both conditions must be true for completion

2. **Return Completion Status**:
   - Return `true` if Finalize step completed successfully
   - Return `false` for all other cases (including failed Finalize)
   - Note: Failed Finalize still ends the session (via `get_next_interaction/1`), but `complete?/1` returns false for status tracking

## Error Handling

- **Invalid State**: If current module/status combination is unexpected
  - Return `{:error, :invalid_state}` from `get_next_interaction/1`
  - Prevents session from progressing with corrupted state

- **Session Already Complete**: If session status is `:complete` or `:failed`
  - `Utils.find_last_completed_interaction/1` returns `nil`
  - `get_next_interaction/1` will start from beginning, but orchestrator will be blocked by session status validation elsewhere

- **No Interactions**: If session has no interactions
  - Return first step (ExecuteReview) to begin workflow
  - Normal initialization case

## Dependencies

- Sessions.OrchestratorBehaviour (behaviour implementation)
- Sessions.Session (session struct)
- Sessions.Interaction (interaction struct)
- Sessions.Result (result struct)
- Sessions.Utils (utility functions for finding completed interactions)
- ContextDesignReviewSessions.Steps.ExecuteReview (step module)
- ContextDesignReviewSessions.Steps.Finalize (step module)

## Notes

- The orchestrator is completely stateless - it makes decisions purely based on the current session state
- Step retry logic: ExecuteReview retries on error, but Finalize ends session regardless of status
- Session completion: Only successful Finalize returns true from `complete?/1`, but both success and failure return `:session_complete` from `get_next_interaction/1`
- The orchestrator does not handle state transitions - that responsibility belongs to SessionsRepository and ResultHandler
- Step modules are referenced via the `Steps` alias which maps to `CodeMySpec.ContextDesignReviewSessions.Steps`
- The workflow is linear with conditional retry: ExecuteReview → (retry on error OR proceed to) Finalize → Complete
