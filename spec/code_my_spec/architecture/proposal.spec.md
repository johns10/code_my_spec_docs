# CodeMySpec.Architecture.Proposal

Represents an architecture proposal for a greenfield project. A proposal contains bounded contexts with their child components, surface components (controllers, LiveViews), story mappings, and dependencies between components.

Proposals are ephemeral - they exist only during a design session. Use `validate/1` to check for issues before `execute/2`.

## Type

module

## Fields

| Field | Type | Required | Description | Constraints |
| ----- | ---- | -------- | ----------- | ----------- |
| app_name | string | Yes | Application module name (e.g., "MetricFlow") | Defaults to "App" |
| contexts | list(context) | No | Bounded contexts with child components | Defaults to [] |
| surface_components | list(component) | No | Surface components (LiveViews, Controllers) | Defaults to [] |
| dependencies | list(dependency) | No | Component dependencies as from/to pairs | Defaults to [] |
| unmapped_story_ids | list(integer) | No | Story IDs not mapped to any component | Defaults to [] |

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Stories
- CodeMySpec.Documents
