## Dependencies

- CodeMySpec.Rules
- CodeMySpec.Utils
- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Environments
- CodeMySpec.Quality
- CodeMySpec.Tests
- CodeMySpec.Compile

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

Evaluate Claude's output by running tests and checking quality.

```elixir
@spec evaluate(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract component and project from session
2. Get component file paths using Utils.component_files/2
3. Check if test file exists, return invalid with error if missing
4. Check if implementation exists to determine TDD mode
5. Check compilation using Compile.execute/0
6. If compilation fails, return invalid with formatted compilation errors
7. If compilation passes, run quality checks including test execution, TDD state validation, and spec alignment
8. Validate quality scores against required thresholds (alignment >= 0.9, overall >= 0.95)
9. Return valid if all checks pass, otherwise return invalid with formatted errors

**Test Assertions**:
- returns invalid when test file doesn't exist
- returns invalid when compilation fails
- runs tests when compilation passes
- checks TDD state when in TDD mode (no implementation)
- checks spec alignment against test assertions
- returns valid when all quality checks pass
- returns invalid with errors when quality checks fail
- requires alignment score of at least 0.9
- requires overall score of at least 0.95
