# Requirements sync doesn't cascade from components to stories to project

## Status: Open

Story requirements (`bdd_specs_passing`, `component_complete`, `qa_complete`) and project
requirements (`all_stories_complete`, `all_bdd_specs_passing`) are only fully synced during
`ProjectSync.sync` (full sync). All incremental paths only sync component requirements,
leaving story and project requirements stale.

## Problem

Requirements form a cascade: component state changes affect story requirements, which
affect project requirements. But the incremental sync paths skip the cascade:

| Location | Component | Story | Project |
|---|---|---|---|
| `ProjectSync.sync` (full sync) | All | All | Yes |
| `FileWatcherServer` (continuous, on file save) | Changed only | **Missing** | **Missing** |
| `StartImplementation` (impl lifecycle start) | Changed only | All (just added) | **Missing** |
| `Validation` (stop/subagent stop hooks) | Problem components | After spex only | **Missing** |
| `WriteBddSpecs` | Changed only | **Missing** | **Missing** |

**Consequence:** Status files show stale story requirements. `NextActionable` may make
wrong decisions because `bdd_specs_passing` was never evaluated. The `stories.md` status
file shows all BDD specs as failing even when there are zero spex problems in the DB.

## Root cause

`recalculate_component_requirements` exists for targeted component updates, but there's
no equivalent cascade function. Each call site manually handles component requirements
and stops there.

## Fix: `RequirementsSync.cascade_from_components/2`

Add a single function that handles the upward cascade from changed components:

```elixir
@spec cascade_from_components(Scope.t(), [String.t()]) :: :ok
def cascade_from_components(scope, changed_component_ids) do
  # 1. Find stories linked to the changed components (not all stories)
  affected_stories =
    Stories.list_project_stories(scope)
    |> filter_stories_linked_to(changed_component_ids)
    |> Repo.preload([:requirements, :component])

  # 2. Sync requirements for just those stories
  if affected_stories != [] do
    sync_story_requirements(affected_stories, scope)
  end

  # 3. Sync project requirements (depends on story state)
  sync_project_requirements(scope)
end
```

Then call it from each incremental sync site after component requirements are done:

### FileWatcherServer (line ~178)

After `recalculate_component_requirements` for each changed component:
```elixir
RequirementsSync.cascade_from_components(scope, changed_component_ids)
```

This is the most important site — it runs on every file save and writes status files
that reflect stale data without the cascade.

### Validation (line ~323)

After `recalculate_for_problem_components`:
```elixir
RequirementsSync.cascade_from_components(scope, problem_component_ids)
```

### StartImplementation (line ~144)

Replace the current full `sync_story_requirements` with the targeted cascade:
```elixir
RequirementsSync.cascade_from_components(scope, changed_ids)
```

This is more efficient than syncing all 42 stories when only 2 components changed.

### StartAgentTask

No change needed. Individual task sessions don't need story/project requirements.

## Performance consideration

`cascade_from_components` should be efficient because:
- Story filtering is by component_id (indexed FK), not full table scan
- Only affected stories get recalculated, not all stories
- Project requirements are a single record — always cheap

For FileWatcherServer specifically, the cascade adds ~50-100ms on top of the existing
component sync. This is acceptable within the 100ms debounce window since the debounce
timer resets on each file event anyway.

## Files

- `lib/code_my_spec/requirements/sync.ex` — add `cascade_from_components/2`
- `lib/code_my_spec/project_sync/file_watcher_server.ex` — call cascade after component sync
- `lib/code_my_spec/validation.ex` — call cascade after problem component recalc
- `lib/code_my_spec/agent_tasks/start_implementation.ex` — replace full story sync with cascade
