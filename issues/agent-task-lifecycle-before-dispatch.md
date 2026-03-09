# Agent Task Lifecycle: `before_dispatch` Callback

## Problem

The dispatch flow currently goes straight from "requirement is unsatisfied" to "dispatch the task module." There's no opportunity for a task to refresh stale data before dispatch, which leads to unnecessary agent cycles.

Concrete example: `FixBddSpecs` gets dispatched because `BddSpecPassingChecker` sees stale spex problems from session start. The specs might actually pass now (all components were implemented since then), but we dispatched a fix agent anyway.

More generally: any task whose checker depends on cached/stored results needs a way to say "let me refresh my data first — I might not even be needed."

## Design

### New optional callback

```elixir
@callback before_dispatch(Scope.t(), map(), keyword()) :: :ok | :skip | {:error, String.t()}
```

- `:ok` — proceed with dispatch (default for all tasks)
- `:skip` — data was refreshed and the requirement is now satisfied; don't dispatch
- `{:error, reason}` — hard precondition failure; don't dispatch, surface the error

### Default implementation

Tasks that don't define `before_dispatch` get `:ok` — no change in behavior. This is opt-in.

### Contract rules

1. `before_dispatch` owns ALL of its logic internally — refresh data, re-evaluate the requirement, determine the outcome
2. The caller (Dispatch) does NOT re-walk the graph on `:skip` — it just signals back to `StartImplementation` which handles the re-walk
3. `before_dispatch` should be resilient — catch internal failures, log, and return `:ok` to proceed with dispatch rather than blocking
4. Reserve `{:error, reason}` for hard precondition failures where dispatching would be pointless (e.g., "server not running" for QA tasks)

### Call site in Dispatch

`before_dispatch` is called in `Dispatch.command/3` after `build_session` but before calling `task_module.command/3`. This applies to all scope types (`:local`, `:orchestrate`, `:children`).

For `:local` and `:orchestrate`, the `satisfied_by` module is called directly.
For `:children`, the parent task module is called (the one on the requirement).

### Signal propagation

When `before_dispatch` returns `:skip`:

1. `Dispatch.command` returns `{:ok, :skip}`
2. `StartImplementation.dispatch_or_complete` sees `:skip`, re-walks the graph via `get_next_actions`
3. Since requirements were recalculated inside `before_dispatch`, the re-walk sees fresh data
4. The next actionable requirement is returned (could be the next phase in the same story, or the next story)

This works because `NextActionable.call` always loads requirements fresh from the DB via `Repo.preload(:requirements)`.

No skip count or loop guard needed. The re-walk is safe by construction: `before_dispatch` only returns `:skip` after it has satisfied the requirement in the DB. The rescue clause ensures failures return `:ok` (proceed with dispatch), never a false `:skip`. Re-walking is just another `get_next_actions` call — cheap DB queries that skip past satisfied requirements.

## BDD Spec Strategy

The `before_dispatch` callback changes how and when BDD specs run:

| Level | Requirement | Checker | Task | `before_dispatch` runs |
|-------|------------|---------|------|----------------------|
| Story | `bdd_specs_passing` | `BddSpecPassingChecker` | `FixBddSpecs` | Story-scoped spex files |
| Project | `all_bdd_specs_passing` | `AllBddSpecsPassingChecker` | `FixAllBddSpecs` | `Pipeline.run_all_spex` (all spex) |

### Project-level requirement: `all_bdd_specs_passing`

New project requirement inserted after `all_stories_complete`:

```
... → all_stories_complete → all_bdd_specs_passing → qa_journey_plan → ...
```

- **Checker:** `AllBddSpecsPassingChecker` — queries `Problems.list_project_problems(scope, source: "spex")`, satisfied when no spex problems exist
- **Task:** `FixAllBddSpecs` — same prompt pattern as `FixBddSpecs` but project-scoped (all stories, not one)
- **`before_dispatch`:** calls `Pipeline.run_all_spex`, stores problems, recalculates project requirements, returns `:skip` if all pass

This is where `run_all_spex` actually belongs — not at session start, but as a `before_dispatch` on the project-level requirement that fires exactly when the graph reaches it (after all stories complete).

### Removing `run_all_spex` from session start

Currently `StartAgentTask.run_project_task` calls `Pipeline.run_all_spex` on every `/start-implementation`. With `before_dispatch` handling spex at both story and project levels, this can be removed:

- **Story-level spex** — `FixBddSpecs.before_dispatch` runs story-scoped spex when the graph reaches `bdd_specs_passing` (after `component_complete` is satisfied)
- **Project-level spex** — `FixAllBddSpecs.before_dispatch` runs all spex when the graph reaches `all_bdd_specs_passing` (after `all_stories_complete`)
- **Session start** — no longer needs to run spex. The graph walk won't reach `bdd_specs_passing` until components are done, so there's no need for spex results upfront.

This eliminates the expensive `run_all_spex` from every session start — specs only run when the graph actually needs them.

## Implementation Steps

### 1. Add `before_dispatch` detection in Dispatch

**File:** `lib/code_my_spec/project_coordinator/dispatch.ex`

Add a private function mirroring the existing `has_function?` pattern:

```elixir
defp call_before_dispatch(task_module, scope, session, opts) do
  if has_function?(task_module, :before_dispatch, 3) do
    task_module.before_dispatch(scope, session, opts)
  else
    :ok
  end
end
```

### 2. Wire into `command_local`

**File:** `lib/code_my_spec/project_coordinator/dispatch.ex`

```elixir
defp command_local(req, scope, parent_session) do
  Logger.info("[Dispatch] command :local #{req.name} → #{inspect(req.satisfied_by)}")
  session = build_session(req, scope, parent_session)

  case call_before_dispatch(req.satisfied_by, scope, session, []) do
    :ok -> req.satisfied_by.command(scope, session, skip_sync: true)
    :skip -> {:ok, :skip}
    {:error, reason} -> {:error, reason}
  end
end
```

### 3. Wire into `command_orchestrate`

**File:** `lib/code_my_spec/project_coordinator/dispatch.ex`

Same pattern — call `before_dispatch` before the orchestrate logic. If `:skip`, return `{:ok, :skip}` without writing prompt files or recording tasks.

### 4. Wire into `command_children`

**File:** `lib/code_my_spec/project_coordinator/dispatch.ex`

Call `before_dispatch` on the parent task module (the one on the `:children` requirement) before calling `command` and orchestrating children.

### 5. Handle `:skip` in StartImplementation

**File:** `lib/code_my_spec/agent_tasks/start_implementation.ex`

```elixir
defp dispatch(env, scope) do
  case ProjectCoordinator.get_next_actions(scope) do
    {:ok, %Requirement{} = req} ->
      case Dispatch.command(req, scope, %{}) do
        {:ok, :skip} ->
          Logger.info("[StartImplementation] before_dispatch skipped #{req.name}, re-walking")
          dispatch(env, scope)

        {:ok, prompt} ->
          write_status(env, scope, req)
          {:ok, prompt}

        {:error, reason} ->
          {:error, reason}
      end

    :complete -> ...
    {:error, reason} -> ...
  end
end
```

Same pattern for `dispatch_or_complete` (the evaluate path).

### 6. Implement `FixBddSpecs.before_dispatch`

**File:** `lib/code_my_spec/agent_tasks/fix_bdd_specs.ex`

```elixir
def before_dispatch(scope, session, _opts) do
  # Run spex for the story's spec files to get fresh results
  story = session[:story] || find_story(scope, session)

  if is_nil(story) do
    Logger.info("[FixBddSpecs] No story in session, skipping spex refresh")
    :ok
  else
    refresh_spex_for_story(scope, story)
    # Recalculate the story's requirements with fresh problem data
    recalculate_story_requirements(scope, story)
    # Check if bdd_specs_passing is now satisfied
    if spex_now_passing?(scope, story), do: :skip, else: :ok
  end
rescue
  e ->
    Logger.warning("[FixBddSpecs] before_dispatch failed: #{Exception.message(e)}, proceeding")
    :ok
end
```

Private helpers:

- `refresh_spex_for_story/2` — find story's spex files, run them via `Pipeline.run_spex`, store problems via `Problems.replace_problems_for_files`
- `recalculate_story_requirements/2` — call `RequirementsSync.recalculate_story_requirements` (or equivalent) for the story
- `spex_now_passing?/2` — re-query `Problems.list_project_problems(scope, source: "spex")` and check if any relevant failures remain (same logic as `evaluate`)
- `find_story/2` — derive story from session's component via `Stories` query

### 7. Ensure story context is available in session

**File:** `lib/code_my_spec/project_coordinator/dispatch.ex` — `build_session/3`

Currently, when a requirement has `story_id`, the session gets `story_id` and the story's component. Verify that `FixBddSpecs.before_dispatch` receives enough context to identify the story.

The `bdd_specs_passing` requirement has `story_id` set (it's a story-level requirement), so `build_session` will include `story_id` and load the story's component. The session map will have the story context.

### 8. Add `recalculate_story_requirements` if needed

**File:** `lib/code_my_spec/requirements/sync.ex`

Check if a story-level recalculation function exists. If not, add one that:
1. Clears the story's requirements
2. Re-evaluates each requirement definition (which calls the checker)
3. Persists updated requirements

This is needed so that after `before_dispatch` refreshes spex problems, the `bdd_specs_passing` requirement's `satisfied` field gets updated in the DB before `NextActionable` re-walks.

### 9. Add `AllBddSpecsPassingChecker`

**File:** `lib/code_my_spec/requirements/all_bdd_specs_passing_checker.ex` (new)

Implements `CheckerBehaviour`. Receives `%Project{}` as entity.

```elixir
def check(_definition, %Project{} = project, _opts) do
  scope = Scope.for_project(project)
  problems = Problems.list_project_problems(scope, source: "spex")

  if Enum.empty?(problems) do
    Requirement.ok()
  else
    Requirement.error(["#{length(problems)} BDD spec failure(s) remain"])
  end
end
```

### 10. Add `FixAllBddSpecs` agent task

**File:** `lib/code_my_spec/agent_tasks/fix_all_bdd_specs.ex` (new)

Same pattern as `FixBddSpecs` but project-scoped — shows all failing spex across all stories.

```elixir
def before_dispatch(scope, _session, _opts) do
  # Run ALL spex — this is the project-level full refresh
  {:ok, _problems} = Pipeline.run_all_spex(scope)
  # Recalculate project requirements so checker sees fresh data
  recalculate_project_requirements(scope)
  # Check if all spex now pass
  problems = Problems.list_project_problems(scope, source: "spex")
  if Enum.empty?(problems), do: :skip, else: :ok
rescue
  e ->
    Logger.warning("[FixAllBddSpecs] before_dispatch failed: #{Exception.message(e)}, proceeding")
    :ok
end
```

`command/3` and `evaluate/3` follow the same structure as `FixBddSpecs` but without story filtering — all spex failures are included.

### 11. Add `all_bdd_specs_passing` requirement definition

**File:** `lib/code_my_spec/requirements/requirement_definition_data.ex`

```elixir
def all_bdd_specs_passing do
  {:ok, definition} =
    RequirementDefinition.new(%{
      name: "all_bdd_specs_passing",
      checker: AllBddSpecsPassingChecker,
      satisfied_by: CodeMySpec.AgentTasks.FixAllBddSpecs,
      artifact_type: :tests,
      description: "All BDD specs pass across all stories",
      prerequisites: ["all_stories_complete"],
      scope: :orchestrate
    })

  definition
end
```

Update `project_requirements/0`:

```elixir
def project_requirements do
  [
    technical_strategy(),
    architecture_designed(),
    issues_triaged(),
    issues_resolved(),
    all_stories_complete(),
    all_bdd_specs_passing(),     # NEW — after stories, before QA journeys
    qa_journey_plan(),
    qa_journey_execute(),
    qa_journey_wallaby()
  ]
end
```

### 12. Register session type and task mapping

**File:** `lib/code_my_spec/sessions/session_type.ex` — add `AgentTasks.FixAllBddSpecs` to `@valid_types`

**File:** `lib/code_my_spec/agent_tasks/start_agent_task.ex` — add to `@session_type_map` and `@componentless_tasks`

### 13. Remove `run_all_spex` from session start

**File:** `lib/code_my_spec/agent_tasks/start_agent_task.ex`

Remove the `Pipeline.run_all_spex(scope)` call and `persist_spex_problems` from `run_project_task`. Spex now runs lazily via `before_dispatch` at story and project levels — no need to run upfront.

---

## Files Summary

### New files (3):
- `lib/code_my_spec/requirements/all_bdd_specs_passing_checker.ex` — project-level spex checker
- `lib/code_my_spec/agent_tasks/fix_all_bdd_specs.ex` — project-level spex fix task with `before_dispatch`
- `test/code_my_spec/agent_tasks/fix_all_bdd_specs_test.exs` — tests

### Modified files (6):
- `lib/code_my_spec/project_coordinator/dispatch.ex` — add `call_before_dispatch`, wire into all `command_*` functions
- `lib/code_my_spec/agent_tasks/start_implementation.ex` — handle `{:ok, :skip}` in `dispatch` and `dispatch_or_complete`
- `lib/code_my_spec/agent_tasks/fix_bdd_specs.ex` — implement `before_dispatch/3` (story-scoped spex refresh)
- `lib/code_my_spec/requirements/requirement_definition_data.ex` — add `all_bdd_specs_passing()` definition, update `project_requirements/0`
- `lib/code_my_spec/sessions/session_type.ex` — register `FixAllBddSpecs`
- `lib/code_my_spec/agent_tasks/start_agent_task.ex` — register task mapping, remove `run_all_spex` from session start

### Possibly modified (1):
- `lib/code_my_spec/requirements/sync.ex` — add `recalculate_story_requirements/2` and/or `recalculate_project_requirements/2` if they don't exist

### Untouched:
- `next_actionable.ex` — no changes needed
- `validation.ex` — no changes needed (hook path is separate from dispatch path)
- `pipeline.ex` — `run_all_spex` stays as a function, just called from `FixAllBddSpecs.before_dispatch` instead of session start

## Future Uses

Other tasks that could benefit from `before_dispatch`:

- **QA tasks** (`QaStory`, `QaApp`, `QaJourneyExecute`) — verify server is running before dispatching a browser-based QA agent
- **Implementation tasks** — verify compilation succeeds before dispatching code generation (avoid dispatching into a broken project)
- **Any task with cached checker data** — same pattern as `FixBddSpecs`: refresh data, re-evaluate, skip if satisfied

## Testing

- `test/code_my_spec/project_coordinator/dispatch_test.exs` — test that `before_dispatch` is called when defined, default `:ok` when not defined, `:skip` prevents command call, `{:error, reason}` propagates
- `test/code_my_spec/agent_tasks/start_implementation_test.exs` — test re-walk on `:skip`, skip count limit
- `test/code_my_spec/agent_tasks/fix_bdd_specs_test.exs` — test `before_dispatch` runs story spex, returns `:skip` when passing, returns `:ok` when failing, rescues errors
- `test/code_my_spec/agent_tasks/fix_all_bdd_specs_test.exs` — test `before_dispatch` runs all spex, returns `:skip` when all pass, returns `:ok` when failures remain
- `test/code_my_spec/requirements/all_bdd_specs_passing_checker_test.exs` — satisfied when no spex problems, unsatisfied when problems exist
