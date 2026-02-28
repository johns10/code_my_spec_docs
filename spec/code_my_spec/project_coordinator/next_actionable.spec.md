# CodeMySpec.ProjectCoordinator.NextActionable

Finds the next actionable requirement for a project by recursively descending through entities. Uses the `scope` field on requirements to control how descent happens:

- `:local` — requirement is about this entity itself, return immediately
- `:children` — requirement depends on child entities worked in parallel (agent decides order)
- `:dependencies` — requirement depends on a serial chain, descend one-at-a-time and return first with work

Both `:children` and `:dependencies` return an error when descent finds nothing actionable.

Expects all requirements to already be synced to the database. Does not fabricate virtual requirements from definitions.

## Functions

### call/2

```elixir
@spec call(Scope.t(), struct()) :: {:ok, Requirement.t()} | :complete | {:error, String.t()}
```

Entry point. Loads requirements for the entity, finds the first stuck requirement (unsatisfied with met prerequisites), then dispatches based on its `scope`.

**Process**:
1. Ensure entity has requirements loaded (preload if needed)
2. `find_stuck/2` — walk registry definitions in order, find first unsatisfied with met prereqs, return the matching DB record
3. `resolve/2` — dispatch on `req.scope`:
   - `nil` → `:complete` (nothing stuck)
   - `:local` → `{:ok, req}` immediately
   - `:children` → `descend_children/2` validates children have work, then returns the **parent** requirement (not the child's). Fallback to `{:error, "requirement unsatisfied but all children are satisfied"}`
   - `:dependencies` → `descend_dependencies/2`, fallback to `{:error,  "requirement unsatisfied but all dependencies are satisfied"}`

**Test Assertions**:

- call/2 returns first unsatisfied requirement with met prerequisites
- call/2 returns :complete when all requirements are satisfied
- call/2 with :local scope returns requirement immediately regardless of satisfied_by
- call/2 with :local scope and satisfied_by: nil returns requirement (not :complete)
- call/2 with :children scope validates children have work, returns **parent** requirement (not child's)
- call/2 with :children scope returns error when no children have work
- call/2 with :dependencies scope descends into serial dependency chain
- call/2 with :dependencies scope iterates stories by priority for project-level requirements
- call/2 with :dependencies scope walks component dependency tree for story-level requirements
- call/2 with :dependencies scope returns error when chain is complete but requirement unsatisfied

### descend_children/2 (private)

For `:children` scope. Handles component → child components via `parent_component_id`.

Iterates child components using `Components.list_child_components/2`, calling `call/2` on each to validate at least one child has actionable work. Returns first found, propagates errors, or `:complete`. The caller (`resolve/2`) returns the **parent** requirement — the execution layer (Dispatch) uses Orchestrate for child orchestration.

### descend_dependencies/2 (private)

For `:dependencies` scope. Handles three entity types:

- **Project** → iterates stories in priority order via `list_project_stories_by_priority/1`, returns first story with actionable work
- **Story** → gets linked component (`story.component_id`), walks its dependency tree via `walk_dependency_chain/3`
- **Component** → walks its own dependency tree via `walk_dependency_chain/3`

`walk_dependency_chain/3` uses `ProjectCoordinator.find_next_in_chain/2` to find the leaf-most component ready for work, then recursively calls `find_stuck` + `resolve` on it.

### find_stuck/2 (private)

Walks registry definitions in order. Returns the first definition that is:
1. Not satisfied (no DB record or DB record has `satisfied: false`)
2. Has all prerequisites met (satisfied, or vacuously met if not in this entity's definition list)

Returns the matching DB `%Requirement{}` record. Returns `nil` if no definition has a matching DB record (all satisfied or none exist).

## Dependencies

- `CodeMySpec.Requirements.Registry` — provides ordered requirement definitions per entity type
- `CodeMySpec.ProjectCoordinator.find_next_in_chain/2` — dependency chain traversal
- `CodeMySpec.Components.list_child_components/2` — child component lookup
- `CodeMySpec.Stories.list_project_stories_by_priority/1` — priority-ordered story listing
