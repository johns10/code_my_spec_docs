# Sessions — Future Story Candidates

Story 469 ("Session Management") was deleted on 2026-05-12 because its
criteria described a filesystem-backed design that was abandoned in
favor of the Ecto-schema sessions in postgres. The thin SessionsLive
view at `/projects/:project_name/sessions` is the only user-facing
surface and felt too anemic to justify its own story at that scope.

If/when sessions become a richer surface, the candidate framings are:

## Candidate: Agent-facing session task management

> *As an agent, I want to see and manage my own session tasks so that I
> can pick up an in-flight task, mark stale tasks inactive, and resume
> across restarts without manual intervention.*

MCP-surface story. Would cover:
- Listing the agent's own active tasks on the current session
- Marking specific tasks inactive (e.g. abandoned)
- Resuming an in-progress task across session boundaries
- Visibility into session state via the same MCP tools other agent
  flows use (`evaluate_task`, etc.)

## Candidate: Session stop marks open tasks inactive

> *When a session stops (deliberate or crash), tasks left in `:active`
> status on that session should be marked `:inactive` (or similar) so
> the next session start doesn't see a phantom open task. The user
> explicitly flagged this as "good but not urgent right now"
> (2026-05-12).*

Session-lifecycle / housekeeping concern. Probably belongs as a
sub-story on whatever owns session lifecycle (StopController?
StartAgentTask?). Not urgent.

## What exists today (for context)

- `Sessions.Session` Ecto schema with statuses `:active | :complete |
  :failed | :cancelled`, embeds `Task` (with its own status).
- `AgentTasks.StartAgentTask` creates sessions, enriches scope, calls
  the task module's `command/3`.
- `CodeMySpecLocalWeb.SessionsLive` — read-only browse: list,
  show-session, show-task. No mutations.
- No agent-facing MCP tools for sessions/tasks today.
