# CodeMySpec.Requirements.CheckerType

Custom Ecto type that validates and converts requirement checker modules. Provides type casting, loading, and dumping for a predefined set of valid checker modules used in the requirements system. Built using `CodeMySpec.Utils.ModuleType` to enable database persistence of checker module references. Valid checker modules include FileExistenceChecker, DocumentValidityChecker, TestStatusChecker, DependencyChecker, HierarchicalChecker, and ContextReviewFileChecker.

## Delegates

None.

## Functions

### type/0

Returns the underlying Ecto type used for database storage.

```elixir
@spec type() :: :string
```

**Process**:
1. Return `:string` as the database storage type

**Test Assertions**:
- returns :string

### cast/1

Casts a value to a valid checker module atom.

```elixir
@spec cast(binary() | atom()) :: {:ok, t()} | :error
```

**Process**:
1. If input is an atom in the valid types list, return `{:ok, module}`
2. If input is a binary string, look up the short name in the mapper
3. If found in mapper, recursively cast the resolved module atom
4. Otherwise return `:error`

**Test Assertions**:
- returns {:ok, module} when given a valid checker module atom
- returns {:ok, module} when given the short name string "FileExistenceChecker"
- returns {:ok, module} when given the short name string "DocumentValidityChecker"
- returns {:ok, module} when given the short name string "TestStatusChecker"
- returns {:ok, module} when given the short name string "DependencyChecker"
- returns {:ok, module} when given the short name string "HierarchicalChecker"
- returns {:ok, module} when given the short name string "ContextReviewFileChecker"
- returns :error when given an invalid module atom
- returns :error when given an unknown string
- returns :error when given nil
- returns :error when given a number

### load/1

Loads a checker module from database string representation.

```elixir
@spec load(binary()) :: {:ok, t()} | :error
```

**Process**:
1. Convert the binary string to an existing atom using `String.to_existing_atom/1`
2. Return `{:ok, module}` with the resolved atom

**Test Assertions**:
- returns {:ok, module} when loading a valid checker module string
- converts string to existing atom

### dump/1

Dumps a checker module atom to string for database storage.

```elixir
@spec dump(atom()) :: {:ok, binary()} | :error
```

**Process**:
1. If the module is an atom in the valid types list, convert to string and return `{:ok, string}`
2. Otherwise return `:error`

**Test Assertions**:
- returns {:ok, string} when dumping a valid checker module atom
- returns :error when dumping an invalid module atom
- returns :error when dumping a non-atom value

### mapper/0

Returns a map from short module names to full module atoms.

```elixir
@spec mapper() :: %{String.t() => module()}
```

**Process**:
1. Map over valid types, extracting the last segment of each module name
2. Create tuples of (short_name, full_module)
3. Convert to a map

**Test Assertions**:
- returns a map with short names as keys
- maps "FileExistenceChecker" to CodeMySpec.Requirements.FileExistenceChecker
- maps "DocumentValidityChecker" to CodeMySpec.Requirements.DocumentValidityChecker
- maps "TestStatusChecker" to CodeMySpec.Requirements.TestStatusChecker
- maps "DependencyChecker" to CodeMySpec.Requirements.DependencyChecker
- maps "HierarchicalChecker" to CodeMySpec.Requirements.HierarchicalChecker
- maps "ContextReviewFileChecker" to CodeMySpec.Requirements.ContextReviewFileChecker
- contains exactly 6 entries

### valid_types/0

Returns the list of valid checker module atoms.

```elixir
@spec valid_types() :: [module()]
```

**Process**:
1. Return the module attribute `@valid_types`

**Test Assertions**:
- returns a list of 6 modules
- includes CodeMySpec.Requirements.FileExistenceChecker
- includes CodeMySpec.Requirements.DocumentValidityChecker
- includes CodeMySpec.Requirements.TestStatusChecker
- includes CodeMySpec.Requirements.DependencyChecker
- includes CodeMySpec.Requirements.HierarchicalChecker
- includes CodeMySpec.Requirements.ContextReviewFileChecker

## Dependencies

- CodeMySpec.Utils.ModuleType
- Ecto.Type