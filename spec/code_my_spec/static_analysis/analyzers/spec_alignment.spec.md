# CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment

## Type

module

Custom analyzer that validates implementation matches specification definitions. Checks function signatures, type specs, and test assertions against spec documents. Reads spec files from the docs/spec directory, parses them using the Documents context, then compares parsed functions against actual implementation and test files to detect misalignment. Reports Problems for missing functions, mismatched specs, and missing or extra test assertions.

## Delegates

None - all functionality is implemented directly.

## Functions

### run/2

Execute the spec alignment analyzer against a project and return Problems for any misalignments between specs and implementation.

```elixir
@spec run(Scope.t(), keyword()) :: {:ok, [Problem.t()]} | {:error, String.t()}
```

**Process**:
1. Extract project from scope and verify it has code_repo configured
2. Determine spec directory path (docs/spec within project code_repo)
3. Find all .spec.md files recursively in the spec directory
4. For each spec file:
   - Read and parse the spec document using CodeMySpec.Documents
   - Extract the module name from the spec file path and metadata
   - Determine implementation file path from module name
   - Determine test file path from module name
   - Compare spec functions against implementation using CodeMySpec.Code.Elixir.get_functions/1
   - Compare spec test_assertions against test file using CodeMySpec.Code.Elixir.get_test_assertions/1
   - Generate Problems for any misalignments found
5. Aggregate all Problems from all spec files
6. Set source_type to :static_analysis and source to "spec_alignment" on all Problems
7. Return {:ok, [Problem.t()]} with all detected alignment issues

**Test Assertions**:
- returns empty list when all specs match implementation perfectly
- detects missing function implementations (function in spec but not in code)
- detects extra function implementations (public function in code but not in spec)
- detects mismatched @spec type signatures between spec and implementation
- detects missing test assertions (assertion in spec but test not found)
- detects extra test assertions (test exists but not documented in spec)
- handles spec files for modules that don't exist yet (no Problems generated)
- handles modules without spec files (no Problems generated)
- handles spec files with no Functions section gracefully
- handles implementation files with no public functions gracefully
- handles test files that don't exist yet (no Problems generated)
- sets source to "spec_alignment" on all Problems
- sets source_type to :static_analysis on all Problems
- sets appropriate severity levels (error for missing impl, warning for extra functions)
- includes file_path and line numbers in Problems when available
- handles parsing errors in spec files gracefully (returns Problem about invalid spec)
- handles parsing errors in implementation files gracefully
- respects opts[:paths] to limit analysis to specific directories
- returns error when spec directory doesn't exist

### available?/1

Check if the spec alignment analyzer can run. Always returns true since it uses built-in parsing capabilities without external dependencies.

```elixir
@spec available?(Scope.t()) :: boolean()
```

**Process**:
1. Check if spec directory exists (docs/spec)
2. Returns true if directory exists

**Test Assertions**:
- returns true when project spec directory 
- returns false when spec directory doesn't exist
- does not raise exceptions
- executes quickly without blocking

### name/0

Return the human-readable name of the analyzer.

```elixir
@spec name() :: String.t()
```

**Process**:
1. Return "spec_alignment" as the analyzer name

**Test Assertions**:
- returns "spec_alignment"
- returns consistent value across multiple calls

## Dependencies

- CodeMySpec.Users.Scope
- CodeMySpec.Projects.Project
- CodeMySpec.Problems.Problem
- CodeMySpec.Documents
- CodeMySpec.Code.Elixir
- CodeMySpec.Utils.Paths
- File
- Path