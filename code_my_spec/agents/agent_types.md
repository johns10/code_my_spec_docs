# AgentTypes

## Purpose
Simple data store for agent type definitions. Provides agent type configurations as static data structures without complex logic.

## Module Interface

```elixir
@spec get(agent_type()) :: AgentType.t() | nil
@spec list() :: [agent_type()]
@spec exists?(agent_type()) :: boolean()

@type agent_type() :: :coder
```

## Function Specifications

### `get/1`
Returns the AgentType struct for the given type, or nil if not found.

### `list/0`
Returns list of all available agent type atoms.

### `exists?/1`
Quick check if an agent type is defined.

## Dependencies

- **AgentType struct**: For type definitions and validation
