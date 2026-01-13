# SessionType

Custom Ecto type for validating and serializing session types. Handles both legacy orchestrator-based session types and new agent task types, providing type-safe casting, loading, and dumping for database persistence.

## Dependencies

- Ecto.Type
- CodeMySpec.Sessions.AgentTasks

## Functions

### type/0

Returns the underlying database type for this custom Ecto type.

```elixir
@spec type() :: :string
```

**Process**:
1. Return `:string` as the database storage type

**Test Assertions**:
- returns :string atom

### cast/1

Casts a value to a valid session type module. Accepts both atom and binary (string) inputs.

```elixir
@spec cast(binary() | atom()) :: {:ok, t()} | :error
```

**Process**:
1. If input is an atom in the valid types list, wrap in `{:ok, module}` tuple
2. If input is a binary string, look up the module name in the mapper and recursively cast
3. For any other input, return `:error`

**Test Assertions**:
- returns {:ok, module} for valid legacy type atom
- returns {:ok, module} for valid agent task type atom
- returns {:ok, module} for valid type as string (e.g., "ComponentSpec")
- returns :error for invalid atom
- returns :error for invalid string
- returns :error for non-atom/non-binary input

### load/1

Loads a session type from database storage format (binary string) to runtime format (atom).

```elixir
@spec load(binary()) :: {:ok, t()} | :error
```

**Process**:
1. Convert the binary string to an atom using `String.to_atom/1`
2. Wrap the result in `{:ok, atom}` tuple

**Test Assertions**:
- returns {:ok, atom} for valid binary module name
- converts string representation to corresponding atom

### dump/1

Dumps a session type from runtime format (atom) to database storage format (binary string).

```elixir
@spec dump(atom()) :: {:ok, binary()} | :error
```

**Process**:
1. If input is an atom, convert to string using `Atom.to_string/1` and wrap in `{:ok, string}` tuple
2. For any other input, return `:error`

**Test Assertions**:
- returns {:ok, string} for valid atom module
- returns :error for non-atom input

### mapper/0

Builds a mapping from short module names to full module atoms for string-based type lookup.

```elixir
@spec mapper() :: %{binary() => atom()}
```

**Process**:
1. Map over all valid types (legacy + agent task types)
2. For each type, extract the last segment of the module name (e.g., "ComponentSpec" from AgentTasks.ComponentSpec)
3. Create a tuple of `{short_name, full_module}` for each type
4. Convert the list of tuples into a map

**Test Assertions**:
- returns a map with string keys
- maps "ComponentSpec" to AgentTasks.ComponentSpec
- maps "ContextSpec" to AgentTasks.ContextSpec
- maps legacy type names to their full module atoms
- includes all valid types in the mapping
