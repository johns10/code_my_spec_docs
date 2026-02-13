# CodeMySpec.AgentTasks.ComponentTest

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils

## Functions

### command/3

Generate the command prompt for Claude to write component tests.

```elixir
@spec command(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract component from session
2. Get test rules for component type using Rules.find_matching_rules/2
3. List similar components for pattern inspiration using Components.list_similar_components/2
4. Build test prompt with spec file location, test rules, similar components, and TDD context
5. Return prompt text

**Test Assertions**:
- returns prompt with component information
- includes test rules in prompt
- includes similar components when available
- indicates TDD mode when implementation doesn't exist
- indicates validation mode when implementation exists
- includes spec file path and test file path

### evaluate/3

Evaluate Claude's output by checking test requirements and querying persisted problems.

```elixir
@spec evaluate(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract component and project from session
2. Reload component from database via ComponentRepository.get_component/2
3. Check test artifact requirements via Requirements.check_requirements/4 with artifact_types: [:tests]
4. Build requirement feedback from unsatisfied requirements (nil if all pass)
5. Check problems via ProblemFeedback.for_test_task/3 (queries test file problems, filters out test failures)
6. Combine requirement feedback and problem feedback via ProblemFeedback.combine/2

**Test Assertions**:
- returns {:ok, :valid} when all test requirements are satisfied and no blocking problems exist
- returns {:ok, :invalid, feedback} when test file does not exist
- returns {:ok, :invalid, feedback} when test spec alignment fails
- returns {:ok, :invalid, feedback} when compilation errors exist in test file
- returns {:ok, :valid} even when test failures exist (TDD mode — test failures are filtered out)
- returns {:ok, :invalid, feedback} combining requirement and problem feedback when both fail
- includes unsatisfied requirement details in feedback
- includes problem details in feedback for non-test problems
- reloads component from database before checking requirements
