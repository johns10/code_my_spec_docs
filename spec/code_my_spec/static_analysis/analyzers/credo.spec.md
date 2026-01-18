# CodeMySpec.StaticAnalysis.Analyzers.Credo

**Type**: module

Runs Credo static analysis for code consistency and style checks. Executes `mix credo suggest --format json --all --all-priorities`, captures stdout to a temporary file for reliable JSON parsing, then converts to Problems. Implements the AnalyzerBehaviour to provide pluggable static analysis capabilities with consistent error handling and result normalization.

## Delegates

None

## Functions

### run/2

Execute Credo analysis against a project and return normalized Problems.

```elixir
@spec run(Scope.t(), keyword()) :: {:ok, [Problem.t()]} | {:error, String.t()}
```

**Process**:
1. Extract project from scope
2. Verify project has code_repo configured, return error if missing
3. Generate temporary output file path for JSON results
4. Build command: `mix credo suggest --format json --all --all-priorities`
5. Execute command in project directory using System.cmd with cd option set to code_repo
6. Write stdout to temporary file for reliable JSON parsing
7. Read and decode JSON from temporary file
8. Extract issues array from JSON structure (handle both Credo 1.x and 2.x formats)
9. Map each issue through ProblemConverter.from_credo/1
10. Add project_id to each Problem struct
11. Clean up temporary file
12. Return {:ok, problems} on success or {:error, reason} on failure

**Test Assertions**:
- returns {:ok, list(Problem.t())} when Credo finds issues
- returns {:ok, []} when Credo finds no issues
- each Problem has source set to "credo"
- each Problem has source_type set to :static_analysis
- each Problem has valid file_path relative to project root
- each Problem has project_id matching scope project
- each Problem has severity mapped from Credo priority (>= 10: error, >= 5: warning, < 5: info)
- each Problem has category from Credo category field
- each Problem has rule from Credo check name
- returns {:error, String.t()} when project has no code_repo
- returns {:error, String.t()} when mix credo command fails
- returns {:error, String.t()} when JSON parsing fails
- handles malformed JSON gracefully
- handles missing project directory gracefully
- passes through options like config_file if provided
- cleans up temporary files even on errors
- handles Credo not being in mix.exs dependencies

### available?/1

Check if Credo is available and can be executed in the project.

```elixir
@spec available?(Scope.t()) :: boolean()
```

**Process**:
1. Extract project from scope
2. Return false if project is nil or has no code_repo
3. Check if project directory exists
4. Check if mix.exs exists in project directory
5. Check if deps/credo directory exists (indicates credo is installed)
6. Return true if all checks pass, false otherwise
7. Catch all errors and return false (never raise)

**Test Assertions**:
- returns true when Credo deps directory exists
- returns false when project has no code_repo
- returns false when project directory doesn't exist
- returns false when mix.exs doesn't exist
- does not raise exceptions
- executes quickly (< 100ms, just file checks)
- handles File.exists? errors gracefully

### name/0

Return the analyzer name for reporting and logging.

```elixir
@spec name() :: String.t()
```

**Process**:
1. Return "credo" string

**Test Assertions**:
- returns "credo"
- returns consistent value across calls
- value matches source field in generated Problems

## Dependencies

- CodeMySpec.Users.Scope
- CodeMySpec.Projects.Project
- CodeMySpec.Problems.Problem
- CodeMySpec.Problems.ProblemConverter