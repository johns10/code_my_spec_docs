# FixTestFailures Step

## Purpose
Passes test failures to the AI agent to fix. Extracts failure information from the previous interaction and instructs the agent to address the failures without analyzing or processing the results.

## Public API

```elixir
# Step behavior implementation
@spec get_command(Scope.t(), Session.t()) :: {:ok, Command.t()} | {:error, term()}
@spec handle_result(Scope.t(), Session.t(), Result.t()) :: {:ok, map(), Result.t()}
```

## Execution Flow

### 1. Command Generation (get_command/2)
1. **Extract Failure Message**: Pull test_results from session state
3. **Create AI Agent**: Initialize component-designer agent with "component-code-reviser" profile using `:claude_code` provider
4. **Build Prompt**: Simple prompt stating tests failed and including failure output
5. **Build Command**: Generate AI agent command with `continue: true` flag
6. **Return Command**: Package as `Command.new/3` with module, command string, and prompt

### 2. Result Processing (handle_result/3)
1. **Return Result**: Pass through the result without state updates or analysis
2. **No State Changes**: Session state remains unchanged

## Error Handling
- **No Test Failures Found**: Returns `{:error, "no test failures found in previous interactions"}` if no failed interactions exist
- **Missing Failure Data**: Returns `{:error, "test failures not accessible"}` if error_message cannot be retrieved
- **Agent Creation Failure**: Returns error if AI agent cannot be initialized