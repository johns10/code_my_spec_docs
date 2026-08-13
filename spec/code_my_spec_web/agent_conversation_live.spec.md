# CodeMySpecWeb.AgentConversationLive

Read-only view of one agent conversation — the turns it took, the tools it called and what they returned, with sub-agent turns attributed to the sub-agent. Streams new turns in as the agent takes them. Deliberately separate from InboxLive: that is a support queue where a person is writing to you, this is a machine you are watching.

One conversation is one Claude session, not one project. A project has as many sessions at once as it has working copies being worked in, and merging them produces a single interleaved transcript answering no question anybody asked. A model turn arrives addressed to a working copy — all `/v1/messages` can carry, since the Anthropic API has no session and nothing sits between the agent and the proxy to add one — and the server resolves that to the session running there through `Sessions.external_id_for_harness/1`, naming the conversation with Claude's own session id.

Renders through `CodeMySpecWeb.ChatComponents`, shared with the story interview and the support inbox. It passes `tool_role={:call}`, because `role: :tool` means a tool *call* here — that is what `ConversationRecorder.write_tool_calls/3` writes with it.

Read-only today, but not permanently: `ask_user_question` and `send_message` are meant to land in the transcript, so a notification takes the reader to the conversation the question came from rather than to a page showing the question and none of the work behind it. The interaction is targeted — a specific question answered in place — not a composer.

## Type

liveview

## Dependencies

- CodeMySpec.Conversations
- CodeMySpecWeb.ChatComponents
