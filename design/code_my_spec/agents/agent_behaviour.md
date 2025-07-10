# AgentBehaviour

## Purpose
Defines the contract that all agent implementations must fulfill, ensuring consistent interface and behavior across different execution backends (Claude Code, OpenHands, custom agents, etc.). This behavior is for **implementations**, not agent types.

## Behavior Contract

```elixir
@doc """
Execute an agent with the given prompt and configuration.
Streams output chunks to the provided handler function.
"""
@callback execute(Agent.t(), prompt(), stream_handler()) :: 
  {:ok, execution_result()} | {:error, execution_error()}

@doc """
Validate agent-specific configuration before agent creation.
Returns validated config or list of validation errors.
"""
@callback validate_config(config()) :: 
  {:ok, config()} | {:error, [validation_error()]}

# Type definitions
@type prompt() :: String.t()
@type stream_handler() :: (any() -> :ok)
@type config() :: map()
@type execution_result() :: map()
@type execution_error() :: atom()
@type validation_error() :: String.t()
```

## Callback Specifications

### `execute/3`
**Purpose**: Execute the agent with a prompt and stream results to handler

**Parameters**:
- `agent` - Agent struct containing type, config, and metadata
- `prompt` - String prompt to send to the agent
- `stream_handler` - Function that receives output chunks as they arrive

**Return Values**:
- `{:ok, execution_result}` - Successful execution with final output and metadata
- `{:error, execution_error}` - Execution failed with error reason

**Streaming Behavior**:
- Must call `stream_handler` with meaningful output chunks as they arrive
- What constitutes a "chunk" is implementation-specific (could be complete messages, partial text, JSON objects, etc.)
- Handler calls should be non-blocking and not fail execution if handler errors
- Final output should also be returned in execution_result for completeness

**Session Management**:
- Agents may optionally support sessions and return session identifiers
- Session handling is entirely agent-specific
- Agents without session support can omit session-related fields from results

### `validate_config/1`
**Purpose**: Validate implementation-specific configuration before agent execution

**Parameters**:
- `config` - Map containing agent configuration parameters

**Return Values**:
- `{:ok, validated_config}` - Configuration is valid, optionally with normalized values
- `{:error, [error_messages]}` - List of validation error messages

**Validation Responsibilities**:
- Check implementation-specific required fields
- Validate field types and formats appropriate to the implementation
- Check for implementation-specific conflicting options
- Verify implementation-specific external dependencies
- Apply implementation-specific defaults

## Implementation Requirements

### Error Handling
- Must handle and categorize common error types:
  - `:config_invalid` - Configuration validation failed
  - `:agent_unavailable` - Agent binary/service not available
  - `:execution_failed` - Agent execution failed
  - `:timeout` - Agent execution timed out
  - `:authentication_failed` - API key or auth issues

### Stream Handler Integration
- Call stream handler frequently during execution
- Handle stream handler failures gracefully (log but continue)
- Provide meaningful chunks (not character-by-character)
- Include relevant metadata in stream when available

### Configuration Standards
Each agent implementation defines its own configuration schema and requirements. There are no mandated configuration fields - agents should document their specific configuration needs.

### Session Management Standards
Session management is entirely optional and implementation-specific:
- Implementations may support session resumption through their configuration
- Session identifiers and resume mechanisms are defined per implementation
- Implementations without session support simply don't include session-related fields in results

## Implementation Examples

### Basic Implementation Pattern
```elixir
defmodule MyAgentImplementation do
  @behaviour AgentBehaviour
  
  @impl true
  def execute(agent, prompt, stream_handler) do
    with {:ok, validated_config} <- validate_config(agent.config),
         {:ok, result} <- do_execution(prompt, validated_config, stream_handler) do
      {:ok, result}
    else
      {:error, reason} -> {:error, reason}
    end
  end
  
  @impl true
  def validate_config(config) do
    # Implementation-specific validation logic
  end
  
  defp do_execution(prompt, config, stream_handler) do
    # Implementation-specific execution
    # Call stream_handler.(output) as results arrive
  end
end
```

### Stream Handler Usage
```elixir
# In execute/3 implementation - streaming whatever chunks are appropriate for the implementation
def handle_output_chunk(chunk, stream_handler) do
  try do
    stream_handler.(chunk)
  rescue
    e -> 
      Logger.warning("Stream handler failed: #{inspect(e)}")
      # Continue execution despite handler failure
  end
end
```

## Testing Requirements

### Behavior Testing
Each implementation should test:
- Valid configuration acceptance
- Invalid configuration rejection
- Successful execution with stream handling
- Error conditions and appropriate error returns
- Session management (if supported)
- Stream handler failure resilience

### Mock Implementation
For testing contexts that use agents:
```elixir
defmodule MockAgentImplementation do
  @behaviour AgentBehaviour
  
  @impl true
  def execute(_agent, prompt, stream_handler) do
    # Simulate streaming output
    stream_handler.("Processing: #{prompt}")
    stream_handler.("Result: Mock response")
    
    {:ok, %{
      final_output: "Mock response for: #{prompt}",
      metadata: %{mock: true}
    }}
  end
  
  @impl true
  def validate_config(config), do: {:ok, config}
end
```

## Dependencies

- **Agent Schema**: Uses Agent struct for configuration and metadata
- **Logging**: Should use Logger for error reporting and debugging
- **No External Dependencies**: Behavior itself has no external dependencies

## Future Considerations

- **Async Execution**: Consider `execute_async/3` callback for non-blocking execution
- **Progress Reporting**: Standardized progress/status reporting beyond simple streaming
- **Resource Management**: Callbacks for resource allocation and cleanup
- **Capability Discovery**: Runtime capability detection and reporting
- **Multi-turn Conversations**: Structured conversation state management