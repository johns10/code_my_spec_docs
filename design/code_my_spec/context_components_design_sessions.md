# ContextComponentsDesignSessions

## Purpose
Orchestrates AI-driven workflows that generate design documentation for all components within a Phoenix context. Manages the lifecycle of context-wide component design sessions by spawning child component design sessions in agentic mode, coordinating a design review session, and finalizing with a pull request.

## Entity Ownership

This context owns no entities.

## Access Patterns
- All operations scoped by account_id through the Scope struct
- Session data filtered by project_id to ensure project-specific context design
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
- Review session ID stored in session state for validation
- Session parent-child relationships enforced through session_id foreign key

## Components
### ContextComponentsDesignSessions.Orchestrator

| field | value |
| ----- | ----- |
| type  | other |

Stateless orchestrator managing the sequence of context component design steps, determining workflow progression based on completed interactions. Handles child session spawning and validation loops.

### ContextComponentsDesignSessions.Steps.Initialize

| field | value |
| ----- | ----- |
| type  | other |

Prepares the development environment by creating a git branch and loading the list of components within the target context.

### ContextComponentsDesignSessions.Steps.SpawnComponentDesignSessions

| field | value |
| ----- | ----- |
| type  | other |

Creates child ComponentDesignSession records for each component in the context with execution_mode set to :agentic. Returns a command with metadata containing child_session_ids array for the client to start all sessions in parallel.

### ContextComponentsDesignSessions.Steps.SpawnReviewSession

| field | value |
| ----- | ----- |
| type  | other |

Creates a review session (agentic mode) that analyzes all generated component designs for consistency, missing dependencies, and integration issues. Returns command with review_session_id in metadata for client to start.

### ContextComponentsDesignSessions.Steps.Finalize

| field | value |
| ----- | ----- |
| type  | other |

Completes the context components design session by creating a pull request with all generated design documentation.

## Dependencies
- Sessions
- Components
- Rules
- Agents

## Execution Flow
1. **Initialize**: Create git branch for design documentation
2. **Spawn Component Design Sessions**: Query child components, create child ComponentDesignSession records (agentic mode), return command with child_session_ids
   - Client starts all child sessions in parallel (autonomous execution)
   - Client monitors child sessions until all reach terminal state (:complete, :failed, :cancelled)
   - Client calls handle_result on parent session when all children are done
   - **handle_result validates**: Load parent with children, check all complete, verify design files exist
   - If validation fails → return :error, orchestrator loops back to this step for retry
   - If validation passes → return :ok, orchestrator proceeds to review
3. **Spawn Review Session**: Load parent with children, create ComponentDesignReviewSession (agentic mode) with paths to all designs, return command with review_session_id
   - Client starts review session (autonomous execution)
   - Client monitors review session until terminal state
   - Client calls handle_result on parent session when review is done
   - **handle_result validates**: Load review session, check complete, verify review document exists
   - If validation fails → return :error, orchestrator loops back to this step for retry
   - If validation passes → return :ok, orchestrator proceeds to finalize
4. **Finalize**: Create pull request with all design documentation and mark session complete
