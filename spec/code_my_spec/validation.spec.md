# CodeMySpec.Validation

**Type**: context

Validates files edited during Claude Code sessions. Orchestrates the full validation flow: runs a generic pipeline (compile, tests, static analysis, BDD specs, spec validation) on all tracked file edits, persists discovered problems to the database, clears tracked file edits, triggers a full project sync so requirements reflect the latest state, and optionally evaluates task-specific criteria for subagent sessions identified by transcript markers. Called from the hook controller on Stop and SubagentStop events. Returns a block/allow decision for the Claude Code hook protocol.

## Functions

### run/2

Execute the full validation flow for a set of edited files.

```elixir
@spec run(Scope.t(), keyword()) :: {:ok, :valid} | {:error, [Problem.t()] | String.t()}
```

**Options**:
- `:files` - List of file paths to validate (overrides FileEdits lookup)
- `:transcript_path` - Subagent transcript path (triggers task evaluation via TaskContext)

**Process**:
1. Get files: use provided `:files` option, or fall back to `FileEdits.list_all/0` for all tracked edits
2. If no files, return `{:ok, :valid}` immediately
3. Run `Pipeline.run/3` on all files to get `[Problem.t()]`
4. Persist problems via `Problems.replace_problems_for_files/3`
5. Clear tracked file edits via `FileEdits.truncate_all/0`
6. Run full sync via `Sync.sync_all/2` (requirements read persisted problems)
7. If `:transcript_path` provided, resolve task via `TaskContext.resolve/2` and call `module.evaluate/3`
8. Decide: if problems exist, return `{:error, problems}`. If task evaluation failed, return `{:error, feedback}`. Otherwise return `{:ok, :valid}`

**Test Assertions**:
- returns `{:ok, :valid}` when no files to validate
- returns `{:ok, :valid}` when pipeline finds no problems and no task evaluation
- returns `{:error, problems}` when pipeline finds problems
- persists problems to database after pipeline runs
- clears all tracked file edits after persisting problems
- runs sync after persisting problems
- evaluates task when transcript_path is provided and TaskContext resolves
- returns `{:error, feedback}` when task evaluation is invalid
- skips task evaluation when no transcript_path provided
- skips task evaluation when TaskContext returns :none
- rescues task evaluation errors and returns `{:error, message}`
- uses provided files option instead of FileEdits lookup when given

### format_output/1

Format a validation result into the Claude Code hook response map.

```elixir
@spec format_output({:ok, :valid} | {:error, [Problem.t()] | String.t()}) :: map()
```

**Process**:
1. `{:ok, :valid}` → return empty map `%{}`
2. `{:error, problems}` when list → render via `ProblemRenderer.render_for_feedback/2` with context and max_problems, return `%{"decision" => "block", "reason" => rendered}`
3. `{:error, reason}` when binary → return `%{"decision" => "block", "reason" => reason}`

**Test Assertions**:
- returns empty map for valid result
- returns block decision with rendered problems for error with problem list
- returns block decision with reason string for error with string

## Dependencies

- CodeMySpec.AgentTasks.TaskContext
- CodeMySpec.FileEdits
- CodeMySpec.Problems
- CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.ProjectSync.Sync
- CodeMySpec.Validation.Pipeline

## Components

### CodeMySpec.Validation.Pipeline

Runs the validation pipeline on a set of files. Categorizes files by type, compiles the project, then runs tests, static analysis, BDD specs, and spec validation. Returns a flat list of all problems found, filtered to only the edited files.
