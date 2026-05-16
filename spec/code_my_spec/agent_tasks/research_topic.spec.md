# CodeMySpec.AgentTasks.ResearchTopic

## Type

module

Per-topic agent task for deep research on a technology decision. Generates a self-contained research prompt that includes the full research methodology, evaluation criteria, and output format. The prompt file is written to a status directory and picked up by whatever subagent the orchestrator dispatches — no specific subagent is required.

In the requirement flow, this task runs AFTER TechnicalStrategy has created the ADR. Its job is deep research: searching Hex.pm, reading official docs, evaluating community health, and producing knowledge entries. The ADR already exists and provides context for the research.

Produces:
- `.code_my_spec/knowledge/{topic}/` — knowledge entries (getting_started.md, configuration.md, patterns.md, etc.)

Cleans up `.code_my_spec/status/research/{topic}.md` on successful validation.

Subsume useful information from `/Users/johndavenport/Documents/github/code_my_spec_cli/CodeMySpec/agents/researcher.md` as it will be deprecated.

## Dependencies

- CodeMySpec.Environments
- CodeMySpec.Paths
