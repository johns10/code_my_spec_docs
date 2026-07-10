# CodeMySpec.Conversations.Conversation

One continuous thread between an end-user and the account. Belongs to an account and a project; carries the end-user's identity (external user id/email). Has many messages. Unique per (account, project, end-user) so repeat messages append rather than fork a new thread.

## Type

schema
