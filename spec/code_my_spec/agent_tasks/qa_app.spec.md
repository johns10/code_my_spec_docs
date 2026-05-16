# CodeMySpec.AgentTasks.QaApp

## Type

module

Orchestrator task for browser-based QA of the running app. Analyzes the project's routes, stories, and BDD spec coverage, then delegates per-story QA testing to QaStory workers using story IDs. Provides two entry points: `command/3` builds the orchestration prompt with router content, stories, BDD coverage, and dispatch instructions; `evaluate/3` checks that QA results exist per story and validates the summary.

## Dependencies

- CodeMySpec.AgentTasks.QaStory
- CodeMySpec.BddSpecs
- CodeMySpec.BddSpecs.SpecProjector
- CodeMySpec.Environments
- CodeMySpec.Stories
