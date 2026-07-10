# CodeMySpec.Conversations

Chat domain for operator-to-end-user messaging. Owns conversations (one thread per end-user, scoped to account+project) and messages. Participant-agnostic envelope: a message's author is identified by (role, sender_id) with role in [:user, :operator] and :assistant reserved for future LLM participants. Human-to-human only in v1; no streaming/parts/tool-call/model-config machinery. Account-scoped so any CMS user in the account can read and reply; end-users isolated to their own thread.

## Type

context
