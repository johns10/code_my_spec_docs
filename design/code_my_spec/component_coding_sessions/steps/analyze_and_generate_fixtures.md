# AnalyzeAndGenerateFixtures

## Purpose

Delegates to an AI agent to analyze existing fixtures in test/support/fixtures/, identify which ones are useful for testing the component, and generate any new fixtures that are needed. The agent autonomously explores fixture files, determines what's reusable, and creates missing fixtures following project conventions.

## Public API

```elixir
@spec get_command(Scope.t(), Session.t()) :: {:ok, Command.t()} | {:error, String.t()}
@spec handle_result(Scope.t(), Session.t(), Result.t()) :: {:ok, map(), Result.t()} | {:error, String.t()}
```

## Execution Flow

### get_command/2

1. **Read Component Design**: Extract component design document from session state (stored by previous ReadComponentDesign step)
2. **Load Fixture Rules**: Query Rules context for fixture-specific coding rules
3. **Compose Agent Prompt**: Build prompt instructing agent to:
   - Investigate all fixtures in test/support/fixtures/
   - Identify which existing fixtures are useful for this component
   - Read those useful fixture files
   - Determine what new fixtures are needed based on component design
   - Generate new fixture files following observed patterns
4. **Return Command**: Create and return Command struct with agent invocation

### handle_result/3

1. **Extract Agent Output**: Get fixture generation results from Result struct
2. **Update Session State**: Store fixture file paths and generation outcome in session state for use by subsequent GenerateTests step
3. **Return Updates**: Return session updates map and updated Result

## Dependencies

- Sessions
- Agents
- Rules

## Error Handling

- Missing component design in session state → return error tuple
- No existing fixtures found → proceed with generic fixture patterns
- Agent invocation failures → return error with agent context
- File system errors during analysis → return error with file context
