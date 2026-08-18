# CodeMySpecWeb.AgentConversationLive.Show

Read-only view of one agent session's conversation — the turns it took, the tools
it called and what they returned, with sub-agent turns attributed to the
sub-agent via `agent_role`. New turns arrive live while the agent runs, with no
reload and nothing the operator can send back.

One page is one session, taken from the URL. A model turn arrives addressed to a
working copy — all `/v1/messages` can carry, since the Anthropic API has no
session and nothing sits between the agent and the proxy to add one — and the
server resolves that to the session running there through
`Sessions.external_id_for_harness/1`, naming the conversation with Claude's own
session id.

Renders through `CodeMySpecWeb.ChatComponents`, shared with the story interview
and the support inbox. It passes `tool_role={:call}`, because `role: :tool` means
a tool *call* here — that is what `ConversationRecorder.write_tool_calls/3`
writes with it.

Read-only today, but not permanently: `ask_user` and the agent's messages are
meant to land in the transcript, so a notification takes the reader to the
conversation the question came from rather than to a page showing the question
and none of the work behind it. The interaction is targeted — a specific question
answered in place — not a composer.

## Type

liveview

## Dependencies

- CodeMySpec.Conversations
- CodeMySpecWeb.ChatComponents
