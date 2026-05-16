# CodeMySpec.AgentTasks.ComponentSpec

Agent task module for generating component specification documents via Claude Code slash commands.

This module orchestrates the workflow of creating component spec documents through AI agents. It provides two main entry points: `command/3` builds the initial prompt for Claude with design rules and document specifications, while `evaluate/3` validates the generated spec against artifact requirements and checks for persisted problems on the spec file.

## Delegates

None

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Components.Registry
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils
