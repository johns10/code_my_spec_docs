# CodeMySpecWeb.AgentConversationLive.Index

Every agent session recorded against a project, newest activity first.

Exists because `Show` used to answer "whichever conversation moved most
recently". With one agent that reads as *the* conversation; with five it hides
four, and which one you land on changes as they take turns.

A session carries a name so it can be told apart. The name is generated when the
conversation is created — an index of five UUIDs is the problem this page exists
to solve, and it would have appeared before anyone had a chance to name anything
— and it is editable here, because the useful name is "backend refactor" and only
a person knows that.

## Type

liveview

## Dependencies

- CodeMySpec.Conversations
