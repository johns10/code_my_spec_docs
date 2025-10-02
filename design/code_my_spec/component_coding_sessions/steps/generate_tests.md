# GenerateTests

## Purpose

Delegates to an AI agent to generate comprehensive test files for the component. The agent autonomously explores existing fixtures in test/support/fixtures/, generates any new fixtures needed, then writes test files that leverage those fixtures and follow TDD principles to define the component's contract before implementation.

## Public API

```elixir
@spec get_command(Scope.t(), Session.t()) :: {:ok, Command.t()} | {:error, String.t()}
@spec handle_result(Scope.t(), Session.t(), Result.t()) :: {:ok, map(), Result.t()} | {:error, String.t()}
```

## Execution Flow

### get_command/2

1. **Read Component Design**: Extract component design document from session state (stored by previous ReadComponentDesign step)
2. **Load Test Rules**: Query Rules context for test-specific coding rules
3. **Compose Agent Prompt**: Build prompt instructing agent to:
   - Investigate all fixtures in test/support/fixtures/
   - Identify which existing fixtures are useful for this component
   - Read those useful fixture files
   - Determine what new fixtures are needed based on component design
   - Generate new fixture files following observed patterns
   - Write comprehensive test files that leverage the fixtures
   - Follow TDD principles to define the component's contract
   - Cover all public API functions specified in the component design
   - Include path of test file
4. **Return Command**: Create and return Command struct with agent invocation

### handle_result/3

1. **Extract Agent Output**: Get test generation results from Result struct
2. **Update Session State**: Store test file paths and generation outcome in session state for use by subsequent steps
3. **Return Updates**: Return session updates map and updated Result

## Dependencies

- Sessions
- Agents
- Rules

## Error Handling

- Missing component design in session state → return error tuple
- Agent invocation failures → return error with agent context
- File system errors during test generation → return error with file context