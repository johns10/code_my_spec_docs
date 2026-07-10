# CodeMySpec.Conversations.Message

A single message in a conversation. Has a text body and an author identified by (role, sender_id): role is :user (end-user) or :operator (a CMS user in the account), with :assistant reserved for future LLM authors. Ordered by inserted_at. No streaming/parts/tool-call structure in v1 — body is plain text.

## Type

schema
