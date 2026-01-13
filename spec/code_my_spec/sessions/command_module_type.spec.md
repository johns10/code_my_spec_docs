# CodeMySpec.Sessions.CommandModuleType

Custom Ecto type for safely serializing and deserializing session command module atoms to and from database strings. Provides a whitelist-based validation mechanism to ensure only valid session step modules can be stored and loaded, protecting against arbitrary atom creation from untrusted database content.

## Functions

### type/0

Returns the underlying database type for this custom Ecto type.

```elixir
@spec type() :: :string
```

**Process**:
1. Return :string as the database storage type

**Test Assertions**:
- returns :string atom

### cast/1

Converts input values to the internal atom representation for use in changesets.

```elixir
@spec cast(atom() | String.t()) :: {:ok, atom()} | :error
```

**Process**:
1. If input is an atom, return it wrapped in {:ok, atom}
2. If input is a binary string, look it up in the string_mapper
3. If found in mapper, recursively cast the resulting atom
4. For any other input, return :error

**Test Assertions**:
- returns {:ok, module} when given a valid module atom
- returns {:ok, module} when given a valid module string
- returns :error when given an invalid module string
- returns :error when given nil
- returns :error when given a number
- returns :error when given a list

### load/1

Converts database string values back to atoms when loading from the database.

```elixir
@spec load(String.t()) :: {:ok, atom()}
```

**Process**:
1. Look up the binary string in the string_mapper
2. Return {:ok, atom} with the mapped module atom

**Test Assertions**:
- returns {:ok, module} for valid stored module strings
- returns {:ok, nil} for unknown module strings (via Map.get default)

### dump/1

Converts atom values to strings for database storage.

```elixir
@spec dump(atom()) :: {:ok, String.t()} | :error
```

**Process**:
1. If input is an atom, convert to string and return {:ok, string}
2. For any other input, return :error

**Test Assertions**:
- returns {:ok, string} when given an atom
- returns :error when given a non-atom value
- returns :error when given a string
- returns :error when given nil

### string_mapper/0

Builds a mapping from module name strings to module atoms for lookup operations.

```elixir
@spec string_mapper() :: %{String.t() => atom()}
```

**Process**:
1. Reduce over the @valid_modules list
2. For each module atom, convert to string and add to accumulator map
3. Return map of string keys to atom values

**Test Assertions**:
- returns a map
- contains all valid modules as values
- keys are string versions of module atoms
- includes all context spec session step modules
- includes all component spec session step modules
- includes all component coding session step modules
- includes all component test session step modules
- includes all context components design session step modules
- includes all context coding session step modules
- includes all context testing session step modules
- includes all context design review session step modules

## Dependencies

- Ecto.Type
- Logger
