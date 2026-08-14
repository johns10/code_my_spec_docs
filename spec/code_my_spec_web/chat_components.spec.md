# CodeMySpecWeb.ChatComponents

The message components every conversation surface renders through — the support inbox, the story interview, and the record of what an agent did.

Each of those grew its own `turn/1`, `chat_side/1` and `chat_bubble/1`, and they drifted the way copies do: two rendered tool calls differently, and a tool result was labelled `tool-result` in one view and `tool-call` in another. One set removes the drift and gives the interaction work ahead — a question answered inside the transcript — a single place to land.

## What a surface has to declare

**`own_role` — which side is "mine".** In the support inbox the reader is the operator, so the operator sits right; in an agent conversation the reader is watching, and the assistant sits right. Same markup, different answer, so it is an argument rather than a hardcoded clause.

**`tool_role` — what `role: :tool` means.** Not cosmetic. `ConversationRecorder.write_tool_calls/3` writes a tool *call* with that role and `Conversations.add_tool_result/4` writes a tool *result* with it. A component cannot tell them apart, because the difference is not in the message. The surface says which it has, and both stay honestly labelled. The ambiguity belongs in the data; naming it here is how it stops being invisible.

## Components

- `turn/1` — dispatches a message to the right one. A halted or failed turn is a notice before it is a message; a turn carrying calls is those calls rather than an empty bubble; a turn with neither text nor calls renders hidden rather than as a blank bubble.
- `chat_message/1` — a person's or an agent's words, with an `:extra` slot for anything that belongs inside the bubble. The inbox puts attachments there, and its text is conditional because a message can be attachments and nothing else.
- `tool_call/1` — a call the agent made. The name is read every time and the arguments occasionally, so the name is always on screen and the arguments sit behind a closed disclosure; a payload past 600 bytes is cut and says so *inside* that disclosure, keeping a closed block one line tall. A qualified MCP name is one unbreakable 45-character token, wider than a phone, so the name is allowed to shrink and to break — without both it overflowed its card and the reader lost which tool ran.
- `tool_result/1` — what a call came back with.
- `notice/1` — something about the conversation rather than in it: halted, failed, a gap in the record. Warning-toned, because each means the transcript is not the whole story.
- `question/1` — a question the agent asked, answerable where it is shown. Lifted out of `QuestionLive.Show` unchanged; that page still renders it, and a transcript can too. Answered questions keep rendering, showing what was asked beside what was said — in a transcript the answer is part of the record, not a modal that closes.

## Runs of calls fold

A model that reads five files before saying anything produced five blocks of the same shape, and the prose either side went off screen. `group_turns/2` folds a run of two or more consecutive calls into one line — "used 5 tools" — closed, with each call inside it opening to its own arguments and no others.

Two is the threshold rather than one: a lone call dressed as a group is a disclosure hiding a single thing, which costs a click and says nothing.

Every `data-test` the spex assert on is part of the contract: `message`, `tool-call`, `tool-call-group` (with its `data-count`), `tool-result`, `chat-halted`, `chat-failed`, and the marker `notice/1` is given.

## Type

module

## Dependencies

- CodeMySpec.Conversations
- CodeMySpecWeb.CoreComponents
