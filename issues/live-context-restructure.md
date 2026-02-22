# Introduce Live Context Component Type

## Context

The current LiveView system conflates individual LiveViews with what should be "Live Contexts" — a grouping concept analogous to domain Contexts but for the UI layer. In Phoenix, `UserLive` is a namespace/directory containing `UserLive.Index`, `UserLive.Show`, `UserLive.FormComponent`. The system needs to model this hierarchy explicitly:

- **Live Context** (`UserLive`) — spec-only grouping, no code file, has children
- **LiveView** (`UserLive.Index`) — routed page with params, mount, handle_event
- **LiveComponent** (`UserLive.FormComponent`) — stateful component with assigns, phx-target={@myself}

Additionally, `liveview` and `liveview_component` currently share the same `"liveview"` document type, so LiveComponents get a spec format requiring routes they don't have.

---

## Group 1: New Requirement Definitions + Live Context Component Type

### 1A. Add requirement definitions for live_context
**File**: `lib/code_my_spec/requirements/requirement_definition_data.ex`

Add `live_context_spec_file()` and `live_context_spec_valid()` — same pattern as `context_spec_file()`/`context_spec_valid()` but `satisfied_by: CodeMySpec.AgentTasks.LiveContextSpec`.

### 1B. Add `live_context` component type
**File**: `lib/code_my_spec/components/registry.ex`

Add to `@type_definitions`:
```elixir
"live_context" => %{
  requirements: [
    RequirementDefinitionData.live_context_spec_file(),
    RequirementDefinitionData.live_context_spec_valid(),
    RequirementDefinitionData.children_designs(),
    RequirementDefinitionData.children_implementations(),
    RequirementDefinitionData.dependencies_satisfied()
  ],
  document_type: "live_context_spec",
  display_name: "Live Context",
  description: "UI grouping of related LiveViews and LiveComponents under a shared namespace",
  icon: "rectangle-group",
  color: "emerald"
}
```

No implementation_file, test_file, tests_passing — live_context has no code.

### 1C. Update `liveview_component` to use its own document type
**File**: `lib/code_my_spec/components/registry.ex`

Change `document_type` from `"liveview"` to `"liveview_component"`. Keep the same requirements (they point to `LiveViewSpec` which adapts via `component.type`).

---

## Group 2: Document Type Definitions

### 2A. Add `live_context_spec` document type
**File**: `lib/code_my_spec/documents/registry.ex`

Two new section descriptions:
- `@spec_live_context_liveviews` — Lists routed LiveViews with their paths. Each child has a module name, route, and description. Example: `UserLive.Index` with route `/users`.
- `@spec_live_context_components` — Lists LiveComponents shared across views in this context. Each child has a module name and description. Example: `UserLive.FormComponent`.

Document definition:
- Required sections: `["liveviews", "components", "dependencies"]`
- Section descriptions: `type`, `liveviews` (new), `components` (new), `dependencies`

On evaluate, `LiveContextSpec` creates child spec stubs for both listed LiveViews and Components — same pattern as `ContextSpec.create_child_spec_files/3`.

### 2B. Add `liveview_component` document type
**File**: `lib/code_my_spec/documents/registry.ex`

New section descriptions:
- `@spec_assigns` — Table format (Assign, Type, Required, Description). Must include `:id`.
- `@spec_livecomponent_events` — handle_event callbacks with phx-target={@myself}, parent communication via `send(self(), msg)`

Document definition:
- Required sections: `["assigns", "design"]`
- Optional sections: `["events", "dependencies"]`
- Section descriptions: `type`, `assigns`, `events`, `design` (reuse existing), `dependencies`

---

## Group 3: LiveContextSpec Agent Task

### 3A. Create LiveContextSpec
**New file**: `lib/code_my_spec/agent_tasks/live_context_spec.ex`

Follow `ContextSpec` pattern exactly. Key differences:
- `get_design_rules()` → `Rules.find_matching_rules("live_context", "design")`
- `DocumentSpecProjector.project_spec("live_context_spec")`
- Prompt describes a "UI grouping of related LiveViews and LiveComponents"
- `evaluate/3`: validates spec, creates child spec stubs from BOTH the LiveViews section and Components section (reuse `create_child_spec_files` pattern from ContextSpec, but process two sections)
- No user stories in prompt (live contexts are UI groupings, stories map to individual views)

---

## Group 4: DevelopLiveContext Orchestrator

### 4A. Create DevelopLiveContext
**New file**: `lib/code_my_spec/agent_tasks/develop_live_context.ex`

Follow `DevelopLiveView` pattern with these changes:

**Three phases** (no design review):
1. Live context spec (`LiveContextSpec`)
2. Child specs — type-aware dispatch:
   - `"liveview"` children → `LiveViewSpec`
   - `"liveview_component"` children → `LiveViewSpec` (adapts via component.type)
   - Other → `ComponentSpec`
3. Implementation — children only (parent has no code):
   - `"liveview"` → `LiveViewTest`/`LiveViewCode`
   - `"liveview_component"` → `ComponentTest`/`ComponentCode`
   - Implementation order: LiveComponents first, then LiveViews

Key difference from DevelopLiveView: the parent live_context is NOT included in implementation phase (no code file). Only children get tests+code.

### 4B. Keep DevelopLiveView
Keep `DevelopLiveView` as-is for standalone liveviews not part of a live_context. The `live_context` type gets `DevelopLiveContext`; standalone `liveview` keeps `DevelopLiveView`.

---

## Group 5: Session/Task Routing Updates

### 5A. SessionType
**File**: `lib/code_my_spec/sessions/session_type.ex`

Add to `@valid_types`:
- `AgentTasks.DevelopLiveContext`
- `AgentTasks.LiveContextSpec`

### 5B. StartAgentTask
**File**: `lib/code_my_spec/agent_tasks/start_agent_task.ex`

Add to `@session_type_map`:
- `"develop_live_context" => AgentTasks.DevelopLiveContext`
- `"live_context_spec" => AgentTasks.LiveContextSpec`

Add to `resolve_session_type/2`:
```elixir
defp resolve_session_type("spec", %{type: "live_context"}) do
  {:ok, AgentTasks.LiveContextSpec}
end
```
Place BEFORE the existing liveview clause.

### 5C. ManageImplementation
**File**: `lib/code_my_spec/agent_tasks/manage_implementation.ex`

- Add `"live_context"` to `@developable_types`
- Add `task_module_for(%{type: "live_context"})` → `DevelopLiveContext`
- Add `task_key(DevelopLiveContext)` → `"develop_live_context"`
- Add `task_module_from_key("develop_live_context")` → `DevelopLiveContext`
- Add alias for `DevelopLiveContext`

---

## Group 6: Utils Path Handling

### 6A. Update component_files for live_context
**File**: `lib/code_my_spec/utils.ex`

Add `"live_context"` to the live directory injection:
```elixir
type in ["liveview", "liveview_component", "live_context"] -> inject_live_dir(module_path)
```

---

## Group 7: Architecture Proposal Updates

### 7A. Update @proposal_surface_components
**File**: `lib/code_my_spec/documents/registry.ex`

Update to show `live_context` type with `#### Children` subsection listing both LiveViews (with routes) and LiveComponents. Show that standalone liveview is for single-page views with no siblings.

### 7B. Update SurfaceComponentParser to support children
**File**: `lib/code_my_spec/documents/parsers/surface_component_parser.ex`

Add `extract_children/2` (reuse from `ContextParser`) to `parse_component/1`. Return children in the component map.

### 7C. Update Proposal valid types
**File**: `lib/code_my_spec/architecture/proposal.ex`

- Add `live_context` and `liveview_component` to `@valid_types`
- Update `normalize_components` to handle optional `children` field
- Update `to_components` to expand surface component children (like context children)
- Update `sync_and_link_components` to link stories for `live_context` type
- Update `check_story_surface_mapping` to count stories from live_context children
- Update `check_naming_hierarchy` to validate live_context children start with parent name

---

## Group 8: Rules

### 8A. Create live_context_design.md
**New file**: `docs/rules/live_context_design.md`

```yaml
component_type: "live_context"
session_type: "design"
```

Cover: naming convention (`AppWeb.{Feature}Live`), structure (each child LiveView = unique route), scope (focused on single feature area).

### 8B. Update liveview_component_design.md
**File**: `docs/rules/liveview_component_design.md`

Strengthen with LiveComponent-specific guidance: assigns section requirements, events use phx-target={@myself}, parent communication via `send(self(), msg)`.

---

## Group 9: Tests

### 9A. LiveContextSpec tests
**New file**: `test/code_my_spec/agent_tasks/live_context_spec_test.exs`

Follow `ContextSpec` test patterns. Test command/3 generates prompt, evaluate/3 validates spec and creates child stubs.

### 9B. DevelopLiveContext tests
**New file**: `test/code_my_spec/agent_tasks/develop_live_context_test.exs`

Follow `DevelopLiveView` test patterns. Key: test that parent live_context is NOT included in implementation phase.

### 9C. Update SessionType test
**File**: `test/code_my_spec/sessions/session_type_test.exs`

Update `valid_module_atoms/0` count for the two new types.

---

## Verification

1. `mix compile --warnings-as-errors` — clean compile
2. `mix test` — no regressions
3. IEx verification:
   ```elixir
   # live_context_spec document definition exists
   CodeMySpec.Documents.Registry.get_definition("live_context_spec")

   # liveview_component document definition exists (separate from liveview)
   CodeMySpec.Documents.Registry.get_definition("liveview_component")

   # live_context rules match
   CodeMySpec.Rules.find_matching_rules("live_context", "design")

   # Component type registered
   CodeMySpec.Components.Registry.get_type("live_context")
   ```
4. Architecture proposal: `live_context` and `liveview_component` are accepted as valid types

## Critical Files

- `lib/code_my_spec/components/registry.ex` — type definitions
- `lib/code_my_spec/documents/registry.ex` — document type definitions
- `lib/code_my_spec/requirements/requirement_definition_data.ex` — requirement factories
- `lib/code_my_spec/agent_tasks/context_spec.ex` — pattern to follow for LiveContextSpec
- `lib/code_my_spec/agent_tasks/develop_live_view.ex` — pattern to follow for DevelopLiveContext
- `lib/code_my_spec/agent_tasks/manage_implementation.ex` — task routing
- `lib/code_my_spec/agent_tasks/start_agent_task.ex` — session type mapping
- `lib/code_my_spec/sessions/session_type.ex` — valid types list
- `lib/code_my_spec/architecture/proposal.ex` — proposal execution
- `lib/code_my_spec/documents/parsers/surface_component_parser.ex` — children parsing
- `lib/code_my_spec/utils.ex` — file path derivation
