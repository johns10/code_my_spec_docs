# Requirements as Task Graph: Unify Requirements Across Entity Levels

## Status
accepted

## Severity
high

## Description

The requirements system already encodes a dependency graph via `prerequisites` within each entity level (project, story, component). But cross-entity links are handled by special checkers (`AllStoriesCompleteChecker`, `ComponentCompleteChecker`, `HierarchicalChecker`) rather than explicit graph edges. The `Tasks` context projects this same information into a separate table with explicit dependency rows — pure duplication.

The goal: requirements ARE the task graph. One graph, queryable, spanning project → story → component levels. Kill the Tasks context.

## Current State

Three disconnected requirement graphs:
- **Project requirements**: `project_setup → technical_strategy → architecture → ... → all_stories_complete → qa_preflight → ...`
- **Story requirements**: `component_linked → bdd_specs_exist → component_complete → bdd_specs_passing → qa_complete`
- **Component requirements**: `spec_file → spec_valid → implementation_file → test_file → tests_passing`

Cross-entity edges exist only as checker logic:
- `all_stories_complete` checker queries all stories, checks if their requirements are satisfied
- `component_complete` checker checks the linked component tree
- `children_designs` / `children_implementations` check child components

The Tasks context (`CodeMySpec.Tasks`) duplicates this into a `tasks` table with explicit `depends_on` edges.

## Design

### 1. Add `depends_on` to persisted Requirements

Add a `depends_on` field to the `requirements` table — a list of `{entity_type, entity_id, requirement_name}` tuples (or a join table). This makes cross-entity edges explicit and queryable.

At sync time, when `all_stories_complete` is evaluated, store edges to each story's terminal requirement. When `component_complete` is evaluated, store edges to each component's terminal requirement.

### 2. Same-level links: already done via `prerequisites`

`prerequisites` on `RequirementDefinition` handles same-entity ordering. These are static (defined in code). At sync time, persist them as edges on the requirement record so the graph is fully queryable from the DB without loading definitions.

### 3. Cross-level links: computed at sync time

During `sync_project_requirements`:
- `all_stories_complete` gets edges to each story's `qa_complete` requirement
- `issues_triaged` / `issues_resolved` get edges to component requirements that surface issues

During `sync_story_requirements`:
- `component_complete` gets edges to each component's `tests_passing` (or terminal requirement)
- `bdd_specs_passing` gets edges to component implementation requirements

During `sync_component_requirements` (for containers):
- `children_designs` gets edges to each child's `spec_valid`
- `children_implementations` gets edges to each child's `tests_passing`
- `dependencies_satisfied` gets edges to each dependency's terminal requirement

### 4. Graph queries

With edges persisted, the full graph is queryable:
```elixir
# All requirements blocking this one
Requirements.blocking(requirement) → [%Requirement{}, ...]

# All requirements this one blocks
Requirements.blocked_by(requirement) → [%Requirement{}, ...]

# Full project graph (for visualization)
Requirements.project_graph(scope) → %{nodes: [...], edges: [...]}

# Next actionable across the entire project
Requirements.next_actionable_project(scope) → [%Requirement{}, ...]
```

### 5. Visualization

The requirements graph replaces the Mermaid task graph. `/projects/:name/graph` renders the full cross-entity requirement graph. Nodes are requirements, edges are prerequisites + cross-entity dependencies. Color by satisfaction status.

### 6. Delete Tasks context

Once edges are persisted on requirements:
- Delete `lib/code_my_spec/tasks.ex` and `lib/code_my_spec/tasks/`
- Delete `priv/repo/migrations/20260320235122_create_tasks.exs` (or migrate to drop)
- Delete `TaskGraphProjector`, `TaskGraphController`
- Remove task-related routes from old and new routers

## Migration Path

1. Add `depends_on` column (jsonb/text) to requirements table
2. Update `sync_project_requirements` to persist same-level prerequisite edges
3. Update cross-entity checkers to persist edges when computing satisfaction
4. Add graph query functions to Requirements context
5. Add graph visualization to local web
6. Verify all orchestration works from requirements graph
7. Delete Tasks context

## Key Insight

The checkers already compute the cross-entity edges — they just don't persist them. `AllStoriesCompleteChecker` already iterates stories and checks their requirements. It just needs to also write `depends_on` edges as a side effect. The checker result (satisfied/not) stays the same; we just capture the edges it traversed.
