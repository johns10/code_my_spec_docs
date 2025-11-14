# ContextTestingSessions

## Purpose
Orchestrates the testing of all components within a Phoenix context by spawning ComponentTestingSessions for each component, validating their completion, and finalizing the testing workflow. Provides coordination-level workflow management that ensures all components have passing tests before marking the context testing session complete.

## Entity Ownership

This context owns no entities.

## Access Patterns
- All operations scoped by account_id through the Scope struct
- Session data filtered by project_id to ensure project-specific context testing
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
- Branch name computed on-demand from session component name (not stored in state)

## Components
### ContextTestingSessions.Orchestrator

| field | value |
| ----- | ----- |
| type  | other |

Stateless orchestrator managing the sequence of context testing steps, determining workflow progression based on completed interactions. Handles child session spawning and validation loops for component test completion.

### ContextTestingSessions.Utils

| field | value |
| ----- | ----- |
| type  | other |

Utility functions for ContextTestingSessions workflow, including branch name generation for git operations.

### ContextTestingSessions.Steps.Initialize

| field | value |
| ----- | ----- |
| type  | other |

Prepares the development environment by creating a git branch and setting up the working directory at the project root. Component data is queried on-demand by subsequent steps rather than stored in session state.

### ContextTestingSessions.Steps.SpawnComponentTestingSessions

| field | value |
| ----- | ----- |
| type  | other |

Queries the child components for the target context. Creates child ComponentTestingSession records for each component with execution_mode set to :agentic. Returns a command with metadata containing child_session_ids array for the client to start all sessions in parallel.

### ContextTestingSessions.Steps.Finalize

| field | value |
| ----- | ----- |
| type  | other |

Completes the context testing session by committing all test files, pushing to remote branch, and marking the session complete.

## Dependencies
- Sessions (session orchestration and persistence, child session creation)
- Environments (environment setup commands)
- CodeMySpec.Utils (component file paths)

## Execution Flow
1. **Initialize**: Create git branch and set up development environment
2. **Spawn Component Testing Sessions**: Query child components from database, create child ComponentTestingSession records (agentic mode), return command with child_session_ids
   - Client starts all child sessions in parallel (autonomous execution)
   - Client monitors child sessions until all reach terminal state (:complete, :failed, :cancelled)
   - Client calls handle_result on parent session when all children are done
3. **Validate Component Tests** (performed in SpawnComponentTestingSessions.handle_result/4):
   - Load parent session with preloaded child sessions
   - Verify all child ComponentTestingSession records completed successfully
   - Verify test files exist for all components
   - Verify tests pass for all components
   - If validation fails → return :error, orchestrator loops back to SpawnComponentTestingSessions for retry
   - If validation passes → return :ok, orchestrator proceeds to Finalize
4. **Finalize**: Commit all test files, push to remote branch, and mark session complete

## Test Strategies
### Fixtures
- **valid_context_component**: Factory for creating valid context component with design files
- **context_with_multiple_components**: Pre-built context with 3+ components for parallel testing
- **completed_component_test_session**: Factory for ComponentTestingSession with :complete status

### Mocks and Doubles
- Mock git operations (branch creation, commits, pushes) with simulated stdout/stderr
- Mock filesystem operations for test file creation
- Use database fixtures instead of mocking child session spawning

### Testing Approach
- Integration tests for complete workflow with real database operations
- Test validation loops by creating partial completion scenarios
- Verify retry behavior by simulating validation failures
- Test scope inheritance across parent and child sessions

## Test Assertions
- describe "context testing session workflow"
  - test "executes complete context testing workflow"
  - test "handles validation failure and retry for incomplete child sessions"
  - test "handles validation when all child sessions complete successfully"
  - test "handles validation failure when tests fail"
  - test "handles child session failures gracefully"
  - test "validates all components have corresponding child sessions"
  - test "generates branch name dynamically from component name"
  - test "child sessions inherit parent scope"
  - test "finalizes by committing and marking session complete"