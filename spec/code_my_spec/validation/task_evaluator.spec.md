# CodeMySpec.Validation.TaskEvaluator

Evaluates agent tasks. Two entry points for the two hook events: `evaluate_component/2` resolves a component task from a transcript marker and delegates to the task module's `evaluate/3` (SubagentStop). `evaluate_sessions/2` looks up sessions by external conversation ID, evaluates the session stack at highest priority, deletes passing sessions, and returns combined feedback for failures (Stop).

## Functions

### evaluate_component/2

Resolve a component task from a transcript marker and evaluate it.

```elixir
@spec evaluate_component(Scope.t(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, String.t()} | :none
```

**Options**:
- `:transcript_path` - Path to the subagent transcript file (required)

**Process**:
1. Extract task marker from transcript via `Transcripts.TaskIdentifier.identify/1`
2. If no marker found, return `:none`
3. Map type name to module via `SessionType.mapper/0`
4. Look up component via `Components.get_component_by_module_name/2`
5. If component not found, return `:none`
6. Get component's files via `Utils.component_files/2`
7. Build session-like map: `%{component: component, project: scope.active_project}`
8. Call `module.evaluate(scope, session_map, [])` — evaluates against the task's own files
9. Return result as-is, rescue exceptions → `{:error, "Task evaluation failed: #{message}"}`

**Test Assertions**:
- resolves component from transcript marker and evaluates
- returns :none when transcript has no marker
- returns :none when task type not recognized
- returns :none when component not found in database
- returns {:ok, :valid} when task module passes
- returns {:ok, :invalid, errors} when task module finds issues
- returns {:error, reason} when task module errors
- rescues exceptions and returns {:error, message}
- evaluates against task's own files, not edited files from transcript

### evaluate_sessions/2

Look up sessions by external conversation ID, evaluate the session stack, delete passing sessions.

```elixir
@spec evaluate_sessions(Scope.t(), String.t()) :: {:ok, :valid} | {:error, String.t()}
```

**Process**:
1. List sessions filtered by `session_id` (external conversation ID)
2. If no sessions, return `{:ok, :valid}`
3. Get sessions at highest priority level (session stack)
4. For each session:
   - Enrich with component (look up by `component_module_name`) and project
   - Call `session.type.evaluate(scope, session, [])`
5. Delete passing sessions
6. If any failed, return `{:error, combined_feedback}` with failures grouped by task type
7. If all passed, return `{:ok, :valid}`

**Test Assertions**:
- returns {:ok, :valid} when no sessions found
- returns {:ok, :valid} when all sessions pass evaluation
- returns {:error, feedback} when any session fails
- deletes passing sessions after evaluation
- keeps failing sessions for re-evaluation
- evaluates only sessions at highest priority level
- filters sessions by external conversation ID
- enriches sessions with component and project before evaluation
- combines feedback from multiple failures
- rescues individual evaluation errors gracefully

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Sessions
- CodeMySpec.Sessions.SessionType
- CodeMySpec.Transcripts.TaskIdentifier
- CodeMySpec.Utils
