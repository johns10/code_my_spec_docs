# CodeMySpec.AgentTasks.StartAgentTask

Orchestrates agent task session startup. Validates inputs, syncs the project,
resolves the correct AgentTask module, creates a filesystem-backed Session,
and calls the module's `command/2` to generate the initial prompt.

Classifies tasks into five categories — bootstrap, project, componentless,
topic, and component — each with a different startup pipeline.

## Dependencies

- CodeMySpec.AgentTasks
- CodeMySpec.AgentTasks.TaskMarker
- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Environments.Environment
- CodeMySpec.Paths
- CodeMySpec.ProjectSync.FileWatcherServer
- CodeMySpec.ProjectSync.Sync
- CodeMySpec.Sessions
- CodeMySpec.Sessions.Session
