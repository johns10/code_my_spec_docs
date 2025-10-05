# ComponentTestSessions

## Purpose
Manages the multi-step workflow for generating tests and fixtures for individual Phoenix context components through AI-assisted generation, without running tests or fixing failures.

## Entity Ownership

This context owns no entities.

## Access Patterns
- All operations scoped by account_id through the Scope struct
- Session data filtered by project_id to ensure project-specific test generation

## Public API
```elixir
# Session workflow delegation
@spec get_next_interaction(step_module_atom) :: {:ok, module()} | {:error, :session_complete | :invalid_interaction}
@spec steps() :: [module()]
```

## State Management Strategy
### Stateless Orchestration
- All workflow state persisted through Sessions context
- Workflow progress tracked via embedded Interactions in Session records

## Components
### ComponentTestSessions.Orchestrator

| field | value |
| ----- | ----- |
| type  | other |

Stateless orchestrator managing the sequence of test generation steps, determining workflow progression based on completed interactions.

### ComponentTestSessions.Steps.Initialize

| field | value |
| ----- | ----- |
| type  | other |

Prepares the development environment and workspace for test generation, setting up necessary directories and repository state.

### ComponentTestSessions.Steps.GenerateTestsAndFixtures

| field | value |
| ----- | ----- |
| type  | other |

Generates comprehensive test and fixture files using AI agents. Provides paths to parent context design file and component design file so the agent can read them directly. Applies test and fixture rules specific to component testing patterns and best practices.

### ComponentTestSessions.Steps.RunTests

| field | value |
| ----- | ----- |
| type  | other |

Executes the generated tests to identify compilation errors and test failures. Captures error output and test results for analysis in the next step.

### ComponentTestSessions.Steps.FixCompilationErrors

| field | value |
| ----- | ----- |
| type  | other |

Analyzes compilation errors and test failures from the previous step and uses AI agents to fix issues. Provides paths to design files, test files, and error output to enable targeted fixes. May iterate multiple times until tests compile and pass.

### ComponentTestSessions.Steps.Finalize

| field | value |
| ----- | ----- |
| type  | other |

Completes the test generation session by committing the test and fixture files to the repository after all tests pass successfully.

## Dependencies
- Sessions
- Rules
- Agents
- Components

## Execution Flow
1. **Initialize Environment**: Set up workspace and repository state for test generation
2. **Generate Tests and Fixtures**: Create comprehensive test and fixture files using AI agents, providing paths to design files
3. **Finalize Session**: Commit tests and fixtures to repository without running them
