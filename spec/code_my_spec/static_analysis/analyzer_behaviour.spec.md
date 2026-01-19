# CodeMySpec.StaticAnalysis.AnalyzerBehaviour

**Type**: module

Behaviour defining the interface that all static analyzers must implement. Specifies callbacks for running analysis and checking availability. Each analyzer implements these callbacks to execute its specific tool (Credo, Boundary, Sobelow, or custom analyzers) and normalize results into Problem structs for consistent reporting. This behaviour enables pluggable static analysis with uniform error handling and result aggregation.

## Delegates

None - this module defines callbacks only.

## Functions

### run/2 (callback)

Execute the static analysis tool against a project and return normalized Problems. Implementations should invoke their specific tool, parse the output, and transform results into Problem structs using ProblemConverter or custom logic.

```elixir
@callback run(scope :: Scope.t(), opts :: keyword()) ::
  {:ok, [Problem.t()]} | {:error, String.t()}
```

**Process**:
1. Receive the scope containing active account and project context
2. Extract the project path from scope.project or options
3. Execute the analyzer's tool command (e.g., `mix credo --format json`)
4. Capture and parse the tool's output (JSON, plain text, or other format)
5. Transform each result into a Problem struct with appropriate severity, source, file_path, line, message, and category
6. Set source_type to :static_analysis and source to the tool name
7. Return `{:ok, [Problem.t()]}` on success or `{:error, reason}` if execution fails

**Test Assertions**:

### available?/1 (callback)

Check if the analyzer's tool is available and can be executed. Implementations should verify that the required executable or Mix task exists and is properly configured.

```elixir
@callback available?(scope :: Scope.t()) :: boolean()
```

**Process**:
1. Receive the scope containing project context
2. Check if the analyzer's tool is installed and accessible (e.g., verify Mix task exists, check for binary in PATH)
3. Optionally verify tool-specific configuration files exist (e.g., .credo.exs)
4. Return true if the tool can be executed, false otherwise

**Test Assertions**:

### name/0 (callback)

Return the human-readable name of the analyzer for reporting and logging purposes.

```elixir
@callback name() :: String.t()
```

**Process**:
1. Return a string identifying the analyzer (e.g., "Credo", "Boundary", "Sobelow")

**Test Assertions**:

## Dependencies

- CodeMySpec.Problems.Problem
- CodeMySpec.Users.Scope