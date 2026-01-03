# CodeMySpec.Code

**Type**: context

Provides AST operations on code files for extracting structured information like dependencies, functions, and test assertions. Enables static analysis and metadata extraction across different programming languages.

## Components

### CodeMySpec.Code.ElixirAST

Performs AST operations specifically for Elixir source files, extracting module dependencies, function definitions with specs, and test assertions.

## Delegates

- get_dependencies/1: CodeMySpec.Code.Elixir.get_dependencies/1
- get_functions/1: CodeMySpec.Code.Elixir.get_functions/1
- get_test_assertions/1: CodeMySpec.Code.Elixir.get_test_assertions/1
- get_undeclared_dependencies/1: CodeMySpec.Code.Elixir.get_undeclared_dependencies/1

## Functions

### get_dependencies/1

Extract module dependencies from an Elixir source file.

```elixir
@spec get_dependencies(file_path :: String.t()) :: {:ok, [String.t()]} | {:error, term()}
```

**Process**:
1. Delegate to CodeMySpec.Code.Elixir.get_dependencies/1
2. Parse the Elixir file into an AST
3. Traverse AST to find alias, import, and use statements
4. Extract module names from these statements
5. Return list of fully qualified module names

**Test Assertions**:
- get_dependencies/1 returns list of aliased modules
- get_dependencies/1 returns list of imported modules
- get_dependencies/1 returns list of used modules
- get_dependencies/1 returns error for invalid Elixir syntax
- get_dependencies/1 returns error for non-existent file
- get_dependencies/1 handles files with no dependencies

### get_functions/1

Extract public function definitions with their specs from an Elixir source file.

```elixir
@spec get_functions(file_path :: String.t()) ::
  {:ok, [%{name: atom(), arity: integer(), spec: String.t() | nil}]} | {:error, term()}
```

**Process**:
1. Delegate to CodeMySpec.Code.Elixir.get_functions/1
2. Parse the Elixir file into an AST
3. Traverse AST to find public function definitions (def/defp)
4. For each function, extract name, arity, and associated @spec
5. Filter to only public functions (def, not defp)
6. Return list of function metadata maps

**Test Assertions**:
- get_functions/1 extracts public function names and arities
- get_functions/1 excludes private functions (defp)
- get_functions/1 includes @spec when present
- get_functions/1 handles functions without @spec
- get_functions/1 handles multi-clause functions correctly
- get_functions/1 returns error for invalid Elixir syntax
- get_functions/1 returns empty list for modules with no public functions

### get_test_assertions/1

Extract test case names and assertions from an Elixir test file.

```elixir
@spec get_test_assertions(file_path :: String.t()) ::
  {:ok, [%{test_name: String.t(), description: String.t()}]} | {:error, term()}
```

**Process**:
1. Delegate to CodeMySpec.Code.Elixir.get_test_assertions/1
2. Parse the Elixir test file into an AST
3. Traverse AST to find test macro calls (test, describe)
4. Extract test names and their descriptions
5. Group tests by describe blocks if present
6. Return list of test metadata maps

**Test Assertions**:
- get_test_assertions/1 extracts test names from test blocks
- get_test_assertions/1 extracts describe block groupings
- get_test_assertions/1 handles nested describe blocks
- get_test_assertions/1 includes test descriptions
- get_test_assertions/1 returns error for invalid Elixir syntax
- get_test_assertions/1 returns error for non-test files
- get_test_assertions/1 returns empty list for test files with no tests

### get_undeclared_dependencies/1

Extract module references that are used in the code but not declared in alias, import, or use statements.

```elixir
@spec get_undeclared_dependencies(file_path :: String.t()) :: {:ok, [String.t()]} | {:error, term()}
```

**Process**:
1. Delegate to CodeMySpec.Code.Elixir.get_undeclared_dependencies/1
2. Get all declared dependencies from the file
3. Build alias resolution map for short name -> full module name mappings
4. Traverse AST to collect all module references (function calls, structs, behaviours, typespecs)
5. Resolve aliased short names to full module names
6. Filter out Elixir standard library modules (optional)
7. Compare used modules against declared dependencies
8. Return list of modules used but not declared

**Test Assertions**:
- get_undeclared_dependencies/1 detects fully qualified module calls not in declarations
- get_undeclared_dependencies/1 detects struct references not declared
- get_undeclared_dependencies/1 resolves aliased short names correctly
- get_undeclared_dependencies/1 handles multi-alias forms when resolving
- get_undeclared_dependencies/1 detects module references in @behaviour
- get_undeclared_dependencies/1 detects module references in @spec typespecs
- get_undeclared_dependencies/1 detects module references in @type definitions
- get_undeclared_dependencies/1 excludes Elixir stdlib modules (configurable)
- get_undeclared_dependencies/1 returns empty list when all deps are declared
- get_undeclared_dependencies/1 handles modules used in pattern matching
- get_undeclared_dependencies/1 handles modules in function guards
- get_undeclared_dependencies/1 deduplicates repeated undeclared references
- get_undeclared_dependencies/1 returns error for invalid Elixir syntax
- get_undeclared_dependencies/1 returns error for non-existent file
- get_undeclared_dependencies/1 ignores dynamic module references (apply/3, etc.)

## Dependencies

- No external context dependencies
