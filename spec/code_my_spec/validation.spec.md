# CodeMySpec.Validation

**Type**: context

Validates files edited during Claude Code sessions. Parses transcripts to extract edited files, runs the generic validation pipeline, persists discovered problems, triggers a project sync, and evaluates agent tasks. Exposes two entry points — one for SubagentStop (component task from transcript marker) and one for Stop (session stack evaluation). Called from the hook controller.

## Functions

### validate_subagent/2

Handle SubagentStop: validate edited files and evaluate the component task.

```elixir
@spec validate_subagent(Scope.t(), keyword()) :: {:ok, :valid} | {:error, [Problem.t()] | String.t()}
```

**Options**:
- `:transcript_path` - Path to the subagent's transcript file (required)

**Process**:
1. Parse transcript to extract edited files via `FileExtractor`
2. If no edited files, return `{:ok, :valid}`
3. Run `Pipeline.run/2` on edited files → `pipeline_problems`
4. Resolve component task from transcript marker via `TaskEvaluator.evaluate_component/2`  → `task_result`
5. Persist `pipeline_problems` via `Problems.replace_problems_for_files/3`
6. Run `Sync.sync_all/1`
7. Combine: if `pipeline_problems` exist, return `{:error, problems}`. If `task_result` is error, return `{:error, feedback}`. Otherwise `{:ok, :valid}`

**Test Assertions**:
- returns `{:ok, :valid}` when transcript has no edited files
- returns `{:ok, :valid}` when pipeline and component evaluation both pass
- returns `{:error, problems}` when pipeline finds problems
- returns `{:error, feedback}` when component task evaluation fails
- runs pipeline on all edited files from transcript
- evaluates component task on task's own files (not edited files)
- persists pipeline problems scoped to edited files
- runs sync after persisting problems
- returns `{:ok, :valid}` when no task marker found in transcript

### validate_stop/2

Handle Stop: validate edited files and evaluate the session stack.

```elixir
@spec validate_stop(Scope.t(), keyword()) :: {:ok, :valid} | {:error, [Problem.t()] | String.t()}
```

**Options**:
- `:transcript_path` - Path to the main session's transcript file (required)
- `:session_id` - External conversation ID for session lookup (required)

**Process**:
1. Parse transcript to extract edited files via `FileExtractor`
2. If no edited files and no sessions, return `{:ok, :valid}`
3. Run `Pipeline.run/2` on edited files → `pipeline_problems`
4. Evaluate session stack via `TaskEvaluator.evaluate_sessions/2` using `:session_id` → `session_result`
5. Persist `pipeline_problems` via `Problems.replace_problems_for_files/3`
6. Run `Sync.sync_all/1`
7. Combine: if `pipeline_problems` exist, return `{:error, problems}`. If `session_result` is error, return `{:error, feedback}`. Otherwise `{:ok, :valid}`

**Test Assertions**:
- returns `{:ok, :valid}` when transcript has no edited files and no active sessions
- returns `{:ok, :valid}` when pipeline passes and all sessions pass
- returns `{:error, problems}` when pipeline finds problems
- returns `{:error, feedback}` when session evaluation fails
- runs pipeline on all edited files from transcript
- evaluates session stack filtered by session_id
- persists pipeline problems scoped to edited files
- runs sync after persisting problems
- returns `{:ok, :valid}` when no active sessions found

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

- CodeMySpec.Problems
- CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.ProjectSync.Sync
- CodeMySpec.Transcripts.ClaudeCode.FileExtractor
- CodeMySpec.Transcripts.ClaudeCode.Transcript
- CodeMySpec.Validation.Pipeline
- CodeMySpec.Validation.TaskEvaluator

## Components

### CodeMySpec.Validation.Pipeline

Runs the generic validation pipeline on a set of files. Categorizes files by type, compiles the project, then runs tests, static analysis (Credo, Sobelow), BDD specs, and spec document validation. Returns a flat list of all problems found, filtered to only the provided files.

### CodeMySpec.Validation.TaskEvaluator

Evaluates agent tasks. Two entry points: `evaluate_component/2` resolves a component task from a transcript marker and delegates to the task module's `evaluate/3`. `evaluate_sessions/2` looks up sessions by external conversation ID, evaluates the session stack (highest priority), deletes passing sessions, and returns combined feedback for failures.
