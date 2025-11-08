# ContextCodingSessions

## Purpose
Orchestrates the implementation of all components within a Phoenix context by spawning ComponentCodingSessions for each component, validating their completion, and finalizing the implementation. Provides coordination-level workflow management that ensures all components are implemented and their unit tests pass before committing to a git branch.

## Entity Ownership

This context owns no entities.

## Access Patterns
- All operations scoped by account_id through the Scope struct
- Session data filtered by project_id to ensure project-specific context implementation
- Child sessions inherit parent scope for secure multi-session orchestration

## Public API
```elixir
# Session workflow delegation
@spec get_next_interaction(step_module_atom) :: {:ok, module()} | {:error, :session_complete | :invalid_interaction}
@spec steps() :: [module()]
```

## State Management Strategy
### Stateless Orchestration with Child Session Coordination
- All workflow state persisted through Sessions context
- Workflow progress tracked via embedded Interactions in Session records
- Child session IDs stored in command metadata
- Session parent-child relationships enforced through session_id foreign key
- Branch name stored in session state for git operations

## Components
### ContextCodingSessions.Orchestrator

| field | value |
| ----- | ----- |
| type  | other |

Stateless orchestrator managing the sequence of context implementation steps, determining workflow progression based on completed interactions. Handles child session spawning and validation loops for component implementation completion.

### ContextCodingSessions.Steps.Initialize

| field | value |
| ----- | ----- |
| type  | other |

Prepares the development environment by creating a git branch.

### ContextCodingSessions.Steps.SpawnComponentCodingSessions

| field | value |
| ----- | ----- |
| type  | other |

Fetches child components. Creates child ComponentCodingSession records for each component in the context with execution_mode set to :agentic. Returns a command with metadata containing child_session_ids array for the client to start all sessions in parallel.

### ContextCodingSessions.Steps.Finalize

| field | value |
| ----- | ----- |
| type  | other |

Completes the context coding session by committing all implementation code.

## Dependencies
- Sessions
- Components
- Environments
- Utils

## Execution Flow
1. **Initialize**: Create git branch
2. **Spawn Component Coding Sessions**: Query child components, create child ComponentCodingSession records (agentic mode), return command with child_session_ids
   - Client starts all child sessions in parallel (autonomous execution)
   - Client monitors child sessions until all reach terminal state (:complete, :failed, :cancelled)
   - Client calls handle_result on parent session when all children are done
3. **Validate Component Implementations** (performed in SpawnComponentCodingSessions.handle_result/4):
   - Load parent session with preloaded child sessions
   - Verify all child ComponentCodingSession records completed successfully
   - Verify implementation files exist for all components
   - Verify unit tests pass for all components
   - If validation fails → return :error, orchestrator loops back to SpawnComponentCodingSessions for retry
   - If validation passes → return :ok, orchestrator proceeds to Finalize
4. **Finalize**: Commit all implementation code, push to remote branch, and mark session complete