# CodeMySpec.AgentTasks.ProblemFeedback

## Type

module

Shared problem feedback for agent task evaluation. Queries persisted problems for component files and formats actionable feedback for the model. Each agent task type (code, test, spec) has different rules for which problems to include — code tasks include all problems, test tasks filter out test failures (TDD mode), and spec tasks check only the spec file.

## Dependencies

- CodeMySpec.Problems
- CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.Utils

## Functions

### for_code_task/3

Query all problems for a component's code file and test file.

```elixir
@spec for_code_task(Scope.t(), Component.t(), Project.t()) :: String.t() | nil
```

**Process**:
1. Get code_file and test_file paths via `Utils.component_files/2`
2. Query `Problems.list_project_problems/2` for each file path
3. Combine both problem lists
4. If no problems, return `nil`
5. If problems exist, format via `ProblemRenderer.render_for_feedback/2` with context and max_problems: 20

**Test Assertions**:
- returns nil when no problems exist for code or test files
- returns formatted feedback when code file has problems
- returns formatted feedback when test file has problems
- includes problems from both code and test files in combined feedback
- includes all problem types (compiler, credo, sobelow, test failures)

### for_test_task/3

Query problems for a component's test file, excluding test failures.

```elixir
@spec for_test_task(Scope.t(), Component.t(), Project.t()) :: String.t() | nil
```

**Process**:
1. Get test_file path via `Utils.component_files/2`
2. Query `Problems.list_project_problems/2` for the test file
3. Reject problems with `source_type == :test` (test failures expected in TDD mode)
4. If no remaining problems, return `nil`
5. If problems exist, format via `ProblemRenderer.render_for_feedback/2`

**Test Assertions**:
- returns nil when no problems exist for test file
- returns formatted feedback when test file has compilation errors
- returns formatted feedback when test file has credo issues
- filters out test failures (source_type == :test)
- returns nil when only test failures exist

### for_spec_task/3

Query problems for a component's spec file.

```elixir
@spec for_spec_task(Scope.t(), Component.t(), Project.t()) :: String.t() | nil
```

**Process**:
1. Get spec_file path via `Utils.component_files/2`
2. Query `Problems.list_project_problems/2` for the spec file
3. If no problems, return `nil`
4. If problems exist, format via `ProblemRenderer.render_for_feedback/2`

**Test Assertions**:
- returns nil when no problems exist for spec file
- returns formatted feedback when spec file has validation problems

### combine/2

Merge requirement feedback and problem feedback into an evaluate result tuple.

```elixir
@spec combine(String.t() | nil, String.t() | nil) :: {:ok, :valid} | {:ok, :invalid, String.t()}
```

**Process**:
1. If both nil, return `{:ok, :valid}`
2. If only requirement feedback, return `{:ok, :invalid, req_feedback}`
3. If only problem feedback, return `{:ok, :invalid, problem_feedback}`
4. If both present, join with double newline and return `{:ok, :invalid, combined}`

**Test Assertions**:
- returns {:ok, :valid} when both inputs are nil
- returns {:ok, :invalid, feedback} with requirement feedback when only requirements fail
- returns {:ok, :invalid, feedback} with problem feedback when only problems exist
- returns {:ok, :invalid, feedback} combining both when requirements fail and problems exist
