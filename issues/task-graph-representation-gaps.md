# Task Graph Representation Gaps

## Status
accepted

## Severity
medium

## Description

The requirements graph visualization (`/projects/:name/graph`) cannot fully represent the actual execution dependency graph. The graph only shows edges stored in `depends_on` on persisted requirements, but several real dependency relationships are invisible because they don't produce requirements or edges.

## Current Gaps

### 1. Component dependencies invisible for non-context types

Component-to-component dependencies (e.g., `CalculationLive` depends on `Calculations`, `Calculations` depends on `Calculation`) exist in the `dependencies` table but are only surfaced through `DependencyChecker`, which only runs for component types that include `dependencies_satisfied` in their requirement definitions (contexts, coordination_contexts). Default/module-type components don't have this requirement, so their dependency edges never appear in the graph.

The execution model handles this correctly — `ProjectCoordinator.NextActionable` walks dependency chains at runtime regardless of component type. But the graph can't show what it doesn't persist.

**Options:**
- Add `dependencies_satisfied` to `default_requirements()` — simple but adds a requirement to every component that may not need it
- Have the graph projector query the dependencies table directly and add synthetic edges — decouples graph from requirements
- Add a lightweight "dependency edge" concept separate from requirement satisfaction

### 2. Cross-entity ordering not represented

Stories show `component_linked` as actionable even when project-level prerequisites like `issues_resolved` haven't been met. The `ProjectCoordinator.NextActionable` enforces this ordering at runtime (it won't descend into stories until project requirements allow), but the graph has no edges from project → story level to show this.

Similarly, `all_stories_complete` has edges TO each story's `qa_complete` (checker-produced), but there's no reverse: stories don't have edges FROM project requirements showing they're blocked.

**Options:**
- Add cross-level prerequisite edges during sync (e.g., story `component_linked` depends_on project `issues_resolved`)
- Keep the graph as-is and accept it shows per-level ordering only
- Add a separate "execution order" overlay to the graph projector that queries the coordinator logic

### 3. Prerequisite edges for undefined requirements

`implementation_file` has `prerequisites: ["spec_valid", "dependencies_satisfied"]`. For component types that don't define `dependencies_satisfied`, this prerequisite is "vacuously met" in the execution model but previously created phantom edges in the graph pointing to non-existent nodes. This was fixed by filtering prerequisite edges to only include requirements defined for the entity type.

## Root Cause

The requirements system and the execution model (ProjectCoordinator) have different scopes:
- **Requirements**: per-entity satisfaction state, persisted, queryable
- **Execution model**: cross-entity traversal logic, runtime, not persisted

The graph tries to represent the execution model using only persisted requirement edges, but the execution model knows things the requirements don't encode (component dependency chains, cross-level ordering rules, scope-based descent).

## Impact

The graph is useful for seeing per-entity requirement progress and same-level ordering. It correctly shows project → story cross-entity edges (via `all_stories_complete` checker) and story → component edges (via `component_complete` checker). But it misses component → component dependency chains for non-context types and doesn't show the full top-down execution ordering.

## Recommendation

Don't try to force all execution knowledge into persisted requirement edges. Instead, have the graph projector be smarter — query the dependencies table directly and add synthetic edges for component dependencies, regardless of whether `dependencies_satisfied` is a requirement for that type. This keeps the requirement definitions clean while giving the graph full visibility.
