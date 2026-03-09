# Incremental Sync & Analysis Pipeline

## Problem

Every hook fire (task start/stop) runs a full project sync: reads all files, runs all static analysis and tests against the full project, rebuilds all requirements and problems from scratch. This is too expensive.

## Target Architecture

1. **File watcher** watches `lib/`, `test/`, `.code_my_spec/spec/`. On change: map file to component, bump `files_changed_at` on the component record.
2. **Hook pipeline** queries dirty components per tool (`WHERE files_changed_at > last_analyzed_at[tool]`), runs only those, does scoped problem replacement.
3. **Per-tool granularity** — `last_analyzed_at` tracks each tool independently: `compiler`, `credo`, `sobelow`, `exunit`, `spex`.
4. **Problems scoped to components** via `component_id` FK. Scoped invalidation: delete problems WHERE `component_id IN dirty_set AND source = tool`, insert new.
5. **BDD specs decoupled** from stop hook.
6. **Deleted components** cascade-delete their problems via FK.
7. **Requirements** are cheap structural checks only — never depend on analysis results.

---

## Implementation Phases

Phases 1-3 build the watcher and dirty tracking. No changes to problems, requirements, or hooks until Phase 4+.

---

## Phase 1: Schema — Component Dirty Tracking Fields

### Migration

```elixir
alter table(:components) do
  add :files_changed_at, :utc_datetime
  add :last_analyzed_at, :map, default: %{}
end

create index(:components, [:files_changed_at])
```

**`files_changed_at`** — UTC timestamp of the most recent file change for this component. The watcher bumps this on every relevant event.

**`last_analyzed_at`** — Per-tool timestamp map:

```elixir
%{
  "compiler" => "2026-03-06T12:00:00Z",
  "credo"    => "2026-03-06T12:00:00Z",
  "sobelow"  => "2026-03-06T11:30:00Z",
  "exunit"   => "2026-03-06T12:00:00Z"
}
```

### Schema change in `Component.ex`

```elixir
field :files_changed_at, :utc_datetime
field :last_analyzed_at, :map, default: %{}
```

### Dirty query

A component is dirty for tool X when:

```elixir
# files_changed_at is set AND (never analyzed by this tool OR analyzed before last change)
where(c, [c], not is_nil(c.files_changed_at) and
  (fragment("(?->?)::text IS NULL", c.last_analyzed_at, ^tool_key) or
   c.files_changed_at > fragment("(?->>?)::timestamp", c.last_analyzed_at, ^tool_key)))
```

Or simpler in Elixir — load all components, filter in app code:

```elixir
def dirty_for_tool?(component, tool) do
  changed_at = component.files_changed_at
  analyzed_at = get_in(component.last_analyzed_at || %{}, [to_string(tool)])

  changed_at != nil and (analyzed_at == nil or DateTime.compare(changed_at, DateTime.from_iso8601!(analyzed_at)) == :gt)
end
```

---

## Phase 2: FileWatcherServer — Thin Event-to-DB Bridge

The watcher's only job: see file event, map to component, update the component in DB. No in-memory state beyond what the GenServer needs for debouncing.

### File: `lib/code_my_spec/project_sync/file_watcher_server.ex`

```elixir
defmodule CodeMySpec.ProjectSync.FileWatcherServer do
  @moduledoc """
  Watches project directories for file changes and marks components dirty in the DB.

  On file change: maps path to component, bumps `files_changed_at` on the
  component record. The hook pipeline queries dirty
  components when it needs to decide what to analyze.
  """
  use GenServer
  require Logger

  alias CodeMySpec.Components
  alias CodeMySpec.Components.DirtyTracker
  alias CodeMySpec.Users.Scope

  @watched_dirs [".code_my_spec/spec", "lib", "test"]
  @debounce_ms 100

  # --- Client API ---

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  def running?,
    do: GenServer.call(__MODULE__, :running?)

  # --- Callbacks ---

  @impl true
  def init(opts) do
    project_root = Keyword.get(opts, :project_root, File.cwd!())
    dirs = @watched_dirs |> Enum.map(&Path.join(project_root, &1)) |> Enum.filter(&File.dir?/1)

    case FileSystem.start_link(dirs: dirs) do
      {:ok, watcher_pid} ->
        FileSystem.subscribe(watcher_pid)
        Logger.info("[FileWatcher] Watching: #{Enum.join(dirs, ", ")}")
        {:ok, %{watcher_pid: watcher_pid, project_root: project_root,
                 scope: Keyword.get(opts, :scope), pending: MapSet.new(),
                 debounce_timer: nil, running: true}}

      {:error, reason} ->
        Logger.warning("[FileWatcher] Could not start: #{inspect(reason)}")
        :ignore
    end
  end

  @impl true
  def handle_call(:running?, _from, state), do: {:reply, state.running, state}

  @impl true
  def handle_info({:file_event, _pid, {path, events}}, state) do
    if Enum.any?(events, &(&1 in [:modified, :created, :removed, :renamed])) do
      pending = MapSet.put(state.pending, path)
      if state.debounce_timer, do: Process.cancel_timer(state.debounce_timer)
      timer = Process.send_after(self(), :flush, @debounce_ms)
      {:noreply, %{state | pending: pending, debounce_timer: timer}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info(:flush, state) do
    relative_paths = Enum.map(state.pending, &Path.relative_to(&1, state.project_root))

    case get_scope(state) do
      %Scope{} = scope ->
        DirtyTracker.mark_files_changed(scope, relative_paths)
      nil ->
        Logger.debug("[FileWatcher] No scope available, skipping dirty marking")
    end

    {:noreply, %{state | pending: MapSet.new(), debounce_timer: nil}}
  end

  @impl true
  def handle_info({:file_event, _pid, :stop}, state) do
    Logger.warning("[FileWatcher] Watcher stopped")
    {:noreply, %{state | watcher_pid: nil, running: false}}
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, state) do
    if state.debounce_timer, do: Process.cancel_timer(state.debounce_timer)
    :ok
  end

  defp get_scope(%{scope: %Scope{} = scope}), do: scope
  defp get_scope(_state) do
    # Load scope from local config or CLI context
    case Scope.for_cli() do
      %Scope{} = scope -> scope
      _ -> nil
    end
  end
end
```

### Key design

- **Stateless beyond debounce** — all dirty state lives in the DB, survives restarts.
- **`DirtyTracker.mark_files_changed/2`** does the path-to-component mapping and DB update.
- **Graceful degradation** — returns `:ignore` if FileSystem can't start. Logs and skips if no scope.
- **Debounce at 100ms** — same as the old implementation. Batches rapid saves.

---

## Phase 3: `Components.DirtyTracker` — Path Mapping + DB Updates

Pure functions for mapping paths to components, plus DB update helpers.

### File: `lib/code_my_spec/components/dirty_tracker.ex`

```elixir
defmodule CodeMySpec.Components.DirtyTracker do
  @moduledoc """
  Maps file paths to components and manages dirty state in the DB.
  """

  alias CodeMySpec.Components
  alias CodeMySpec.Components.Component
  alias CodeMySpec.Users.Scope
  alias CodeMySpec.Utils

  @type tool :: :compiler | :credo | :sobelow | :exunit | :spex

  # --- Mark dirty (called by watcher) ---

  @doc """
  Map file paths to components and bump `files_changed_at` in the DB.
  """
  @spec mark_files_changed(Scope.t(), [String.t()]) :: :ok
  def mark_files_changed(%Scope{} = scope, relative_paths) do
    components = Components.list_components(scope)
    {path_to_component, _} = build_path_index(components, scope.active_project)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    # Group changed paths by component
    paths_by_component =
      relative_paths
      |> Enum.group_by(&Map.get(path_to_component, &1))
      |> Map.delete(nil)

    Enum.each(paths_by_component, fn {component_id, _paths} ->
      case Enum.find(components, &(&1.id == component_id)) do
        nil -> :ok
        component ->
          Components.update_component(scope, component,
            %{files_changed_at: now}, broadcast: false)
      end
    end)
  end

  # --- Query dirty (called by hook pipeline) ---

  @doc """
  Returns components that are dirty for a given tool.
  Dirty = files_changed_at is set AND (never analyzed by tool OR changed after last analysis).
  """
  @spec dirty_components(Scope.t(), tool()) :: [Component.t()]
  def dirty_components(%Scope{} = scope, tool) do
    scope
    |> Components.list_components()
    |> Enum.filter(&dirty_for_tool?(&1, tool))
  end

  @doc """
  Check if a single component is dirty for a tool.
  """
  @spec dirty_for_tool?(Component.t(), tool()) :: boolean()
  def dirty_for_tool?(%Component{} = component, tool) do
    changed_at = component.files_changed_at
    tool_key = to_string(tool)
    analyzed_at_str = (component.last_analyzed_at || %{})[tool_key]

    cond do
      is_nil(changed_at) -> false
      is_nil(analyzed_at_str) -> true
      true ->
        {:ok, analyzed_at, _} = DateTime.from_iso8601(analyzed_at_str)
        DateTime.compare(changed_at, analyzed_at) == :gt
    end
  end

  # --- Record analysis complete (called after pipeline runs) ---

  @doc """
  Record that a tool has analyzed these components. Updates `last_analyzed_at[tool]`.
  """
  @spec record_analysis(Scope.t(), [Component.t()], tool()) :: :ok
  def record_analysis(%Scope{} = scope, components, tool) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()
    key = to_string(tool)

    Enum.each(components, fn component ->
      current = component.last_analyzed_at || %{}
      updated = Map.put(current, key, now)
      Components.update_component(scope, component,
        %{last_analyzed_at: updated}, broadcast: false)
    end)
  end

  # --- Path index (pure) ---

  @doc """
  Build reverse index: relative file path => component_id.
  Also returns component_id => file map for collecting dirty files.
  """
  @spec build_path_index([Component.t()], term()) ::
          {%{String.t() => binary()}, %{binary() => %{atom() => String.t()}}}
  def build_path_index(components, project) do
    Enum.reduce(components, {%{}, %{}}, fn component, {path_map, files_map} ->
      files = Utils.component_files(component, project)

      path_map =
        for {_role, rel_path} <- files, reduce: path_map do
          acc -> Map.put(acc, rel_path, component.id)
        end

      {path_map, Map.put(files_map, component.id, files)}
    end)
  end
end
```

### How the hook uses it

```elixir
# In the hook pipeline:
dirty = DirtyTracker.dirty_components(scope, :credo)
# Run credo on dirty components' files...
DirtyTracker.record_analysis(scope, dirty, :credo)
```

### Fallback: mark dirty from transcript

The hook can also call `mark_files_changed/2` with edited files from the transcript. This covers the case where the watcher wasn't running.

```elixir
# In validate_stop, before querying dirty:
DirtyTracker.mark_files_changed(scope, edited_files)
```

### Tests

- `mark_files_changed/2` updates `files_changed_at` on component
- `dirty_for_tool?/2` returns true when `files_changed_at > last_analyzed_at[tool]`
- `dirty_for_tool?/2` returns true when `last_analyzed_at[tool]` is nil
- `dirty_for_tool?/2` returns false when `files_changed_at` is nil
- `dirty_for_tool?/2` returns false when `last_analyzed_at[tool] > files_changed_at`
- `record_analysis/3` updates `last_analyzed_at[tool]` making component clean for that tool
- `dirty_components/2` returns only dirty components for the given tool
- Multiple tools track independently: dirty for `:credo` but clean for `:exunit`
- `mark_files_changed/2` bumps timestamp on each affected component

---

## Phase 4: Schema — Add `component_id` to Problems

### Migration

```elixir
alter table(:problems) do
  add :component_id, references(:components, type: :binary_id, on_delete: :delete_all)
end

create index(:problems, [:component_id])
create index(:problems, [:component_id, :source])
```

`on_delete: :delete_all` — cascade-deletes problems when a component is removed.

`component_id` is nullable — compiler errors don't belong to a single component.

### Schema change in `Problem.ex`

```elixir
belongs_to :component, CodeMySpec.Components.Component, type: :binary_id
```

### `ProblemAssigner` module

**File:** `lib/code_my_spec/problems/problem_assigner.ex`

Maps `problem.file_path` to `component_id` using the path index from `DirtyTracker.build_path_index/2`.

```elixir
defmodule CodeMySpec.Problems.ProblemAssigner do
  @spec assign([Problem.t()], %{String.t() => binary()}) :: [Problem.t()]
  def assign(problems, path_to_component_map) do
    Enum.map(problems, fn problem ->
      component_id = match_path(problem.file_path, path_to_component_map)
      %{problem | component_id: component_id}
    end)
  end

  defp match_path(nil, _), do: nil
  defp match_path(path, map) do
    Map.get(map, path) ||
      Enum.find_value(map, fn {rel, id} ->
        if String.ends_with?(path, rel) or String.ends_with?(rel, path), do: id
      end)
  end
end
```

### New `ProblemRepository` functions

```elixir
@doc "Replace problems for specific components and source. Others untouched."
def replace_problems_for_components(scope, component_ids, source, new_problems)

@doc "Delete all problems for component IDs."
def delete_problems_for_components(scope, component_ids)
```

Scoped by `component_id IN ids AND source = source_string`.

---

## Phase 5: Scoped Analysis Pipeline

### `Pipeline.run_scoped/3`

```elixir
@spec run_scoped(Scope.t(), [Component.t()], keyword()) :: %{atom() => [Problem.t()]}
def run_scoped(scope, dirty_components, opts \\ []) do
  base = scope.cwd
  project = scope.active_project

  # Collect all files for dirty components via Utils.component_files
  all_file_maps = Enum.map(dirty_components, &Utils.component_files(&1, project))

  code_files = all_file_maps |> Enum.map(& &1.code_file) |> resolve_paths(base)
  test_files = all_file_maps |> Enum.map(& &1.test_file) |> resolve_paths(base)
  spec_files = all_file_maps |> Enum.map(& &1.spec_file) |> resolve_paths(base)
  elixir_files = code_files ++ test_files

  compiler_problems = case compile_project(scope, opts) do
    {:ok, p} -> p; {:error, p} -> p
  end

  %{
    compiler: compiler_problems,
    credo: if(elixir_files != [], do: elem(run_credo(elixir_files, scope), 1), else: []),
    sobelow: if(elixir_files != [], do: elem(run_sobelow(elixir_files, scope), 1), else: []),
    exunit: if(test_files != [], do: elem(run_tests(test_files, scope, opts), 1), else: []),
    spec_validation: if(spec_files != [], do: elem(validate_spec_files(spec_files), 1), else: [])
  }
end

defp resolve_paths(rel_paths, base) do
  rel_paths
  |> Enum.map(&Path.join(base, &1))
  |> Enum.filter(&File.exists?/1)
end
```

Uses `Utils.component_files/2` to get all files for each dirty component — no per-file tracking needed.

---

## Phase 6: Refactored Hook Pipeline

### Key Design Decisions

1. **File watcher and transcript are separate concerns.**
   - File watcher = dirty tracking for analysis. Marks components dirty as files change. By the time the stop hook fires, all edits are already tracked and analysis is up to date.
   - Transcript = task identification only. "What files did this agent edit?" → match to dispatched task → evaluate that specific task.

2. **Status file as dispatch registry** — `implementation_status.json` tracks open tasks with enough info to match returning subagents to their dispatched work. Not just observability.

3. **Targeted requirement recalc** — After scoped analysis stores problems, we recalculate requirements only for components that have problems (not dirty ones — they're no longer dirty after analysis runs). This avoids a full sync.

4. **Task matching on subagent return** — Instead of unreliable TaskMarker parsing, we match edited files from the transcript against dispatched tasks in the status file.

5. **No match = return all problems** — If edited files don't match any dispatched task, we skip task evaluation and just return whatever problems the analysis found. No silent pass-through.

### Status File: Dispatch Registry

Expand `StartImplementation.write_status/2` to track dispatched tasks with file expectations:

```elixir
# .code_my_spec/tasks/implementation_status.json
%{
  "dispatched_tasks" => [
    %{
      "requirement" => "component_implementation",
      "component_id" => "aaaa-1111",
      "component_module" => "MyApp.Accounts",
      "expected_files" => ["lib/my_app/accounts.ex", "test/my_app/accounts_test.exs"],
      "dispatched_at" => "2026-03-07T12:00:00Z"
    },
    %{
      "requirement" => "component_design",
      "component_id" => "bbbb-2222",
      "component_module" => "MyApp.Users",
      "expected_files" => ["lib/my_app/users.ex"],
      "dispatched_at" => "2026-03-07T12:00:05Z"
    }
  ],
  "updated_at" => "2026-03-07T12:00:05Z"
}
```

When `:children` scope dispatches N subagents, each child gets an entry. `expected_files` is derived from `Utils.component_files/2` but filtered by requirement type:

- `component_design` → spec file only
- `component_implementation` → code file + test file
- `bdd_specs` → spec file (BDD section)
- `qa_story` → QA files under `.code_my_spec/qa/`
- `qa_journey_*` → journey plan/result/wallaby files

This filtering ensures we match the right task when a subagent returns. A subagent editing `lib/my_app/accounts.ex` matches `component_implementation`, not `component_design`.

### `validate_subagent/2` — Revised Flow

```
 1. Query dirty components → Pipeline.run_scoped
    (file watcher already marked everything dirty as edits happened)
 2. ProblemAssigner.assign → replace_problems_for_components per source
 3. DirtyTracker.record_analysis per tool
 4. Find components with problems (not dirty — analysis just ran)
 5. Recalculate requirements only for problem-bearing components
    (walk up parent chain)
 6. Extract edited files from transcript (task identification only)
 7. Match edited files → dispatched_tasks in status file
 8. If match: evaluate the matched task (component task evaluate)
    If no match: return all problems (no task eval, just blocking problems)
 9. Return combined result
```

Steps 1-5 are the analysis pipeline — same for both entry points. The file watcher has already done its job by the time we get here.

Steps 6-8 are task identification — unique to `validate_subagent`. We parse the transcript only to know which files this particular agent touched, match against the dispatch registry, and evaluate the corresponding task. If no match is found, we just return whatever problems exist — no silent pass.

### `validate_stop/2` — Revised Flow

```
 1. Query dirty components → Pipeline.run_scoped
 2. ProblemAssigner.assign → replace_problems_for_components per source
 3. DirtyTracker.record_analysis per tool
 4. Find components with problems
 5. Recalculate requirements for problem-bearing components
 6. TaskEvaluator.evaluate_sessions (session stack evaluation)
 7. Return combined result
```

Same analysis pipeline (steps 1-5). No transcript needed — session evaluation uses the session_id.

### Targeted Requirement Recalculation

After storing problems, call a lightweight requirement recalc that:
1. Queries components with non-zero problems
2. For each, recalculates that component's requirements
3. Walks up the parent chain (parent's `children_implementations` etc.)
4. Does NOT touch components without problems

```elixir
defp recalculate_for_problem_components(scope) do
  # Components that have stored problems
  component_ids = Problems.components_with_problems(scope)

  # Load those components + parents
  components = Components.list_components(scope)
  problem_components = Enum.filter(components, &(&1.id in component_ids))

  # Recalculate requirements for each + ancestors
  Enum.each(problem_components, fn component ->
    Sync.recalculate_component_requirements(scope, component)
    walk_parent_chain(scope, component, components)
  end)
end
```

This is much cheaper than `sync_all` — only touches the components that matter.

### Task Matching Logic

```elixir
defp match_task(edited_files, status_file) do
  tasks = status_file["dispatched_tasks"] || []

  Enum.find(tasks, fn task ->
    expected = MapSet.new(task["expected_files"])
    edited = MapSet.new(edited_files)
    not MapSet.disjoint?(expected, edited)
  end)
end
```

If multiple tasks overlap (unlikely — components have distinct files), pick the one with the most overlap. If no match, fall back to evaluating all dispatched tasks.

### Implementation (DONE)

**`ImplementationStatus`** (new) — `lib/code_my_spec/project_coordinator/implementation_status.ex`:
- Shared module for status file I/O (dispatch registry)
- `record_task/2`, `dispatched_tasks/1`, `match_task/2`, `build_task_entry/4`
- `expected_files_for/3` — maps requirement name to relevant files

**`StartImplementation`** — uses `ImplementationStatus.build_task_entry` + `record_task`

**`Dispatch`** — records tasks for both `:orchestrate` and `:children` scope:
- `record_orchestrate_task/2` — single subagent dispatch
- `record_child_task/3` — per-child in `:children` scope

**`Validation`** — fully rewritten:
- Shared `run_analysis_pipeline/2` for both entry points
- `recalculate_for_problem_components/1` — targeted requirement recalc
- `match_and_evaluate_task/2` — transcript → edited files → match → evaluate
- `validate_stop` uses `TaskEvaluator.evaluate_sessions` (unchanged)

**`Problems.component_ids_with_problems/1`** — new query in ProblemRepository

**`Sync.recalculate_component_requirements/2`** — already existed from Phase 3

**`ManageImplementation`** — deleted (deprecated)

### Graceful Fallback

If the file watcher wasn't running (e.g., fresh DB, process crashed), no components will be dirty. The analysis pipeline returns empty results and the hook passes through. This is acceptable — the watcher is expected to be running during active development. A full `sync_all` on session start can hydrate dirty state if needed.

---

## Phase 7: Decouple BDD Specs from Stop Hook — DONE

Already achieved by Phase 6 cutover:
- Hook path uses `Pipeline.run_scoped` which doesn't run spex
- `Pipeline.run/3` (which includes spex) has no callers
- `run_all_spex` only called from `StartAgentTask` on session start (correct placement)

---

## Phase 8: Analysis-Dependent Requirement Checkers — DONE (kept)

Originally planned to remove `TestStatusChecker` and `BddSpecPassingChecker`.
Not needed — both already just query stored Problems (cheap). The analysis pipeline
populates problems, `recalculate_for_problem_components` re-evaluates requirements
after. Checkers stay as-is.

---

## Phase 9: Lightweight Hook Sync — DONE

Originally planned `sync_requirements_only/2`. Not needed — the hook path
(`validate_subagent`/`validate_stop`) never calls `Sync.sync_all`. Instead:
- `run_analysis_pipeline` → scoped analysis on dirty components
- `recalculate_for_problem_components` → targeted recalc for components with problems
- File watcher handles incremental recalc via `recalculate_component_requirements`

---

## Incremental Requirement Recalculation — DONE

Implemented via `Sync.recalculate_component_requirements/2`:
- Recalculates a single component's requirements
- Walks up the parent chain (parent's `children_implementations` etc.)
- Called by file watcher after marking dirty
- Called by validation after storing problems

---

## What NOT to Change

1. **`Components.Sync`** — Already incremental with mtime pre-filtering.
2. **`RequirementsSync`** — Full recalculation is cheap. Optimize later if needed.
3. **Structural requirement checkers** — All cheap and correct.
4. **`ProjectCoordinator`** — Orchestration is orthogonal.
5. **Architecture views, StatusWriter** — Fast, keep as-is.
6. **Issues system** — Separate concern.
7. **`ComponentStatus`** — Fine as-is.
8. **Hook controller routing** — HTTP layer unchanged.
9. **`Tests.execute`** — Unchanged, just fed fewer files.

---

## Execution Order

| Step | Phase | What | Risk |
|------|-------|------|------|
| 1 | Phase 1 | Migration: `files_changed_at`, `last_analyzed_at` | None — additive |
| 2 | Phase 3 | `DirtyTracker` module + tests | None — new code |
| 3 | Phase 2 | `FileWatcherServer` + tests | None — new process, opt-in |
| 4 | Phase 4 | Migration: `component_id` on problems + `ProblemAssigner` | None — additive |
| 5 | Phase 5 | `Pipeline.run_scoped` | None — new function |
| 6 | Phase 6 | Wire hooks to use dirty tracking | **Medium** — switchover |
| 7 | Phase 7 | Decouple BDD | Low |
| 8 | Phase 8 | Remove analysis-dependent checkers | Low |
| 9 | Phase 9 | `sync_requirements_only` | Low |

Phases 1-5 add new code. Phase 6 is the switchover. 7-9 are cleanup.

---

## Prior Art

- **Old `FileWatcherServer`**: deleted in `e3a8802`. Watched `docs/spec` + `lib/`, debounced 100ms, dispatched to `ChangeHandler`. Recovered from git history.
- **`ContentSync.FileWatcher`**: existing, watches content dirs. Same `FileSystem` library, same pattern.
- **`ChangeHandler`**: exists at `lib/code_my_spec/project_sync/change_handler.ex`. Currently calls `Sync.sync_all` for everything.
- **`FileWatcherServer` spec**: `.code_my_spec/spec/code_my_spec/project_sync/file_watcher_server.spec.md`. Needs updating.
