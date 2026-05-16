# CodeMySpec.AgentTasks.LiveViewSpec

## Type

module

Generates a specification for a LiveView page or component following the UI spec format: route, params, child components, user interactions (action → behavior + context calls), dependencies, and a structural Design section. The Design section describes layout structure, DaisyUI component choices, and responsive behavior in prose — not renderable HTML. Like ComponentSpec but for UI components — produces specs that LiveViewTest can write assertions against and LiveViewCode can implement to.

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Components.Registry
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils
