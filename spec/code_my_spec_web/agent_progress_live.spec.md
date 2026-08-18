# CodeMySpecWeb.AgentProgressLive

The non-technical user's live spectator screen — what the agent is doing, in
language that does not assume they can read the code.

Left rail: project-level requirement milestones with status. Centre: one vertical
timeline per session, most-recently-updated first. The active session has its
current step auto-expanded — the last task that is not completed or cancelled —
and that step shows its artifact plus plain-language help, a curated body and
video for the major task types and a generic explanation otherwise. Any task can
be expanded to override the auto-focus.

Liveness is recency, not status. The PostToolUse hook touches the session's
`updated_at` on every tool call, so "active" means "updated in the last few
minutes" — known on load, with no polling and no timer. Persisted task status is
deliberately not trusted as a live signal, because a crashed agent leaves stale
`:active` tasks behind and the screen would report work nobody is doing.

Sessions with no activity and sessions with no tasks are hidden, and the list is
capped at the ten most recent, so the timeline stays readable.

This spec used to name `CodeMySpecLocalWeb.AgentProgressLive`, which is not where
the code is or ever was: it lives in `CodeMySpecWeb` and is routed there, and the
harness UI's move into `CodeMySpecWeb` left the document behind. The graph asked
for an implementation file for a module nobody was going to write while the real
one sat beside it.

## Type

liveview

## Route

`/app/projects/:project_id/progress`

## Dependencies

- CodeMySpec.Sessions
- CodeMySpec.Requirements
- CodeMySpec.TaskHelp
