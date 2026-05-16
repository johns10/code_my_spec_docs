# CodeMySpec.AgentTasks.DevelopLiveView

## Type

logic

Orchestrates the full lifecycle of a LiveView from specification through implementation. Mirrors DevelopContext's phased approach: spec the LiveView, spec child components, then implement (tests + code) in dependency order — child components first, then the parent LiveView that composes them. Uses LiveViewSpec/LiveViewTest/LiveViewCode for the parent LiveView and ComponentSpec/ComponentTest/ComponentCode for child components.

Writes prompt files to `docs/status/{root}/{live_view}/` — the same directory tree that StatusWriter uses for status markdown. Paths are derived from the component's module_name, making the whole thing idempotent.

Lifecycle phases:
1. LiveView spec (LiveViewSpec)
2. Component specs (ComponentSpec) for each child
3. Implementation (LiveViewTest + LiveViewCode for parent, ComponentTest + ComponentCode for children in dependency order)

Two main functions:
- `command/3` - Generates prompt files for incomplete phases, returns orchestration prompt
- `evaluate/3` - Validates all phases complete and cleans up prompt files

## Dependencies

- CodeMySpec.AgentTasks.LiveViewSpec
- CodeMySpec.AgentTasks.LiveViewTest
- CodeMySpec.AgentTasks.LiveViewCode
- CodeMySpec.AgentTasks.ComponentSpec
- CodeMySpec.AgentTasks.ComponentTest
- CodeMySpec.AgentTasks.ComponentCode
- CodeMySpec.Requirements
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Environments
