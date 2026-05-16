# CodeMySpec.AgentTasks.ComponentCode

## Type

module

Agent task module for component implementation sessions with the coding agent. Provides four entry points: `command/2` generates the implementation prompt with spec/test/code paths, project context, and component-type-scoped coding rules; `evaluate/2` checks code artifact requirements and queries persisted problems on the code and test files, returning combined feedback; `analyzers/0` declares the analyzers that keep persisted problems fresh; `orchestrate/1` builds the parent-context prompt that spawns a `@code-writer` sub-agent against this requirement and component.

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils
