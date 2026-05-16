# CodeMySpec.AgentTasks.FixBddSpecs

## Type

agent_task

Agent task module for fixing failing BDD specifications. Reads spex failures from the Problems table, derives which stories and components they belong to, filters to only failures whose component has a satisfied `implementation_file` requirement, and builds a prompt instructing the agent to fix the implementation code so the specs pass.

## Delegates

None

## Dependencies

- CodeMySpec.Problems
- CodeMySpec.BddSpecs.Parser
- CodeMySpec.Stories
- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Utils
- CodeMySpec.AgentTasks.TaskMarker
