# CodeMySpecWeb.Tasks.TaskQueueLive

The engineer's at-a-glance view of the agent's task queue: the requirement being
worked right now and the ordered list of what comes next, on one screen.

Backed directly by `RequirementGraph.next_actionable/1`. The head of the
actionable list is the active task and the tail, up to the configured cap of 25,
is the upcoming list.

An empty actionable list renders an explicit empty state rather than an empty
page, so "everything is satisfied" cannot be mistaken for a render error — the
two look identical otherwise, and the one that means success is the one a reader
is least prepared to see.

Subscribes to this project's file-change events, so every sync — manual or
watcher-driven — re-renders the queue without a refresh.

This spec used to name `CodeMySpecLocalWeb.Tasks.TaskQueueLive`, which is not
where the code is: it lives in `CodeMySpecWeb.Tasks` alongside `NextTaskLive` and
is routed there. The harness UI's move into `CodeMySpecWeb` left the document
behind, so the graph asked for an implementation file for a module nobody was
going to write while the real one sat beside it.

## Type

liveview

## Route

`/app/projects/:project_id/tasks`

## Dependencies

- CodeMySpec.Projects
- CodeMySpec.Requirements
- CodeMySpec.Users
