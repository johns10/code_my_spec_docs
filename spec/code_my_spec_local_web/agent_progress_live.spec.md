# CodeMySpecLocalWeb.AgentProgressLive

Live spectator screen for non-technical users at /projects/:project_name/progress. Left: the full project requirement list with status. Center: a timeline of agent sessions with nested tasks, auto-focusing the highest-precedence (earliest project-chain order) active task, with the focused task showing its artifact and plain-language help (curated body + video for major task types, generic otherwise). Subscribes to the project's sessions PubSub topic for real-time updates.

## Type

liveview

## Dependencies

- CodeMySpec.Sessions
- CodeMySpec.Requirements
- CodeMySpec.TaskHelp
