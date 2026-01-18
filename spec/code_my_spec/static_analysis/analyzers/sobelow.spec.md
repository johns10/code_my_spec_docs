# CodeMySpec.StaticAnalysis.Analyzers.Sobelow

**Type**: module

Runs Sobelow security scanner for common Phoenix vulnerabilities. Executes `mix sobelow --format json --private`, captures stdout to a temporary file for reliable JSON parsing, then converts to Problems. Implements the AnalyzerBehaviour to provide consistent interface for static analysis execution.

## Functions

### run/2

Execute Sobelow security scanner against a project and return normalized Problems.

```elixir
@spec run(Scope.t(), keyword()) :: {:ok, [Problem.t()]} | {:error, String.t()}
```

**Process**:
1. Extract project path from scope.project.code_repo
2. Generate temporary file path for JSON output
3. Execute `mix sobelow --format json --private` in project directory using System.cmd
4. Write stdout to temporary file for reliable JSON parsing
5. Read and parse JSON from temporary file into list of vulnerability findings
6. Convert each finding to Problem struct with:
   - severity: map from Sobelow severity (high -> :error, medium -> :warning, low -> :info)
   - source: "sobelow"
   - source_type: :static_analysis
   - file_path: extract from finding's file field
   - line: extract from finding's line field
   - message: extract finding's vulnerability description
   - category: "security"
   - rule: extract finding's type/check name
   - metadata: preserve full finding data
7. Delete temporary file
8. Return `{:ok, [Problem.t()]}` with converted problems

**Test Assertions**:
- returns `{:ok, []}` when no security issues found
- returns `{:ok, list(Problem.t())}` when vulnerabilities detected
- sets severity to :error for high severity findings
- sets severity to :warning for medium severity findings
- sets severity to :info for low severity findings
- sets source to "sobelow" for all problems
- sets source_type to :static_analysis for all problems
- sets category to "security" for all problems
- extracts file path and line number correctly
- preserves vulnerability type in rule field
- stores full finding data in metadata
- returns `{:error, String.t()}` when mix task fails
- returns `{:error, String.t()}` when project path is invalid
- returns `{:error, String.t()}` when JSON parsing fails
- cleans up temporary file even when errors occur
- handles missing file or line information gracefully
- respects timeout option from keyword list
- handles Sobelow not being installed gracefully

### available?/1

Check if Sobelow is available and can be executed in the project.

```elixir
@spec available?(Scope.t()) :: boolean()
```

**Process**:
1. Extract project from scope
2. Return false if project is nil or has no code_repo
3. Check if project directory exists
4. Check if mix.exs exists in project directory
5. Check if deps/sobelow directory exists (indicates sobelow is installed)
6. Return true if all checks pass, false otherwise
7. Catch all errors and return false (never raise)

**Test Assertions**:
- returns true when sobelow deps directory exists
- returns false when sobelow deps directory missing
- returns false when project path is invalid
- returns false when mix.exs is missing
- does not raise exceptions
- executes quickly (< 100ms, just file checks)

### name/0

Return the human-readable name of the analyzer.

```elixir
@spec name() :: String.t()
```

**Process**:
1. Return "sobelow"

**Test Assertions**:
- returns "sobelow"
- returns consistent value across calls

## Dependencies

- CodeMySpec.Users.Scope
- CodeMySpec.Problems.Problem
- CodeMySpec.StaticAnalysis.AnalyzerBehaviour
- System (for executing mix commands)
- File (for temporary file operations)
- Jason (for JSON parsing)