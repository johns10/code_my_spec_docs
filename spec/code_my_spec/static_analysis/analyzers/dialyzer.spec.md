# CodeMySpec.StaticAnalysis.Analyzers.Dialyzer

**Type**: module

Runs Dialyzer for type checking and discrepancy detection. Implements the AnalyzerBehaviour to execute `mix dialyzer --format short` against a project codebase and transform the output into normalized Problem structs. The `--format short` option outputs warnings in Elixir term format, which can be reliably parsed using Code.eval_string/1. Dialyzer performs success typing analysis to detect type inconsistencies, unreachable code, and contract violations without requiring explicit type annotations.

## Delegates

None - implements AnalyzerBehaviour callbacks directly.

## Functions

### run/2

Execute Dialyzer analysis against a project and return normalized Problems.

Uses System.cmd to execute `mix dialyzer --format short` in the project directory, collects the output, parses Dialyzer warnings into structured data, and converts each warning to a Problem struct using ProblemConverter.from_dialyzer/1.

```elixir
@spec run(scope :: Scope.t(), opts :: keyword()) ::
  {:ok, [Problem.t()]} | {:error, String.t()}
```

**Process**:
1. Extract project directory from opts[:cwd] or default to current working directory
2. Check if mix executable is available using System.find_executable/1
3. Call System.cmd with `mix dialyzer --format short` in the project directory
4. Configure cmd options: stderr_to_stdout, cd (project directory), env (MIX_ENV=test)
5. Handle exit codes: 0 (no warnings), 2 (warnings found), other (error)
6. Parse collected output by splitting into lines and filtering for Dialyzer warnings
7. Parse each warning line as Elixir terms using Code.eval_string/1 to extract file, line, type, and message
8. Fall back to regex parsing for non-term output formats
9. Transform each warning map into a Problem struct using ProblemConverter.from_dialyzer/1
10. Return {:ok, list(Problem.t())} on success
11. Return {:error, reason} if execution fails or Dialyzer is not available

**Test Assertions**:
- returns {:ok, list(Problem.t())} when Dialyzer executes successfully
- returns empty list when no type discrepancies found
- each Problem has severity set to :warning
- each Problem has source_type set to :static_analysis
- each Problem has source set to "dialyzer"
- each Problem has valid file_path and message
- each Problem has category set to "type"
- returns {:error, String.t()} when Dialyzer is not installed
- returns {:error, String.t()} when PLT is missing or corrupted
- returns {:error, String.t()} when project path does not exist
- respects cwd option to run in specified directory
- handles Dialyzer output parsing errors gracefully

### available?/1

Check if Dialyzer is available and can be executed in the project.

```elixir
@spec available?(scope :: Scope.t()) :: boolean()
```

**Process**:
1. Extract project from scope
2. Return false if project is nil or has no code_repo
3. Check if project directory exists
4. Check if mix.exs exists in project directory
5. Check if deps/dialyxir directory exists (indicates dialyxir is installed)
6. Return true if all checks pass, false otherwise
7. Catch all errors and return false (never raise)

**Test Assertions**:
- returns true when dialyxir deps directory exists
- returns false when project directory doesn't exist
- returns false when dialyxir dependency not installed
- does not raise exceptions
- executes quickly (< 100ms, just file checks)
- does not modify system state or build PLT

### name/0

Return the human-readable name of the analyzer.

```elixir
@spec name() :: String.t()
```

**Process**:
1. Return the string "dialyzer"

**Test Assertions**:
- returns "dialyzer"
- matches the source field used in generated Problems
- returns consistent value across calls

## Dependencies

- CodeMySpec.Problems.Problem
- CodeMySpec.Problems.ProblemConverter
- CodeMySpec.Users.Scope
- CodeMySpec.StaticAnalysis.AnalyzerBehaviour