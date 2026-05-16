# CodeMySpec.AgentTasks.ProjectSetup

## Type

module

Agent task that guides developers through complete Phoenix project setup for CodeMySpec integration. Generates comprehensive setup instructions and evaluates current setup state by checking prerequisites, project structure, and dependencies. Designed to be run from a target directory that will become (or already is) a Phoenix project root.

The agent approach (vs running the ScriptGenerator script directly) allows picking up setup from any point and provides flexibility for the agent to adapt to different starting states.

## Dependencies

- CodeMySpec.Environments
