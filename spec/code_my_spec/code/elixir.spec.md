# CodeMySpec.Code.Elixir

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
   - `alias` statements (single and multi-alias forms like `alias Foo.{Bar, Baz}`)
   - `import` statements with optional `:only` and `:except` options
   - `use` statements with optional configuration
4. Extract fully qualified module names from each dependency type
5. Handle aliased multi-form syntax (e.g., `alias Foo.{Bar, Baz}` -> `["Foo.Bar", "Foo.Baz"]`)
6. Return deduplicated list of module names as strings
7. Return error tuple if file doesn't exist or has syntax errors

**Test Assertions**:
- returns list of aliased modules (single alias)
- returns list of aliased modules (multi-alias form)
- returns list of imported modules
- returns list of used modules
- combines alias, import, and use into single list
- deduplicates repeated module references
- handles alias with :as option
- handles import with :only option
- handles import with :except option
- returns error for invalid Elixir syntax
- returns error for non-existent file
- returns empty list for files with no dependencies

### get_functions/1

Extract public function definitions with their @spec declarations from an Elixir source file.

```elixir
@spec get_functions(file_path :: String.t()) ::
  {:ok, [%{name: atom(), arity: integer(), spec: String.t() | nil}]} | {:error, term()}
```

**Process**:
1. Read the Elixir source file from the provided file path
2. Parse the file contents into an AST using `Code.string_to_quoted/2`
3. Traverse the AST to identify public function definitions (`def` macros, not `defp`)
4. For each public function:
   - Extract function name as an atom
   - Calculate arity from function arguments
   - Look for associated `@spec` attribute preceding the function
   - Convert spec AST back to string representation if present
5. Handle multi-clause functions by deduplicating same name/arity combinations
6. Handle functions with default arguments (calculate base arity and generated arities)
7. Return list of function metadata maps
8. Return error tuple if file doesn't exist or has syntax errors

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
- handles functions with when clauses
- returns error for invalid Elixir syntax
- returns empty list for modules with no public functions
- returns empty list for non-module files (scripts)

### get_test_assertions/1

Extract test case names and descriptions from an ExUnit test file by parsing test and describe blocks.

```elixir
@spec get_test_assertions(file_path :: String.t()) ::
  {:ok, [%{test_name: String.t(), describe_blocks: [String.t()], description: String.t()}]}
  | {:error, term()}
```

**Process**:
1. Read the Elixir test file from the provided file path
2. Parse the file contents into an AST using `Code.string_to_quoted/2`
3. Traverse the AST to identify test macro calls:
   - `test` macro calls with test descriptions (string argument)
   - `describe` blocks containing groups of tests
4. For each test:
   - Extract test description (string argument to test macro)
   - Track parent describe context as a list (supports nesting)
   - Combine describe and test descriptions for full context
5. Build list of test metadata with:
   - `test_name`: the direct test description
   - `describe_blocks`: list of parent describe block names
   - `description`: full combined description path
6. Return list of test case information
7. Return error tuple if file doesn't exist or has syntax errors

**Test Assertions**:
- extracts test names from test blocks
- extracts test descriptions as strings
- identifies describe block groupings
- handles nested describe blocks
- combines describe + test for full context description
- handles tests without describe blocks (empty describe_blocks list)
- handles doctest declarations
- handles setup and setup_all blocks without including them as tests
- returns error for invalid Elixir syntax
- returns empty list for test files with no tests
- preserves order of tests as they appear in file

### get_undeclared_dependencies/1

Extract module references that are used in the code but not explicitly declared via alias, import, or use statements.

```elixir
@spec get_undeclared_dependencies(file_path :: String.t()) :: {:ok, [String.t()]} | {:error, term()}
```

**Process**:
1. Read the Elixir source file from the provided file path
2. Parse the file contents into an AST using `Code.string_to_quoted/2`
3. Get all declared dependencies using get_dependencies/1
4. Build alias resolution map for short name -> full module name mappings
5. Traverse AST to collect all module references:
   - Fully qualified function calls (e.g., `MyApp.User.get/1`)
   - Struct references (e.g., `%MyApp.User{}`)
   - Behaviour declarations (`@behaviour SomeBehaviour`)
   - Typespec module references in `@spec`, `@type`, `@callback`
   - Protocol implementations (`defimpl Protocol, for: Type`)
   - Quote/unquote module references
6. Resolve aliased short names to full module names using alias map
7. Filter out:
   - Elixir standard library modules (Kernel, Enum, Map, List, etc.)
   - Erlang modules (atoms starting with lowercase)
   - The current module itself
   - Already declared dependencies
8. Deduplicate repeated undeclared references
9. Return sorted list of undeclared module names
10. Return error tuple if file doesn't exist or has syntax errors

**Test Assertions**:
- detects fully qualified module calls not in declarations
- detects struct references not declared
- resolves aliased short names correctly
- handles multi-alias forms when resolving
- detects module references in @behaviour
- detects module references in @spec typespecs
- detects module references in @type definitions
- detects module references in @callback definitions
- detects module references in defimpl
- excludes Elixir stdlib modules (Enum, Map, List, etc.)
- excludes Kernel module functions
- excludes Erlang modules (lowercase atoms)
- excludes the current module from undeclared list
- returns empty list when all deps are declared
- handles modules used in pattern matching
- handles modules in function guards
- deduplicates repeated undeclared references
- returns sorted list of undeclared modules
- returns error for invalid Elixir syntax
- returns error for non-existent file
- ignores dynamic module references (apply/3, etc.)
- handles module attribute references (@some_module)

## Dependencies

- File
- Code