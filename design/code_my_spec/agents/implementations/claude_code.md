# Claude Code Agent Implementation

## Purpose
Main implementation of AgentBehaviour for Claude Code CLI integration. Orchestrates configuration merging, command building, and streaming execution.

## Interface

```elixir
@behaviour CodeMySpec.Agents.AgentBehaviour

@impl true
def execute(%Agent{} = agent, prompt, stream_handler) do
  # Implementation
end
```

## Core Responsibilities
- Merge agent type and instance configurations
- Build Claude CLI command from merged config
- Execute command via CLI adapter with streaming
- Handle execution results and errors

## Execution Flow

```
execute(agent, prompt, stream_handler)
│
├── merge_configs(agent) → merged_config
├── build_command(prompt, merged_config) → command_args
├── cli_adapter.run(command_args, stream_handler)
└── return execution_result
```

## Configuration Merging

```elixir
defp merge_configs(%Agent{config: agent_config, agent_type: %AgentType{config: type_config}}) do
  Map.merge(type_config, agent_config)
end
```

**Merge Strategy**: Agent type config provides defaults, agent instance config overrides.

## Command Building

```elixir
defp build_command(prompt, config) do
  base_cmd = ["claude", "--output-format", "stream-json", "--print", prompt]
  cli_args = build_cli_args(config)
  base_cmd ++ cli_args
end
```

**Base Arguments**: Always includes streaming JSON output format and prompt.
**Config Mapping**: Transforms map keys to CLI flags (e.g., `"model" → "--model"`).

## CLI Configuration Mapping

| Config Key        | CLI Flag          | Example               |
| ----------------- | ----------------- | --------------------- |
| `"model"`         | `--model`         | `"claude-3-5-sonnet"` |
| `"allowed_tools"` | `--allowedTools`  | `["Read", "Write"]`   |
| `"system_prompt"` | `--system-prompt` | `"You are helpful"`   |
| `"max_turns"`     | `--max-turns`     | `5`                   |
| `"cwd"`           | `--cwd`           | `"/path/to/work"`     |

## Error Handling

```elixir
case cli_adapter.run(command, stream_handler) do
  {:ok, :completed} -> 
    {:ok, %{status: :completed}}
    
  {:error, reason, details} -> 
    {:error, reason}
end
```

**Strategy**: Pass through adapter errors without transformation.
**Logging**: Minimal logging, let stream handler deal with details.

## Dependencies
- **CLI Adapter**: Injected via application config for testing
- **Agent/AgentType**: Ecto schemas for configuration
- **Jason**: Only if config requires JSON encoding

## Dependency Injection

```elixir
# Production
config :code_my_spec, :claude_cli_adapter, CodeMySpec.Agents.ClaudeCode.CLIAdapter

# Test
config :code_my_spec, :claude_cli_adapter, CodeMySpec.TestSupport.MockCLIAdapter
```

## Design Principles
- **Single responsibility**: Orchestrate, don't process
- **Configuration driven**: Behavior controlled by agent config
- **Streaming transparent**: Pass handler through to adapter
- **Error transparent**: Don't mask or format adapter errors
- **Stateless**: No internal state between executions

## Module Structure

```
CodeMySpec.Agents.ClaudeCode
├── execute/3 (public, AgentBehaviour)
├── merge_configs/1 (private)
├── build_command/2 (private)
└── build_cli_args/1 (private)
```

## Testing Strategy
- **Mock CLI adapter** via dependency injection
- **Unit test** config merging and command building
- **Integration test** with recorded CLI interactions
- **No mocking** of Agent/AgentType structs (use real data)