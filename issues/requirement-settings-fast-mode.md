# Requirement Settings: Fast Mode (Skip Specs & Unit Tests)

## Problem

The full spec → review → code → test lifecycle is too slow for rapid prototyping and marketing demos. Component specs are a middleman — the model writes the spec, then reads the spec to write the code. It's talking to itself through a document.

The model already has architecture proposals, BDD specs, design rules, and similar components as context. It can go straight from architecture to code.

## Design

Two boolean fields on Project:

| Field | Default | When false, skips |
|---|---|---|
| `require_specs` | `true` | `:specification` and `:review` artifact types |
| `require_unit_tests` | `true` | `:tests` artifact type + `tests_passing` |

With both disabled, component requirements collapse to just `[implementation_file]`. Story requirements are unaffected: `component_linked → bdd_specs_exist → bdd_specs_passing → qa_complete`.

### Filtering location

In `RequirementGraph.compute_component_nodes/2` — after getting definitions from Registry, before computing nodes. Filter by `scope.active_project` settings. The graph naturally recomputes edges from the filtered node set.

`parent_child_edges` already handles missing definitions gracefully via `find_def` returning nil → empty edge list. Needs a fallback fan-out source when both spec_valid and review_valid are filtered out:

```elixir
parent_gate = find_def(parent_defs, "spec_valid") 
              || find_def(parent_defs, "review_valid")
              || List.first(parent_defs)
```

### Settings UI

LiveView at `/projects/:project_name/settings` with two checkboxes. Toggle saves to project record. Graph recomputes on next `get_next_requirement` call.

## Files to Modify

- `lib/code_my_spec/projects/project.ex` — add boolean fields (default true)
- New migration — add columns
- `lib/code_my_spec/requirements/requirement_graph.ex` — filter in `compute_component_nodes/2`, fallback in `parent_child_edges`
- `lib/code_my_spec_local_web/live/settings_live.ex` — NEW settings page
- `lib/code_my_spec_local_web/router.ex` — add route
- `lib/code_my_spec_local_web/live/home_live.ex` — add Settings link

## Notes

- `tests_passing` has `artifact_type: :code` but is semantically a test concern — needs special-case handling
- Existing projects default to `true` (full lifecycle, backward compatible)
- Context review gates disappear when specs disabled — children go straight to implementation
- Can be toggled at any time — graph recomputes from current state
