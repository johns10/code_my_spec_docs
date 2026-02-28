# Graph-Driven Start Implementation

## Status: Core done, integration testing needed

The recursive graph traversal, dispatch layer, and StartImplementation refactor are
implemented and passing unit tests. What remains is integration testing against a
real project and handling edge cases discovered during that testing.

## What Was Done

### 1. NextActionable — recursive graph traversal

`ProjectCoordinator.NextActionable.call(scope, entity)` walks
project → stories → components → dependencies to find the first stuck requirement.

Scope-based descent:
- `:local` — return immediately (leaf work like `spec_file`, `implementation_file`)
- `:children` — validate children have work, return the **parent** requirement (Dispatch orchestrates children)
- `:dependencies` — serial chain descent via `find_next_in_chain`

**Files:** `lib/code_my_spec/project_coordinator/next_actionable.ex`, `test/code_my_spec/project_coordinator/next_actionable_test.exs`

### 2. Dispatch — translates requirements into prompts/evaluations

`ProjectCoordinator.Dispatch` handles both `command` and `evaluate`:

- **command :local** — `build_session` from requirement FKs, delegate to `task_module.command/3`
- **command :children** — parent `command/3` + `task_module.orchestrate/3` on each actionable child, concatenate prompts
- **evaluate :local** — delegate to `task_module.evaluate/3`
- **evaluate :children** — collect descendants, `find_actionable`, run `orchestrate/3` on each, return `:valid` or `:invalid` with feedback. Cleans up status directory when all children complete.

**Files:** `lib/code_my_spec/project_coordinator/dispatch.ex`, `test/code_my_spec/project_coordinator/dispatch_test.exs`, `docs/spec/code_my_spec/project_coordinator/dispatch.spec.md`

### 3. Orchestrate → ProjectCoordinator consolidation

All functions from `AgentTasks.Orchestrate` were moved into `ProjectCoordinator`:
`collect_components`, `find_actionable`, `find_remaining`, `generate_prompt_files`,
`build_orchestration_prompt`, `component_status_dir`, `cleanup_status_directory`,
`default_orchestrate`, `write_prompt_file`, `safe_filename`, `task_module_suffix`,
`format_prompt_file_list`.

`AgentTasks.Orchestrate` was deleted. All 13 callers updated.

**Files:** `lib/code_my_spec/project_coordinator.ex`, `test/code_my_spec/project_coordinator/orchestration_test.exs`

### 4. ContextComponentSpecs / ContextImplementation — evaluate moved to Dispatch

Both modules had identical `evaluate/3` that did child orchestration. This logic
now lives in `Dispatch.evaluate_children/2`. Both modules only provide `command/3`.

**Files:** `lib/code_my_spec/agent_tasks/context_component_specs.ex`, `lib/code_my_spec/agent_tasks/context_implementation.ex`

### 5. StartImplementation — refactored to use graph

Went from 567 lines of ad-hoc dispatching to ~150 lines:

```elixir
# command/3 — caller (StartAgentTask) syncs before calling
def command(scope, _session, _opts \\ []) do
  dispatch(scope.environment, scope)
end

# dispatch — the whole thing
defp dispatch(env, scope) do
  case ProjectCoordinator.get_next_actions(scope) do
    {:ok, req} -> Dispatch.command(req, scope, %{}) |> write_status(env, req)
    :complete  -> {:ok, "All requirements satisfied."}
    {:error, reason} -> {:error, reason}
  end
end
```

Status file stores `{"requirement_id": "..."}` — evaluate reloads it and calls
`Dispatch.evaluate`, then re-dispatches if valid.

Syncing: `StartAgentTask` syncs before `command/3`. `evaluate/3` syncs before
evaluating (agent may have created files) and again before re-dispatching.

**Deleted:** All BDD spec resolution, story dispatch, chain walking, blocked handling,
pre-flight, fix-failing-specs. These were duplicating graph logic or are story-level
concerns that need to be handled differently.

## What Remains

### BDD spec integration

The old StartImplementation had a BDD spec pipeline: run specs → find failing story →
dispatch WriteBddSpecs or fix-failing-specs. This was removed in the refactor.

BDD specs are story-level requirements (`bdd_spec_existence`, `bdd_spec_passing`) that
should be handled by the requirement graph. The checkers need to:

1. **`bdd_spec_existence`** — check if spex files exist for the story
2. **`bdd_spec_passing`** — run the story's spex files and check they pass

These checkers exist in the requirements registry (`requirement_definition_data.ex`)
but need real checker implementations that actually run specs and check files. Currently
they use placeholder checkers.

**Relevant files:**
- `lib/code_my_spec/requirements/requirement_definition_data.ex` — definitions with checker modules
- `lib/code_my_spec/requirements/bdd_spec_existence_checker.ex` — needs implementation
- `lib/code_my_spec/requirements/bdd_spec_passing_checker.ex` — needs implementation
- `lib/code_my_spec/agent_tasks/write_bdd_specs.ex` — task module for `bdd_spec_existence`

### Story-component linkage errors

When a story has no linked component, the old code showed a "Story Blocked" prompt
with available components and a curl command to link. The graph returns an error in
this case. We may need a requirement checker or a pre-flight step that surfaces this
as a clear actionable message rather than an opaque graph error.

### Integration testing

The unit tests pass but this hasn't been tested end-to-end against a real project.
Need to:

1. Run `/start-implementation` on a real project
2. Verify NextActionable finds the right requirement
3. Verify Dispatch generates correct prompts
4. Verify evaluate → re-dispatch loop works
5. Check logging output is sufficient for debugging

### Pre-flight hooks (minor)

The old code had `ensure_json_stub_spec` for controller components. This could
become a requirement checker or be handled in the controller spec task module.

## Agent Tasks Audit

Full audit of all 33 modules in `lib/code_my_spec/agent_tasks/`. Result: **28/33 are
compatible** with the new graph-driven structure. **5 modules are obsolete** (ManageImplementation
+ 4 Develop* modules) — they duplicate graph logic and should be removed after validation.

### Compatible — no changes needed

**Leaf task modules** (provide `command/3`, `evaluate/3`, `orchestrate/3`):
All use `ProjectCoordinator.default_orchestrate` and work transparently with Dispatch.

- `ComponentSpec` — spec writing for components
- `ComponentCode` — implementation writing for components
- `ComponentTest` — test writing for components
- `LiveViewSpec` — spec writing for LiveViews
- `LiveViewCode` — implementation writing for LiveViews
- `LiveViewTest` — test writing for LiveViews
- `LiveContextSpec` — spec writing for live contexts
- `ContextSpec` — spec writing for contexts
- `ContextDesignReview` — design review for contexts

**Parent task modules** (provide `command/3` only, Dispatch handles evaluate):
- `ContextComponentSpecs` — generates parent prompt for context spec + child specs
- `ContextImplementation` — generates parent prompt for context impl + child impls

**Standalone task modules** (not dispatched by the graph, called directly):
- `StartImplementation` — already refactored, drives the graph
- `StartAgentTask` — entry point, calls task modules
- `ProjectSetup` — one-time project scaffolding
- `WriteBddSpecs` — BDD spec generation (will become graph-dispatched via `bdd_spec_existence` requirement)
- `QaApp` — whole-project QA
- `QaStory` — per-story QA
- `RefactorModule` — interactive refactoring

**Support modules** (not task modules, just helpers):
- `ProblemFeedback` — formats test/compilation problems for evaluate feedback
- `TaskIdentifier` — identifies task markers in conversation transcripts
- `TaskMarker` — generates task marker strings for prompts

### Obsolete — should be removed after graph validation

**`ManageImplementation`** — duplicates graph logic with ad-hoc story/component walking.
It iterates stories, finds linked components, dispatches Develop* modules, and manages
a loop. All of this is now handled by:
- `NextActionable` — finds the stuck requirement by walking project → stories → components
- `Dispatch` — generates prompts and evaluates via task modules
- `StartImplementation` — drives the dispatch → evaluate → re-dispatch loop

`ManageImplementation` can be deleted once the graph path is validated end-to-end.
Its callers (`manage-implementation` skill) should be redirected to `start-implementation`.

**Develop\* modules** — compound phase orchestrators that duplicate graph + Dispatch logic:
- `DevelopContext` — 4-phase lifecycle (context spec → component specs → design review → implementation)
- `DevelopController` — 2-phase lifecycle (controller spec → implementation)
- `DevelopLiveContext` — 3-phase lifecycle (live context spec → child specs → implementation)
- `DevelopLiveView` — 3-phase lifecycle (liveview spec → child specs → implementation)

These are NOT in the requirement graph (not `satisfied_by` on any requirement) and do NOT
provide `orchestrate/3`, so Dispatch can't use them. They're only called by ManageImplementation
and as direct slash commands. The graph already handles their lifecycle phases through
existing requirements:

| Develop* phase | Graph requirement | Task module |
|---|---|---|
| Context spec | `spec_file` (:local) | `ContextSpec` |
| Component specs | `children_designs` (:children) | `ContextComponentSpecs` |
| Design review | `design_review` (:local) | `ContextDesignReview` |
| Implementation | `children_implementations` (:children) | `ContextImplementation` |
| LiveView spec | `spec_file` (:local) | `LiveViewSpec` |
| Controller spec | `spec_file` (:local) | `ComponentSpec` |
| Tests + code | `test_file`/`implementation_file` (:local) | `ComponentTest`/`ComponentCode`/`LiveViewTest`/`LiveViewCode` |

Delete alongside ManageImplementation. Remove from `session_type.ex` and `start_agent_task.ex`.

## Architecture

```
StartAgentTask.run
  → Sync.sync_all (components + requirements)
  → StartImplementation.command
    → ProjectCoordinator.get_next_actions
      → NextActionable.call(scope, project)
        → find_stuck requirement
        → resolve by scope (:local/:children/:dependencies)
        → descend recursively if needed
    → Dispatch.command(req, scope, session)
      → :local  → task_module.command/3
      → :children → parent command + orchestrate children
    → write status {requirement_id}

HookController("Stop")
  → TaskEvaluator.evaluate_sessions
    → StartImplementation.evaluate
      → load requirement from status
      → Sync.sync_all (refresh after agent work)
      → Dispatch.evaluate(req, scope, session)
        → :local  → task_module.evaluate/3
        → :children → find_actionable children, orchestrate, check completeness
      → if valid → clear status → sync again → re-dispatch next
      → if invalid → return feedback
```
