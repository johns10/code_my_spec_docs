# CLI Adapter Behavior Design

## Purpose
Defines a contract for executing Claude CLI commands with streaming support, enabling dependency injection for testing while maintaining a clean interface for production use.

## Interface

```elixir
defmodule CodeMySpec.Agents.ClaudeCode.CLIAdapterBehaviour do
  @moduledoc """
  Behavior for Claude CLI command execution implementations.
  """

  @callback run(command :: [String.t()], stream_handler :: (String.t() -> :ok)) :: 
    {:ok, :completed} | {:error, reason :: atom(), details :: any()}
end
```

## Implementation Contract

### Input
- `command` - List of CLI arguments (e.g., `["claude", "--print", "Hello"]`)
- `stream_handler` - Function called with each line of output as it arrives

### Output
- `{:ok, :completed}` - Command completed successfully
- `{:error, reason, details}` - Execution failure with categorized reason

### Responsibilities
- Execute CLI command with provided arguments
- Stream stdout output line-by-line to provided handler
- Call `stream_handler.(line)` for each complete line
- Return appropriate error tuples for different failure modes
- Handle process lifecycle (start, monitor, cleanup)

### Stream Handler Contract
- **Input**: Raw line from CLI stdout as `String.t()`
- **Expected return**: `:ok` (return value ignored)
- **Timing**: Called immediately as lines become available
- **Error handling**: Handler should not raise exceptions

## Error Categories
- `:command_not_found` - CLI binary not available
- `:authentication_error` - API key/auth issues  
- `:invalid_args` - Malformed command arguments
- `:process_failed` - Other execution failures

## Usage Patterns

### Production
```elixir
adapter = CodeMySpec.Agents.ClaudeCode.CLIAdapter

stream_handler = fn line -> 
  IO.puts("Received: #{line}")
end

{:ok, :completed} = adapter.run(["claude", "--print", "Hello"], stream_handler)
```

### Testing
```elixir
# Dependency injection via config
adapter = Application.get_env(:app, :cli_adapter)
{:ok, :completed} = adapter.run(command, stream_handler)
```

## Design Principles
- **Streaming interface** - Real-time output processing
- **Simple contract** - Single function, clear streaming behavior
- **Error transparency** - Categorized failures without complex formatting
- **Test enablement** - Behavior allows mock implementations
- **Raw output** - No parsing or transformation at this layer