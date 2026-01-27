# CodeMySpec.Agents.Implementations.ClaudeCode

Claude Code CLI integration implementation of AgentBehaviour. Builds claude CLI commands with proper configuration for client execution.

## Delegates

None.

## Functions

### build_command_string/2

Build a command string for the agent with the given prompt (delegates to build_command_string/3 with empty opts).

```elixir
@spec build_command_string(Agent.t(), String.t()) :: {:ok, [String.t()]} | {:error, atom()}
```

**Process**:
1. Call build_command_string/3 with an empty map for options

**Test Assertions**:
- returns {:ok, command_list} with valid agent and prompt
- command list starts with "claude"
- command list ends with the prompt string

### build_command_string/3

Build a command string with merged configuration and runtime options.

```elixir
@spec build_command_string(Agent.t(), String.t(), map()) :: {:ok, [String.t()]} | {:error, atom()}
```

**Process**:
1. Merge agent type config with instance config using CodeMySpec.Agents.merge_configs/1
2. Merge the result with runtime opts (opts take precedence)
3. Build CLI arguments from the final config
4. Return {:ok, command_args} where command_args is ["claude" | cli_args ++ [prompt]]

**Test Assertions**:
- returns {:ok, command_list} with valid inputs
- merges agent type config with instance config
- runtime opts override agent config
- includes --model flag when model is specified
- includes --max-turns flag when max_turns is specified
- includes --system-prompt flag when system_prompt is specified
- includes --cwd flag when cwd is specified
- includes --verbose flag when verbose is true
- excludes --verbose when verbose is false
- includes --allowedTools with comma-separated tools list
- includes --resume flag when resume is specified
- includes --continue flag when continue is true
- includes --permission-mode flag when permission_mode is specified
- auto mode sets --permission-mode dontAsk with whitelisted tools

### build_command_struct/3

Build a Command struct for Claude Code execution.

```elixir
@spec build_command_struct(Agent.t(), String.t(), keyword() | map()) :: {:ok, Command.t()} | {:error, atom()}
```

**Process**:
1. Merge agent type config with instance config using CodeMySpec.Agents.merge_configs/1
2. Convert opts to map if provided as keyword list
3. Merge instance config with opts (opts take precedence)
4. Build CLI args from the final config
5. Return {:ok, Command struct} with command: "claude", execution_strategy: :async, and metadata containing prompt, args, and options

**Test Assertions**:
- returns {:ok, Command.t()} with valid inputs
- accepts keyword list for opts parameter
- accepts map for opts parameter
- Command.command is "claude"
- Command.execution_strategy is :async
- Command.module is nil (caller must set it)
- Command.metadata contains :prompt key with the prompt
- Command.metadata contains :args key with CLI arguments list
- Command.metadata contains :options key with merged config
- Command.timestamp is set to current UTC time

## Dependencies

- CodeMySpec.Agents
- CodeMySpec.Agents.Agent
- CodeMySpec.Agents.AgentBehaviour
- CodeMySpec.Sessions.Command
