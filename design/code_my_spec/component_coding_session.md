# ComponentCodingSession

## Purpose
Manages the multi-step workflow for implementing Phoenix context components through AI-assisted test-driven development, including fixture generation, test writing, implementation, and iterative test failure resolution.

## Entity Ownership

This context owns no entities.

## Access Patterns
- All operations scoped by account_id through the Scope struct
- Session data filtered by project_id to ensure project-specific component implementation
- Test results and failure analysis scoped to session context

## Public API
```elixir
# Session workflow delegation
@spec get_next_interaction(step_module_atom) :: {:ok, module()} | {:error, :session_complete | :invalid_interaction}
@spec steps() :: [module()]
```

## State Management Strategy
### Stateless Orchestration with Test-Driven Iteration
- All workflow state persisted through Sessions context
- Component implementation state maintained in Session.state field
- Workflow progress tracked via embedded Interactions in Session records
- Test failure results stored in interaction results to drive fix decisions
- Test failure iteration count tracked to prevent infinite loops
- Component design document loaded at initialization and referenced throughout workflow

## Components
### ComponentCodingSessions.Orchestrator

| field | value |
| ----- | ----- |
| type  | other |

Stateless orchestrator managing the sequence of component implementation steps, determining workflow progression based on completed interactions. Handles test failure loops by returning to FixTestFailures when tests fail.

### ComponentCodingSessions.Steps.Initialize

| field | value |
| ----- | ----- |
| type  | other |

Prepares the development environment and workspace for component implementation, reads component design documentation into session state, and sets up necessary directories and repository state.

### ComponentCodingSessions.Steps.ReadComponentDesign

| field | value |
| ----- | ----- |
| type  | other |

Reads the component design documentation and stores it in the session state. This design information will be included in subsequent prompts to ensure implementation follows the documented architecture.

### ComponentCodingSessions.Steps.AnalyzeAndGenerateFixtures

| field | value |
| ----- | ----- |
| type  | other |

Analyzes existing fixture patterns in test/support/fixtures/ and identifies common data structures needed for testing the component. Generates reusable fixtures following project conventions to prevent verbose inline test data setup.

### ComponentCodingSessions.Steps.GenerateTests

| field | value |
| ----- | ----- |
| type  | other |

Generates comprehensive test files for the component using AI agents, applying the component design document and test-specific coding rules. Creates test files that leverage generated fixtures and follow TDD principles by defining the component's contract before implementation.

### ComponentCodingSessions.Steps.GenerateImplementation

| field | value |
| ----- | ----- |
| type  | other |

Generates the component implementation code using AI agents, applying the component design document and relevant coding rules. Creates all necessary module files, schemas, and supporting code to satisfy the tests written in the previous step.

### ComponentCodingSessions.Steps.RunTestsAndAnalyze

| field | value |
| ----- | ----- |
| type  | other |

Executes the project's ExUnit test suite for the implemented component and analyzes the results. Captures test failures, errors, and stack traces, then determines if failures are component-related (triggering fix loops) or unrelated (proceeding to finalize with warnings).

### ComponentCodingSessions.Steps.FixTestFailures

| field | value |
| ----- | ----- |
| type  | other |

Revises component implementation or tests based on failure analysis, engaging AI agents to address specific test failures, compilation errors, and runtime issues through iterative conversation. Intelligently determines whether to fix implementation code or test code.

### ComponentCodingSessions.Steps.Finalize

| field | value |
| ----- | ----- |
| type  | other |

Completes the component coding session by updating component status metadata and persisting the final implementation state.

## Dependencies
- Sessions
- Tests
- Rules
- Agents
- Components

## Execution Flow
1. **Initialize Environment**: Set up workspace and repository state for component implementation
2. **Read Component Design**: Load component design documentation and store in session state for prompt inclusion
3. **Analyze and Generate Fixtures**: Examine existing fixture patterns and generate reusable test fixtures for the component
4. **Generate Tests**: Create comprehensive test files following TDD principles, defining the component's contract before implementation
5. **Generate Implementation**: Create component implementation code that satisfies the tests written in the previous step
6. **Run Tests and Analyze**: Execute ExUnit test suite and analyze results in a single step
   - If all tests pass → proceed to Finalize
   - If tests fail with component-related issues → proceed to Fix Test Failures with failure analysis
   - If tests fail with unrelated issues → proceed to Finalize with warnings
7. **Fix Test Failures**: Address test failures through iterative AI conversation
   - Intelligently determine whether to fix implementation or tests
   - Return to Run Tests and Analyze for re-evaluation
8. **Finalize Session**: Update component status and complete session