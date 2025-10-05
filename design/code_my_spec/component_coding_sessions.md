# ComponentCodingSessions

## Purpose
Manages the multi-step workflow for implementing Phoenix context components through AI-assisted code generation, including implementation generation, validation, and iterative revision.

## Entity Ownership

This context owns no entities.

## Access Patterns
- All operations scoped by account_id through the Scope struct
- Session data filtered by project_id to ensure project-specific component implementation

## Public API
```elixir
# Session workflow delegation
@spec get_next_interaction(step_module_atom) :: {:ok, module()} | {:error, :session_complete | :invalid_interaction}
@spec steps() :: [module()]
```

## State Management Strategy
### Stateless Orchestration with Test Failure Loops
- All workflow state persisted through Sessions context
- Workflow progress tracked via embedded Interactions in Session records
- Test failure feedback stored in interaction results to drive fix decisions
- Iteration count tracked to prevent infinite loops

## Components
### ComponentCodingSessions.Orchestrator

| field | value |
| ----- | ----- |
| type  | other |

Stateless orchestrator managing the sequence of component implementation steps, determining workflow progression based on completed interactions. Handles test failure loops by cycling between RunTests and FixTestFailures.

### ComponentCodingSessions.Steps.Initialize

| field | value |
| ----- | ----- |
| type  | other |

Prepares the development environment and workspace for component implementation, setting up necessary directories and repository state.

### ComponentCodingSessions.Steps.GenerateImplementation

| field | value |
| ----- | ----- |
| type  | other |

Generates the component implementation code using AI agents. Provides paths to design file and test file so the agent can read them directly. Creates all necessary module files, schemas, and supporting code.

### ComponentCodingSessions.Steps.RunTests

| field | value |
| ----- | ----- |
| type  | other |

Executes the ExUnit test suite for the component and analyzes results. Captures test failures and determines next steps based on test outcomes.

### ComponentCodingSessions.Steps.FixTestFailures

| field | value |
| ----- | ----- |
| type  | other |

Addresses test failures through iterative AI conversation, fixing implementation or tests based on failure analysis.

### ComponentCodingSessions.Steps.Finalize

| field | value |
| ----- | ----- |
| type  | other |

Completes the component coding session by committing the implementation and updating component metadata.

## Dependencies
- Sessions
- Tests
- Rules
- Agents
- Components

## Execution Flow
1. **Initialize Environment**: Set up workspace and repository state for component implementation
2. **Generate Implementation**: Create component implementation code using AI agents, providing paths to design and test files
3. **Run Tests**: Execute ExUnit test suite and analyze results
   - If all tests pass → proceed to Finalize
   - If tests fail → proceed to Fix Test Failures
4. **Fix Test Failures**: Address test failures through iterative AI conversation
   - Fix implementation or tests based on failure analysis
   - Return to Run Tests for re-evaluation
5. **Finalize Session**: Commit implementation and complete session