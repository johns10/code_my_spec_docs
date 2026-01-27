# CodeMySpec.Agents.AgentTypes

Registry module that provides predefined agent type configurations for the CodeMySpec platform. Each agent type represents a specialized AI assistant role with specific prompts, descriptions, and configurations.

## Dependencies

- CodeMySpec.Agents.AgentType

## Functions

### get/1

Retrieves an agent type configuration by its atom identifier.

```elixir
@spec get(agent_type()) :: {:ok, AgentType.t()} | {:error, :unknown_type}
```

**Process**:
1. Pattern match the agent type atom against known types
2. If match found, return `{:ok, agent_type_struct}` with the configured AgentType struct
3. If no match, return `{:error, :unknown_type}`

**Test Assertions**:
- returns `{:ok, agent_type}` for `:unit_coder`
- returns `{:ok, agent_type}` for `:context_designer`
- returns `{:ok, agent_type}` for `:context_reviewer`
- returns `{:ok, agent_type}` for `:component_designer`
- returns `{:ok, agent_type}` for `:test_writer`
- returns `{:error, :unknown_type}` for unknown agent type atoms
- returned AgentType struct contains correct name, description, and prompt fields

### list/0

Returns a list of all available agent type identifiers.

```elixir
@spec list() :: [agent_type()]
```

**Process**:
1. Return the hardcoded list of all supported agent type atoms

**Test Assertions**:
- returns a list containing all five agent types
- returns list with `:unit_coder`, `:context_designer`, `:context_reviewer`, `:component_designer`, `:test_writer`
- returns list in consistent order

### exists?/1

Checks whether a given agent type atom is a valid, known agent type.

```elixir
@spec exists?(agent_type()) :: boolean()
```

**Process**:
1. Check if the provided atom is a member of the list returned by `list/0`
2. Return true if found, false otherwise

**Test Assertions**:
- returns true for `:unit_coder`
- returns true for `:context_designer`
- returns true for `:context_reviewer`
- returns true for `:component_designer`
- returns true for `:test_writer`
- returns false for unknown agent type atoms
- returns false for non-atom values
