# CodeMySpec.BddSpecs.Parser

**Type**: module

Parses Spex DSL source files into structured Spec data using Elixir AST analysis. Reads spec files, converts to quoted expressions, and walks the AST to extract spex, scenario, given_, when_, and then_ macro calls. Returns Spec structs with all scenarios and steps populated. Does not execute specs - only extracts structure for analysis and rendering.

## Delegates

None

## Functions

### parse_file/1

Parse a Spex DSL file into a Spec struct with all scenarios and steps extracted.

```elixir
@spec parse_file(String.t()) :: {:ok, Spec.t()} | {:error, term()}
```

**Process**:
1. Read the file contents from the provided file path
2. Parse the file contents into an AST using `Code.string_to_quoted/2`
3. Traverse the AST to find the defmodule declaration
4. Extract the module name to use as the spec identifier
5. Find the spex macro call within the module body
6. Extract spex name, description, and tags from the macro arguments
7. Walk the spex block to find all scenario macro calls
8. Parse each scenario into a Scenario struct
9. Derive story_id and criterion_id from file path using naming conventions
10. Build and return Spec struct with all extracted data
11. Return error tuple if file doesn't exist, has syntax errors, or missing required macros

**Test Assertions**:
- returns {:ok, spec} for valid Spex DSL file
- extracts spec name from spex macro first argument
- extracts description from spex options keyword list
- extracts tags from spex options keyword list
- finds all scenario blocks within spex
- returns error for file with no spex macro
- returns error for invalid Elixir syntax
- returns error for non-existent file
- extracts story_id from directory pattern {story_id}_*
- extracts criterion_id from filename pattern criterion_{id}_spex.exs
- handles spex files without story/criterion linking
- preserves file path in returned Spec struct

### parse_scenario/1

Parse a scenario AST node into a Scenario struct with all steps extracted.

```elixir
@spec parse_scenario(tuple()) :: Scenario.t()
```

**Process**:
1. Extract scenario name from the first argument of the scenario macro call
2. Walk the scenario block AST to find all step macro calls (given_, when_, then_)
3. For each step macro call:
   - Determine step type from macro name (:given, :when, :then)
   - Extract step description from first argument
   - Get source line number from AST metadata
   - Create Step struct with type, description, and line number
4. Group steps by type into given, when, and then lists
5. Build and return Scenario struct with name and all steps

**Test Assertions**:
- extracts scenario name from macro argument
- finds all given_ macro calls and creates Step structs
- finds all when_ macro calls and creates Step structs
- finds all then_ macro calls and creates Step structs
- preserves step order as they appear in source
- extracts step descriptions as strings
- captures line numbers from AST metadata
- handles scenarios with no steps (empty lists)
- handles scenarios with only given steps
- handles scenarios with mixed step types
- groups steps correctly by type (:given, :when, :then)

### extract_spex_metadata/1

Extract metadata (name, description, tags) from a spex macro call AST.

```elixir
@spec extract_spex_metadata(tuple()) :: %{name: String.t(), description: String.t() | nil, tags: [atom()]}
```

**Process**:
1. Extract the first argument as the spec name (string)
2. Look for keyword list in second argument position
3. Extract :description value if present
4. Extract :tags value if present, defaulting to empty list
5. Return map with name, description, and tags

**Test Assertions**:
- extracts name from first argument
- extracts description from keyword list
- extracts tags list from keyword list
- defaults description to nil when not provided
- defaults tags to empty list when not provided
- handles spex with only name argument
- handles spex with all metadata fields

### validate_syntax/1

Validate that a file contains required Spex DSL structure without parsing fully.

```elixir
@spec validate_syntax(String.t()) :: :ok | {:error, [String.t()]}
```

**Process**:
1. Read file contents
2. Parse into AST using `Code.string_to_quoted/2`
3. Check for defmodule declaration
4. Check for spex macro call within module
5. Verify at least one scenario exists
6. Verify scenarios contain step macros (given_/when_/then_)
7. Accumulate validation errors if any checks fail
8. Return :ok if all validations pass
9. Return {:error, errors} with list of validation failure messages

**Test Assertions**:
- returns :ok for valid Spex DSL file
- returns {:error, reasons} when no defmodule found
- returns {:error, reasons} when no spex macro found
- returns {:error, reasons} when no scenarios found
- returns {:error, reasons} for scenarios without steps
- returns {:error, reasons} for invalid syntax
- returns {:error, reasons} for non-existent file
- accumulates multiple validation errors in single call
- provides descriptive error messages

### derive_story_id/1

Extract story ID from file path using naming convention.

```elixir
@spec derive_story_id(String.t()) :: integer() | nil
```

**Process**:
1. Extract directory name from file path
2. Match directory name against pattern {story_id}_* using regex
3. Extract numeric story_id from matched pattern
4. Return integer story_id if match succeeds
5. Return nil if no match (file not in story directory)

**Test Assertions**:
- extracts story_id from directory name like "123_user_authentication"
- extracts story_id from directory name like "456_dashboard"
- returns nil for files not in story directory pattern
- returns nil for malformed directory names
- handles numeric IDs correctly as integers

### derive_criterion_id/1

Extract criterion ID from file name using naming convention.

```elixir
@spec derive_criterion_id(String.t()) :: integer() | nil
```

**Process**:
1. Extract base filename from file path
2. Match filename against pattern criterion_{id}_spex.exs using regex
3. Extract numeric criterion_id from matched pattern
4. Return integer criterion_id if match succeeds
5. Return nil if no match (file doesn't follow criterion naming)

**Test Assertions**:
- extracts criterion_id from filename "criterion_123_spex.exs"
- extracts criterion_id from filename "criterion_456_spex.exs"
- returns nil for files not following criterion pattern
- returns nil for generic spec files
- handles numeric IDs correctly as integers

## Dependencies

- File
- CodeMySpec.Code
- CodeMySpec.BddSpecs.Spec
- CodeMySpec.BddSpecs.Scenario
- CodeMySpec.BddSpecs.Step
