# CodeMySpec.Sessions.AgentTasks.ComponentCode

**Type**: module

Agent task module for component implementation sessions with Claude Code. Provides two entry points: `command/3` generates the implementation prompt with spec location, test file, similar components for patterns, and coding rules; `evaluate/3` runs tests after Claude implements the component and returns feedback for fixing failures.

## Functions

### command/3

Generate the implementation prompt for Claude to code a component.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract component and project from session map
2. Get implementation rules matching component type and "code" session type via Rules.find_matching_rules/2
3. Fetch similar components via Components.list_similar_components/2 for pattern reference
4. Build implementation prompt with:
   - Project name and description
   - Component name, description, and type
   - Spec file path (from Utils.component_files/2)
   - Test file path for behavior expectations
   - Similar components formatted with their spec/code/test paths
   - Coding rules content
   - Target code file path for implementation
5. Return {:ok, prompt_text}

**Test Assertions**:
- returns ok tuple with prompt string
- includes spec file path in prompt
- includes test file path in prompt
- includes component name and type in prompt
- includes project name and description in prompt
- includes coding rules from matching rules
- includes similar components with file paths when available
- handles empty similar components list with fallback text
- handles component with no description

### evaluate/3

Evaluate Claude's implementation by running tests and providing feedback.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract component and project from session map
2. Get code_file and test_file paths via Utils.component_files/2
3. Check required files exist using Environments.file_exists?/2:
   - If missing, return {:ok, :invalid, feedback} listing missing files
4. Run tests via Tests.execute/2 with ExUnitJsonFormatter
5. Parse test results:
   - If 0 failures, return {:ok, :valid}
   - If failures > 0, return {:ok, :invalid, failure_feedback}
   - If parse error (compile error), return {:ok, :invalid, execution_error_feedback}

**Test Assertions**:
- returns {:ok, :valid} when all tests pass
- returns {:ok, :invalid, feedback} when tests fail with failure details
- returns {:ok, :invalid, feedback} when code file missing
- returns {:ok, :invalid, feedback} when test file missing
- returns {:ok, :invalid, feedback} when both files missing
- returns {:ok, :invalid, feedback} on compile error with raw output
- feedback includes test failure count and total test count
- feedback includes failure titles and error messages
- creates environment from session.environment for file checks

## Dependencies

- CodeMySpec.Rules
- CodeMySpec.Utils
- CodeMySpec.Components
- CodeMySpec.Tests
- CodeMySpec.Environments