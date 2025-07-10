# CLI Adapter Design

## Purpose
Production implementation of CLIAdapterBehaviour that executes Claude CLI commands and streams output line-by-line to a handler function.

## Core Responsibilities
- Execute Claude CLI commands via system process
- Stream stdout output line-by-line to provided handler
- Map process exit codes to categorized error reasons
- Handle system-level execution failures

## Interface

```elixir
@callback run(command :: [String.t()], stream_handler :: (String.t() -> :ok)) :: 
  {:ok, :completed} | {:error, reason :: atom(), details :: any()}
```

## Implementation Strategy

### Streaming Process Execution
```elixir
def run(command, stream_handler) do
  case System.cmd(List.first(command), List.rest(command), [
    stderr_to_stdout: true,
    env: [{"CLAUDE_CODE_ENTRYPOINT", "sdk-py"}],
    into: stream_processor(stream_handler)
  ]) do
    {_output, 0} -> {:ok, :completed}
    {error, code} -> map_exit_code_to_error(code, error)
  end
rescue
  # Handle system-level exceptions
end

defp stream_processor(stream_handler) do
  IO.stream(:stdio, :line)
  |> Stream.each(stream_handler)
end
```

### Exit Code Mapping
- `0` → `{:ok, :completed}`
- `1` → `{:error, :invalid_args, stderr}`
- `2` → `{:error, :authentication_error, stderr}`
- `126` → `{:error, :permission_denied, stderr}`
- `127` → `{:error, :command_not_found, stderr}`
- `other` → `{:error, :process_failed, {code, stderr}}`

### Exception Handling
- `:enoent` → `{:error, :command_not_found, "Binary not found"}`
- `:eacces` → `{:error, :permission_denied, "Permission denied"}`
- `other` → `{:error, :system_error, exception_details}`

## Error Strategy
- **Categorize don't format** - Return structured error tuples
- **Preserve details** - Include stderr/exception info in details field
- **No recovery attempts** - Single execution attempt per call
- **System transparency** - Map OS-level errors directly

## Configuration
- Uses standard Claude CLI environment variables
- No internal configuration or state
- Stateless execution model

## Design Constraints
- **No output parsing** - Returns raw stdout string
- **No retry logic** - Single attempt execution
- **No logging** - Let caller handle logging/monitoring
- **No caching** - Each call is independent execution

## Dependencies
- Elixir's `System.cmd/3` for process execution
- Standard library exception handling
- No external dependencies

## Testing Integration
- Implements CLIAdapterBehaviour for test substitution
- Can be swapped via dependency injection
- No testing utilities in production module