# Remove Rollup Requirement Nodes (all_stories_complete, component_complete)

## Problem

`all_stories_complete` and `component_complete` are requirement nodes that represent **graph traversal**, not actual work. They're single nodes standing in for "check if an entire subtree is satisfied." This creates confusion:

- `get_next_requirement` used to return `component_complete` as "actionable" even though no agent action can satisfy it directly
- Currently hacked around with a `@rollup_requirements` exclusion list in `next_actionable`
- The graph has phantom nodes that inflate the count and confuse agents

## Root Cause

These nodes exist because the prerequisite system only checks within the same entity level (`{entity_type, entity_id, prereq_name}`). Cross-entity checks were implemented as rollup nodes instead of as prerequisite functions.

### `component_complete` (story-level)
- **What it represents:** "Is the component tree under this story's linked component fully implemented?"
- **Who depends on it:** `bdd_specs_passing` (story) — gate: don't run BDD specs until components are built
- **What it should be:** A computed prerequisite function on `bdd_specs_passing` that checks all component-level requirements for this story's component tree

### `all_stories_complete` (project-level)
- **What it represents:** "Are all story subtrees satisfied?"
- **Who depends on it:** `project_qa`, `qa_preflight` (project) — gate: don't QA until implementation done
- **What it should be:** A computed prerequisite function on `project_qa`/`qa_preflight` that checks all story terminal requirements

## Plan

### 1. Make prerequisite checker cross entity boundaries

In `lib/code_my_spec/files/requirement_graph.ex`, change `all_prereqs_met?/2` to support function-based prerequisites alongside name-based ones.

Currently:
```elixir
defp all_prereqs_met?(%{prerequisites: prereqs, entity_type: type, entity_id: id}, satisfaction_map) do
  Enum.all?(prereqs, fn prereq_name ->
    Map.get(satisfaction_map, {type, id, prereq_name}, true)
  end)
end
```

Change prerequisites to support tuples like `{:cross, check_fn}` or special atoms like `:component_tree_satisfied` that trigger cross-entity checks against the full satisfaction map.

### 2. Update story requirement definitions

In `lib/code_my_spec/requirements/story_requirement_definitions.ex` (or wherever story defs live):

- Remove `component_complete` definition entirely
- Change `bdd_specs_passing` prerequisite from `["component_complete"]` to a cross-entity check: "all component reqs for this story's component tree are satisfied"
- `requirement_definition_data.ex` line 364

### 3. Update project requirement definitions

In `lib/code_my_spec/requirements/requirement_definition_data.ex`:

- Remove `all_stories_complete` definition entirely
- Change `project_qa` prerequisite (line 502) to cross-entity check: "all story terminal reqs satisfied"
- Change `qa_preflight` prerequisite (line 545) to same

### 4. Remove compute functions

In `lib/code_my_spec/files/requirement_graph.ex`:

- Remove `check_story("component_complete", ...)` clauses (lines 160-177)
- Remove `check_project("all_stories_complete", ...)` clause (line 307)
- Remove from `@rollup_requirements` (no longer needed)
- Remove from `@late_project_reqs` if present

### 5. Update RequirementCalculator

`RequirementCalculator.component_satisfied?/3` is called by `component_complete`. After removal, verify it's still used elsewhere or remove it too.

## Key Files

- `lib/code_my_spec/files/requirement_graph.ex` — main graph computation, prerequisite checker
- `lib/code_my_spec/requirements/requirement_definition_data.ex` — requirement definitions with prerequisites
- `lib/code_my_spec/files/requirement_calculator.ex` — component tree satisfaction check
- `lib/code_my_spec/files/preloader.ex` — preloads data for graph computation

## Verification

- `get_next_requirement` for Metric Flow should return leaf-level component requirements (spec_file, test_file, etc.) when those block story completion
- `bdd_specs_passing` should not become actionable until all component reqs in the story's tree are satisfied
- `project_qa` should not become actionable until all stories are done
- Total node count should decrease (no more rollup nodes)
- No `component_complete` or `all_stories_complete` in `list_requirements` output
