# CodeMySpec.Code.ElixirAst

**Type**: module

Performs AST operations specifically for Elixir source files, extracting module dependencies, function definitions with specs, and test assertions. Provides static code analysis capabilities by parsing Elixir source files into Abstract Syntax Trees and extracting structured metadata.

## Functions

### get_dependencies/1

Extract module dependencies from an Elixir source file by parsing alias, import, and use statements.

```elixir
@spec get_dependencies(file_path :: String.t()) :: {:ok, [String.t()]} | {:error, term()}
```

**Process**:
1. Read the Elixir source file from the provided file path
2. Parse the file contents into an AST using `Code.string_to_quoted/2`
3. Traverse the AST to identify dependency declarations:
   - `alias` statements (single and multi-alias forms)
   - `import` statements
   - `use` statements
4. Extract fully qualified module names from each dependency type
5. Return deduplicated list of module names as strings
6. Return error tuple if file doesn't exist or has syntax errors

**Test Assertions**:
- returns list of aliased modules (single alias)
- returns list of aliased modules (multi-alias form)
- returns list of imported modules
- returns list of used modules
- combines alias, import, and use into single list
- deduplicates repeated module references
- handles alias with :as option
- returns error for invalid Elixir syntax
- returns error for non-existent file
- returns empty list for files with no dependencies

### get_public_functions/1

Extract public function definitions with their @spec declarations from an Elixir source file.

```elixir
@spec get_public_functions(file_path :: String.t()) ::
  {:ok, [%{name: atom(), arity: integer(), spec: String.t() | nil}]} | {:error, term()}
```

**Process**:
1. Read the Elixir source file from the provided file path
2. Parse the file contents into an AST using `Code.string_to_quoted/2`
3. Traverse the AST to identify public function definitions (`def` macros, not `defp`)
4. For each public function:
   - Extract function name (atom)
   - Calculate arity from function arguments
   - Look for associated `@spec` attribute preceding the function
   - Convert spec AST back to string representation if present
5. Handle multi-clause functions by deduplicating same name/arity
6. Return list of function metadata maps
7. Return error tuple if file doesn't exist or has syntax errors

**Test Assertions**:
- extracts public function names as atoms
- extracts correct arity for functions
- excludes private functions (defp)
- includes @spec when present
- handles functions without @spec (spec: nil)
- handles multi-clause functions correctly (single entry)
- handles functions with default arguments
- handles functions with guards
- handles functions with pattern matching in args
- returns error for invalid Elixir syntax
- returns empty list for modules with no public functions
- returns empty list for non-module files (scripts)

### get_test_assertions/1

Extract test case names and descriptions from an ExUnit test file by parsing test and describe blocks.

```elixir
@spec get_test_assertions(file_path :: String.t()) ::
  {:ok, [%{test_name: String.t(), description: String.t()}]} | {:error, term()}
```

**Process**:
1. Read the Elixir test file from the provided file path
2. Parse the file contents into an AST using `Code.string_to_quoted/2`
3. Traverse the AST to identify test macro calls:
   - `test` macro calls with test descriptions
   - `describe` blocks containing groups of tests
4. For each test:
   - Extract test description (string argument to test macro)
   - Track parent describe context if nested
   - Combine describe and test descriptions for full context
5. Build list of test metadata with test_name and description
6. Return list of test case information
7. Return error tuple if file doesn't exist, has syntax errors, or is not a test file

**Test Assertions**:
- extracts test names from test blocks
- extracts test descriptions as strings
- identifies describe block groupings
- handles nested describe blocks
- combines describe + test for full context
- handles tests without describe blocks
- handles doctest declarations
- returns error for invalid Elixir syntax
- returns error for non-test files
- returns empty list for test files with no tests

## Dependencies

- File
- CodeMySpec.Code
