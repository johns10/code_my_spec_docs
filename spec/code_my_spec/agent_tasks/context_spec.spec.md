# CodeMySpec.AgentTasks.ContextSpec

## Type

module

Consolidated context spec session for Claude Code slash commands. Generates comprehensive prompts for creating Phoenix bounded context specifications with design rules, user stories, and similar component examples. Validates generated specs against artifact requirements, checks for persisted problems on the spec file, and creates child component spec files from parsed sections.

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Components.Registry
- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Stories
- CodeMySpec.Utils
