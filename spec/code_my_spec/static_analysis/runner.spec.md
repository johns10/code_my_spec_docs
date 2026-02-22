# CodeMySpec.StaticAnalysis.Runner

**Type**: module

Orchestrates execution of static analyzers against a project. Handles parallel execution, error isolation, and result aggregation.

## Functions

### run_all/2

Execute all available static analyzers against a project in parallel.

```elixir
@spec run_all(Scope.t(), keyword()) :: {:ok, [Problem.t()]} | {:error, term()}
```

**Process**:
1. Get active project from scope
2. Verify project has code_repo configured
3. Get list of all registered analyzers
4. Filter analyzers to only those that are available (check dependencies installed)
5. Spawn parallel tasks for each available analyzer using Task.async_stream
6. Collect results from all tasks with timeout protection
7. Flatten all Problems from successful analyzers
8. Log warnings for any analyzers that failed or timed out
9. Return aggregated list of Problems

**Test Assertions**:
- returns empty list when no analyzers are available
- executes all available analyzers in parallel
- aggregates Problems from multiple analyzers
- filters out analyzers that aren't available
- continues execution when one analyzer fails (error isolation)
- respects timeout option for slow analyzers
- returns error when project has no code_repo
- logs warnings for failed analyzers
- handles concurrent execution without race conditions

### run/3

Execute a specific static analyzer against a project.

```elixir
@spec run(Scope.t(), atom(), keyword()) :: {:ok, [Problem.t()]} | {:error, term()}
```

**Process**:
1. Get active project from scope
2. Resolve analyzer module from atom name (e.g., :credo -> CodeMySpec.StaticAnalysis.Analyzers.Credo)
3. Check if analyzer is available by calling its available?/1 callback
4. Return error if analyzer is not available
5. Execute analyzer by calling its run/2 callback with project and options
6. Validate all returned Problems have project_id set
7. Return Problems list or error

**Test Assertions**:
- executes specified analyzer and returns Problems
- returns error when analyzer name is invalid
- returns error when analyzer is not available
- returns error when project has no code_repo
- passes options through to analyzer
- validates Problems have project_id set
- handles analyzer execution failures gracefully
- supports all registered analyzer types

### list_analyzers/0

Get list of all registered static analyzer modules.

```elixir
@spec list_analyzers() :: [module()]
```

**Process**:
1. Return hardcoded list of analyzer modules in execution order
2. List includes: Credo, Boundary, Sobelow, SpecAlignment

**Test Assertions**:
- returns list of all analyzer modules
- includes all expected analyzer types
- returns modules in consistent order

## Dependencies

- CodeMySpec.Users.Scope
- CodeMySpec.Projects.Project
- CodeMySpec.Problems.Problem
- CodeMySpec.StaticAnalysis.AnalyzerBehaviour
- CodeMySpec.StaticAnalysis.Analyzers.Credo
- CodeMySpec.StaticAnalysis.Analyzers.Sobelow
- CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment
