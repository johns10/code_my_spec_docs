# Requirements-Driven Orchestration

## Problem

The orchestration layer has four nearly identical `Develop*` modules (DevelopContext, DevelopLiveView, DevelopLiveContext, DevelopController) totaling ~2,500 lines with ~75% code duplication. Each hard-codes a phase sequence (spec → children → review → implementation) that mirrors information already encoded in the requirements system.

The requirements system already knows:
- What needs to be done (`RequirementDefinition` with `satisfied_by` mapping to agent task modules)
- Whether it's done (`Requirement.satisfied`)
- What type of work it is (`artifact_type`: specification, review, code, tests, dependencies, hierarchy)
- Which component types need which requirements (`Registry`)

But the `Develop*` modules duplicate this knowledge as hand-written phase logic. Adding a new component type or requirement means writing another 600-line orchestrator. Worse, the hard-coded phases prevent parallelism — phases run sequentially even when independent requirements could run concurrently.

### What the hard-coded phases actually encode

| DevelopContext (4 phases) | DevelopLiveView (3 phases) | DevelopLiveContext (3 phases) | DevelopController (2 phases) |
|---|---|---|---|
| 1. ContextSpec | 1. LiveViewSpec | 1. LiveContextSpec | 1. ComponentSpec |
| 2. ComponentSpec × N | 2. ComponentSpec × N | 2. LiveViewSpec/ComponentSpec × N | 2. Test + Code |
| 3. ContextDesignReview | — | — | — |
| 4. Test + Code × N | 3. Test + Code × N | 3. Test + Code × N (children only) | — |

This is just the requirements graph walked in a fixed order. The requirements themselves (`spec_file` → `spec_valid` → `children_designs` → `review_file` → ...) already define this sequence.

### ManageImplementation is also over-complicated

`ManageImplementation.resolve_development/3` walks the dependency chain to find the first developable component, maps it to a `Develop*` module by type, then dispatches. If we can dispatch based on requirements directly, ManageImplementation simplifies to: walk the graph, find all components with actionable requirements, dispatch in parallel.

## Design

### Core Idea

Add explicit `prerequisites` to `RequirementDefinition`. The orchestrator becomes: "find unsatisfied requirements whose prerequisites are met, group by `satisfied_by` task, dispatch."

### 1. Add `prerequisites` to RequirementDefinition

New field on `RequirementDefinition`:

```elixir
defstruct [
  :name, :checker, :satisfied_by, :artifact_type,
  :description, :threshold, :config,
  :prerequisites  # NEW: list of requirement names that must be satisfied first
]
```

#### Prerequisite Graph (Common Components)

```
spec_file ──→ spec_valid ──→ dependencies_satisfied ──→ implementation_file ──→ test_file ──→ test_spec_alignment ──→ tests_passing
```

#### Prerequisite Graph (Contexts)

```
context_spec_file ──→ context_spec_valid ──→ children_designs ──→ review_file ──→ review_valid ──→ children_implementations
                                                                                                          │
                                                                                          dependencies_satisfied
                                                                                                          │
                                                                                                  implementation_file ──→ test_file ──→ ...
```

#### Prerequisite Graph (LiveContexts)

```
live_context_spec_file ──→ live_context_spec_valid ──→ children_designs ──→ children_implementations ──→ dependencies_satisfied
```

Note: LiveContext has NO implementation_file, test_file, or tests_passing — it's a grouping container. The graph terminates at dependencies_satisfied.

#### Prerequisite Graph (LiveViews)

```
liveview_spec_file ──→ liveview_spec_valid ──→ dependencies_satisfied ──→ implementation_file ──→ test_file ──→ test_spec_alignment ──→ tests_passing
```

#### Full RequirementDefinitionData changes

```elixir
def spec_file, do: %RequirementDefinition{
  name: "spec_file", prerequisites: [],
  # ... existing fields unchanged
}

def spec_valid, do: %RequirementDefinition{
  name: "spec_valid", prerequisites: ["spec_file"],
  ...
}

def implementation_file, do: %RequirementDefinition{
  name: "implementation_file", prerequisites: ["spec_valid", "dependencies_satisfied"],
  ...
}

def test_file, do: %RequirementDefinition{
  name: "test_file", prerequisites: ["spec_valid"],
  ...
}

def test_spec_alignment, do: %RequirementDefinition{
  name: "test_spec_alignment", prerequisites: ["test_file"],
  ...
}

def tests_passing, do: %RequirementDefinition{
  name: "tests_passing", prerequisites: ["test_spec_alignment", "implementation_file"],
  ...
}

def dependencies_satisfied, do: %RequirementDefinition{
  name: "dependencies_satisfied", prerequisites: ["spec_valid"],
  ...
}

# Context-specific
def context_spec_file, do: %RequirementDefinition{
  name: "context_spec_file", prerequisites: [],
  ...
}

def context_spec_valid, do: %RequirementDefinition{
  name: "context_spec_valid", prerequisites: ["context_spec_file"],
  ...
}

def children_designs, do: %RequirementDefinition{
  name: "children_designs", prerequisites: ["context_spec_valid"],  # or live_context_spec_valid
  ...
}

def review_file, do: %RequirementDefinition{
  name: "review_file", prerequisites: ["children_designs"],
  ...
}

def review_valid, do: %RequirementDefinition{
  name: "review_valid", prerequisites: ["review_file"],
  ...
}

def children_implementations, do: %RequirementDefinition{
  name: "children_implementations", prerequisites: ["review_valid"],  # contexts need review first
  ...
}

# LiveView-specific
def liveview_spec_file, do: %RequirementDefinition{
  name: "liveview_spec_file", prerequisites: [],
  ...
}

def liveview_spec_valid, do: %RequirementDefinition{
  name: "liveview_spec_valid", prerequisites: ["liveview_spec_file"],
  ...
}
```

Note: `test_file` depends on `spec_valid` (not `implementation_file`) — tests can be written before code (TDD mode). `tests_passing` depends on both `test_spec_alignment` AND `implementation_file` since you need both to run tests.

### 2. Requirement Resolution: `Requirements.next_actionable/2`

New function that replaces phase logic:

```elixir
defmodule CodeMySpec.Requirements do
  @doc """
  Returns unsatisfied requirements whose prerequisites are all satisfied
  and which have a `satisfied_by` task module (i.e., actionable by an agent).

  Groups by `satisfied_by` module so the caller can dispatch one task per group.
  """
  def next_actionable(scope, component) do
    definitions = Registry.get_requirements_for_type(component.type)
    current = component.requirements  # persisted requirement records

    satisfaction_map = Map.new(current, &{&1.name, &1.satisfied})

    definitions
    |> Enum.filter(fn defn ->
      not Map.get(satisfaction_map, defn.name, false)         # unsatisfied
      and defn.satisfied_by != nil                            # has a task
      and prerequisites_met?(defn.prerequisites, satisfaction_map)  # ready
    end)
    |> Enum.group_by(& &1.satisfied_by)
    # => %{ComponentSpec => [spec_file, spec_valid], ComponentTest => [test_file], ...}
  end

  defp prerequisites_met?(prerequisites, satisfaction_map) do
    Enum.all?(prerequisites, &Map.get(satisfaction_map, &1, false))
  end
end
```

### 3. Traversal Requirements (dependencies_satisfied, children_*)

Three requirement types are "meta" — they're satisfied by work on OTHER components, not by running a task on this component:

| Requirement | satisfied_by | What satisfies it |
|---|---|---|
| `dependencies_satisfied` | nil | All dependency components have satisfied requirements |
| `children_designs` | nil* | All child components have spec files |
| `children_implementations` | nil | All child components have code files |

*`children_designs` currently has `satisfied_by: nil` but is checked by `HierarchicalChecker`. It's actually satisfied by running `ContextComponentSpecs` or individual `ComponentSpec`/`LiveViewSpec` on children.

These are **traversal triggers**. When `next_actionable/2` encounters a component blocked on `dependencies_satisfied`, the orchestrator doesn't wait — it traverses into the dependency to find actionable work there:

```elixir
defmodule CodeMySpec.AgentTasks.RequirementOrchestrator do
  @doc """
  Walk the dependency/hierarchy graph. Return all actionable {component, task_module, requirements}
  tuples across the entire tree. Supports parallel dispatch.
  """
  def find_all_actionable(scope, root_component) do
    find_all_actionable(scope, root_component, MapSet.new())
  end

  defp find_all_actionable(scope, component, visited) do
    if MapSet.member?(visited, component.id), do: [], else:
    visited = MapSet.put(visited, component.id)

    actionable = Requirements.next_actionable(scope, component)

    if map_size(actionable) > 0 do
      # This component has work to do — return it
      Enum.map(actionable, fn {task_module, reqs} ->
        {component, task_module, reqs}
      end)
    else
      # Check if blocked on dependencies or children
      blocked_on = blocked_traversal_targets(scope, component)
      Enum.flat_map(blocked_on, &find_all_actionable(scope, &1, visited))
    end
  end

  defp blocked_traversal_targets(scope, component) do
    unsatisfied = component.requirements |> Enum.reject(& &1.satisfied)

    deps = if Enum.any?(unsatisfied, &(&1.name == "dependencies_satisfied")) do
      component.dependencies |> Enum.reject(&all_requirements_satisfied?/1)
    else
      []
    end

    children = if Enum.any?(unsatisfied, &(&1.name in ["children_designs", "children_implementations"])) do
      component.child_components |> Enum.reject(&all_requirements_satisfied?/1)
    else
      []
    end

    deps ++ children
  end
end
```

### 4. What Happens to the Develop* Modules

They become thin wrappers that delegate to `RequirementOrchestrator` but retain their role as **aggregation boundaries** for prompt file management and evaluation:

```elixir
defmodule CodeMySpec.AgentTasks.DevelopContext do
  @doc """
  Orchestrate context development by walking requirements.
  """
  def command(scope, session, opts \\ []) do
    component = session.component
    children = get_child_components(scope, component)
    all = [component | children]

    # Find all actionable work across the container
    actionable = Enum.flat_map(all, fn c ->
      Requirements.next_actionable(scope, c)
      |> Enum.map(fn {task_module, reqs} -> {c, task_module, reqs} end)
    end)

    # Generate prompt files for each actionable task
    prompt_files = Enum.map(actionable, fn {comp, task_module, _reqs} ->
      child_session = %{component: comp, project: session.project}
      prompt = task_module.command(scope, child_session)
      path = write_prompt_file(scope, session, comp, task_module, prompt)
      %{component: comp, task_module: task_module, path: path}
    end)

    build_orchestration_prompt(prompt_files)
  end

  def evaluate(scope, session, opts \\ []) do
    component = reload_component(scope, session)
    children = get_child_components(scope, component)
    all = [component | children]

    remaining = Enum.flat_map(all, fn c ->
      c.requirements |> Enum.reject(& &1.satisfied)
    end)

    if Enum.empty?(remaining) do
      cleanup_status_directory(scope, session)
      {:ok, :valid}
    else
      # Re-run command to generate prompts for next batch
      {:ok, :invalid, build_feedback(remaining)}
    end
  end
end
```

The key difference: instead of checking "is phase 2 complete?", it asks "what requirements are actionable?" This naturally handles:
- Phase 1 done, phase 2 ready → generates children spec prompts
- Phase 2 done, phase 3 ready → generates review prompt
- Phase 3 done, phase 4 ready → generates test + code prompts
- All done → valid

The phase sequence **emerges from the prerequisite graph** rather than being hard-coded.

### 5. DevelopLiveView, DevelopLiveContext, DevelopController

Same pattern. The only type-specific logic that remains:

**DevelopLiveView**: Parent uses `LiveViewSpec`/`LiveViewTest`/`LiveViewCode`, children use `ComponentSpec`/`ComponentTest`/`ComponentCode`. This is already encoded in `satisfied_by` — the parent's requirements point to LiveView task modules, children's point to Component task modules.

**DevelopLiveContext**: Parent has no implementation requirements (Registry defines only 5 requirements for `live_context` type, none with artifact_type `:code` or `:tests`). The orchestrator naturally skips it because `next_actionable` returns nothing for the parent after specs are done.

**DevelopController**: No children. `find_all_actionable` returns tasks for the single component. The JSON stub spec creation (`ensure_json_stub_spec`) stays as a pre-flight step in command/3.

### 6. ManageImplementation Simplification

Current flow:
```
resolve_story → resolve_development → find_developable → dispatch to Develop*
```

New flow:
```
resolve_story → find_all_actionable(story.component) → dispatch all in parallel
```

`resolve_development` and its dependency chain walking gets replaced by `RequirementOrchestrator.find_all_actionable/2`, which recursively traverses dependencies and children to find all actionable work across the entire graph.

The dispatch mapping from component type → `Develop*` module stays for aggregation, but the single-component-at-a-time bottleneck goes away. If Story A needs Context work AND LiveView work and they're independent, both dispatch concurrently.

```elixir
# Current (sequential, one component at a time):
{:develop, component, DevelopContext} = resolve_development(scope, story, failures)
DevelopContext.command(scope, session)

# New (parallel, all actionable work):
actionable = RequirementOrchestrator.find_all_actionable(scope, story_component)
# => [{Accounts, ComponentCode, [implementation_file]},
#     {UserLive, LiveViewSpec, [liveview_spec_file]}, ...]

# Group by container for aggregation:
by_container = group_by_parent_container(actionable)
# => %{Accounts => [...], UserLive => [...]}

# Dispatch each container's Develop* in parallel
Enum.map(by_container, fn {container, tasks} ->
  develop_module = develop_module_for(container.type)
  develop_module.command(scope, %{component: container, project: project})
end)
```

### 7. Status File Changes

Current `implementation_status.json`:
```json
{"task": "develop_context", "module_name": "MyApp.Accounts", "component_id": "uuid", "target_story_id": "uuid"}
```

New format supports multiple concurrent tasks:
```json
{
  "target_story_id": "uuid",
  "active_tasks": [
    {"container_type": "context", "component_id": "uuid", "module_name": "MyApp.Accounts"},
    {"container_type": "liveview", "component_id": "uuid", "module_name": "MyApp.UserLive"}
  ]
}
```

## Files to Modify

| File | Changes |
|------|---------|
| `lib/code_my_spec/requirements/requirement_definition.ex` | Add `prerequisites` field to struct |
| `lib/code_my_spec/requirements/requirement_definition_data.ex` | Add `prerequisites` values to all 21 definitions |
| `lib/code_my_spec/requirements.ex` | Add `next_actionable/2` function |
| `lib/code_my_spec/agent_tasks/develop_context.ex` | Replace phase logic with requirements-driven dispatch |
| `lib/code_my_spec/agent_tasks/develop_live_view.ex` | Replace phase logic with requirements-driven dispatch |
| `lib/code_my_spec/agent_tasks/develop_live_context.ex` | Replace phase logic with requirements-driven dispatch |
| `lib/code_my_spec/agent_tasks/develop_controller.ex` | Replace phase logic with requirements-driven dispatch |
| `lib/code_my_spec/agent_tasks/manage_implementation.ex` | Replace `resolve_development` with `find_all_actionable`, support parallel dispatch |

## Files to Create

| File | Purpose |
|------|---------|
| `lib/code_my_spec/agent_tasks/requirement_orchestrator.ex` | Graph traversal: `find_all_actionable/2`, `blocked_traversal_targets/2` |
| `test/code_my_spec/requirements/next_actionable_test.exs` | Unit tests for `next_actionable/2` with various component types |
| `test/code_my_spec/agent_tasks/requirement_orchestrator_test.exs` | Tests for graph traversal, cycle handling, parallel dispatch |

## Files to Delete

None initially. The `Develop*` modules are rewritten in place, not deleted. They retain their role as container-level aggregation points.

## Implementation Sequence

### Phase 1: Foundation (no behavior change)

1. Add `prerequisites` field to `RequirementDefinition` struct (default: `[]`)
2. Populate `prerequisites` in `RequirementDefinitionData` for all 21 definitions
3. Add `Requirements.next_actionable/2`
4. Write tests for `next_actionable/2` covering each component type's requirement graph
5. Validate: existing tests pass, `next_actionable` returns same sequence as current phases

### Phase 2: RequirementOrchestrator

6. Create `RequirementOrchestrator` with `find_all_actionable/2`
7. Write tests: single component, dependency traversal, hierarchy traversal, cycle detection
8. Validate: orchestrator finds same work as current `resolve_development`

### Phase 3: Rewrite Develop* modules (one at a time)

9. **DevelopController** first (simplest — 2 phases, no children, lowest risk)
   - Replace phase logic with `next_actionable` dispatch
   - Keep `ensure_json_stub_spec` pre-flight
   - Verify existing tests pass

10. **DevelopContext** second (most complex — 4 phases, children, design review)
    - Replace phase logic
    - Verify phase ordering emerges correctly from prerequisites

11. **DevelopLiveView** third
    - Verify parent/child task module dispatch works via `satisfied_by`

12. **DevelopLiveContext** fourth
    - Verify parent-excluded-from-implementation works via missing requirements in Registry

### Phase 4: ManageImplementation parallel dispatch

13. Replace `resolve_development` with `RequirementOrchestrator.find_all_actionable/2`
14. Add container grouping for parallel dispatch
15. Update status file format for multiple active tasks
16. Update `evaluate/3` to handle multiple concurrent tasks

### Phase 5: Cleanup

17. Extract remaining shared code from Develop* modules into shared helpers
18. Remove dead phase-tracking code
19. Update status docs

## Key Design Decisions

**Prerequisites on definitions, not on persisted requirements**
Prerequisites are structural (spec must exist before code can be written). They don't change per-component — they're properties of the requirement type. Storing them on `RequirementDefinition` (the template) rather than `Requirement` (the instance) keeps the schema clean.

**Develop* modules stay as aggregation boundaries**
A context is a meaningful unit of work — it groups its children, manages prompt files, and provides a single evaluate entry point. The alternative (one flat orchestrator for all component types) loses this natural grouping and makes prompt management harder. The Develop* modules just get simpler internally.

**Traversal not blocking for dependency/hierarchy requirements**
When a component's `dependencies_satisfied` is false, the orchestrator traverses INTO dependencies to find actionable work. This is the key insight: meta-requirements are traversal edges in the graph, not wait states. The same applies to `children_designs` and `children_implementations`.

**Parallel dispatch at container level**
If two independent contexts both have actionable work, ManageImplementation dispatches both. The Develop* modules handle their own internal sequencing via requirements. This doubles throughput for projects with independent feature areas.

**test_file does not depend on implementation_file**
Tests can be written before code (TDD pattern). Only `tests_passing` depends on `implementation_file` because you need both to actually run tests. This allows test writing and code writing to happen in parallel when both are needed.

**Incremental migration via phase validation**
Phase 1 adds prerequisites without changing behavior. We can validate that `next_actionable` produces the same task sequence as the current hard-coded phases before switching over. Each Develop* module migrates independently.

## Risks

**Prompt quality regression** — Current Develop* modules write detailed orchestration prompts with phase-specific instructions ("implement schemas first", "LiveComponents before LiveViews"). The generic approach generates prompts from leaf tasks, which are already good, but the orchestration wrapper text may lose some of this guidance. Mitigation: keep orchestration prompt templates in the Develop* modules, just populate them from requirements instead of phases.

**Evaluation timing** — Requirements sync must run between task completions for `next_actionable` to see updated satisfaction. This already happens (sync runs on every stop hook), but parallel dispatch means multiple syncs could race. Mitigation: sync is per-component and idempotent.

**Cycle detection** — The prerequisite graph must be acyclic. Currently implicit ordering can't have cycles, but explicit prerequisites could introduce them if misconfigured. Mitigation: validate the prerequisite graph at compile time or startup.
