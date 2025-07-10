# Agents Context

## Purpose
Manages agent creation and execution for coding tasks. Agents have types (like `:unit_coder`) that define their configuration and capabilities, and implementations (like `ClaudeCodeAgent`) that handle actual execution. Agents are ephemeral and not persisted.

## Entity Ownership
- Agent entities and execution orchestration

## Public API

```elixir
# Agent creation and management
@spec create_agent(agent_params()) :: {:ok, Agent.t()} | {:error, Changeset.t()}
@spec list_agent_types() :: [agent_type()]
@spec execute(Agent.t(), prompt(), stream_handler()) :: 
  {:ok, execution_result()} | {:error, execution_error()}

# Type definitions
@type agent_type() :: :unit_coder
@type agent_params() :: %{name: String.t(), type: agent_type(), config: map()}
@type prompt() :: String.t()
@type stream_handler() :: (any() -> :ok)
@type execution_result() :: map()
@type execution_error() :: :config_invalid | :agent_unavailable | :execution_failed
```

## State Management Strategy

### Ephemeral Agents
- Agents are created on-demand using embedded schemas
- No persistence - agents exist only for task duration
- Agent state is maintained in memory during execution

### Implementation Mapping
- Agent types mapped to implementation modules via application configuration
- Environment-specific agent implementations (test vs production)
- Configuration-driven agent execution backend selection

### Agent Configuration
- Agent-specific configuration validation through behavior contract
- No mandated configuration fields - each agent defines its own schema
- Sensitive data handling managed per agent implementation

## Component Diagram

```
Agents Context
├── Agent (embedded schema)
│   ├── name, type, config
│   └── created_at timestamp
├── Registry (main component)
│   └── manages all agent types (:unit_coder, etc.)
├── AgentType
│   └── defines struct and required keys for agents
├── AgentTypes/
│   └── Defines agent types and logic for getting them
└── Implementations/
    └── ClaudeCodeAgent (execution implementation)
        ├── implements AgentBehaviour
        └── actual execution implementation
```

## Dependencies

- **ClaudeCode modules**: Existing CLI adapter infrastructure for Claude Code agent implementation
- **Application Configuration**: Agent type to implementation module mappings

## Execution Flow

1. **Agent Creation**: Create agent with type `:unit_coder` and optional config overrides
2. **Type Resolution**: Get agent type module from Types.Registry 
3. **Implementation Lookup**: Get execution implementation from application config
4. **Execute**: Call `ImplementationModule.execute(agent, prompt, stream_handler)` 
5. **Stream Handling**: Implementation streams output chunks to provided handler
6. **Handler Responsibility**: Stream handler processes chunks appropriately
7. **Completion**: Implementation returns execution result with metadata
8. **Persistence**: Agent and session data persisted for tracking
