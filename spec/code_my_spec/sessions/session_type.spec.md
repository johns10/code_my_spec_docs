# CodeMySpec.Sessions.SessionType

## Type

module

Maps between agent task module atoms and their string names. Used by Session for type validation and by SessionStack to resolve the module to call for evaluation. No longer an Ecto custom type — just a plain module with lookup functions.

## Dependencies

- CodeMySpec.AgentTasks

## Functions

### cast/1

Convert a string name or atom to the corresponding agent task module.

```elixir
@spec cast(String.t() | atom()) :: {:ok, atom()} | :error
```

**Process**:
1. If atom, check against valid types whitelist
2. If string, look up in the name-to-module mapper
3. Return `{:ok, module}` or `:error`

**Test Assertions**:
- returns module atom for valid string name (e.g. "ComponentSpec" → AgentTasks.ComponentSpec)
- returns module atom for valid atom
- returns :error for unknown type

### mapper/0

Returns a map of short names to agent task modules.

```elixir
@spec mapper() :: %{String.t() => atom()}
```

**Process**:
1. Build map from valid types list: last segment of module name → full module

**Test Assertions**:
- maps "ComponentSpec" to AgentTasks.ComponentSpec
- includes all valid agent task types
