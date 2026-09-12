# CodeMySpecWeb.AgentConversationLive

Live context for watching agents work: the list of sessions recorded against a
project, and the read-only transcript of any one of them.

Deliberately separate from `InboxLive`. That is a support queue where a person is
writing to the operator; this is a machine being watched, and nothing here sends
anything back.

One conversation is one Claude session, not one project. A project has as many
sessions at once as it has working copies being worked in, and merging them
produces a single interleaved transcript answering no question anybody asked.
That is why the group is two pages rather than one — `Show` used to mean
"whichever conversation moved most recently", which reads as *the* conversation
while a project has one agent and hides four when it has five.

An earlier version of this file carried `Show`'s description and did not mention
`Index`, so it typed the group as a single `liveview`. That asked the graph for a
parent module no sibling live context has: `EpicsLive` and `IssuesLive` are
`Index` and `Show` and nothing else, and the registry says so outright — "live
contexts have no code file, they are spec-only groupings".

## Type

live_context

## LiveViews

### AgentConversationLive.Index

- **Route:** `/app/projects/:project_id/agent-conversations`
- **Description:** Every agent session recorded against the project, newest
  activity first, with editable names so five of them can be told apart.

### AgentConversationLive.Show

- **Route:** `/app/projects/:project_id/agent-conversation?conversation=<id>`
- **Description:** One session's transcript — turns, tool calls and returns,
  sub-agent turns attributed — streaming in live while the agent runs.

An earlier version of this table gave `Show` a `:conversation_id` path segment
and `Index` the bare `/agent-conversation`. The cockpit decision replaced that:
`Show` *is* the project page, and which session you are reading is a selection
within it (`?conversation=`), so switching agents is a patch and the panels,
preview and pane widths stay where they were. That leaves the singular path
taken, so the list is plural.

## Components

None. Both pages render through `CodeMySpecWeb.ChatComponents`, which is shared
with the story interview and the support inbox and belongs to neither.

## Dependencies

- CodeMySpec.Conversations
- CodeMySpecWeb.ChatComponents
