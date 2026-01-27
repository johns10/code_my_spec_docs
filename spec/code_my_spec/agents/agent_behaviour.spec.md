# CodeMySpec.Agents.AgentBehaviour

Defines the contract that all agent implementations must fulfill, ensuring consistent interface and behavior across different execution backends (Claude Code, OpenHands, custom agents, etc.). This behaviour is for **implementations**, not agent types.

## Delegates

None - this module defines callbacks only.

## Functions

### build_command_string/2

Build a command string for the agent with the given prompt. Legacy API that returns a command list for client execution.

```elixir
@callback build_command_string(Agent.t(), prompt()) ::
  {:ok, command_list()} | {:error, execution_error()}
```

**Process**:
1. Accept an Agent struct and prompt string as arguments
2. Merge the agent's configuration with any default settings
3. Build a command argument list suitable for spawning an external process
4. Return `{:ok, command_list}` on success or `{:error, reason}` on failure

**Test Assertions**:
- returns `{:ok, command_list}` with valid agent and prompt
- command list starts with the agent's CLI command (e.g., "claude")
- returns `{:error, atom}` when agent configuration is invalid

### build_command_string/3

Build a command string with additional runtime options that override agent configuration.

```elixir
@callback build_command_string(Agent.t(), prompt(), opts()) ::
  {:ok, command_list()} | {:error, execution_error()}
```

**Process**:
1. Accept an Agent struct, prompt string, and runtime options as arguments
2. Merge the agent's base configuration with the provided runtime options
3. Build a command argument list with the merged configuration
4. Return `{:ok, command_list}` on success or `{:error, reason}` on failure

**Test Assertions**:
- returns `{:ok, command_list}` with valid agent, prompt, and options
- runtime options override agent configuration values
- accepts both map and keyword list for options parameter
- command list includes flags derived from merged configuration

### build_command_struct/3

Build a Command struct for agentic execution. The module field must be set by the caller after receiving the command.

```elixir
@callback build_command_struct(Agent.t(), prompt(), opts()) ::
  {:ok, Command.t()} | {:error, execution_error()}
```

**Process**:
1. Accept an Agent struct, prompt string, and runtime options as arguments
2. Merge the agent's base configuration with the provided runtime options
3. Build CLI arguments from the merged configuration
4. Create a Command struct with the command name, args in metadata, and module set to nil
5. Return `{:ok, Command.t()}` on success or `{:error, reason}` on failure

**Test Assertions**:
- returns `{:ok, Command.t()}` with valid agent, prompt, and options
- returned Command has module field set to nil (caller must set)
- returned Command contains metadata with prompt and options
- returned Command has timestamp set
- accepts both map and keyword list for options parameter

## Dependencies

- CodeMySpec.Agents.Agent
- CodeMySpec.Sessions.Command
