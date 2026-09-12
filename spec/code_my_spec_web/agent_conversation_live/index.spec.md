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
- CodeMySpecWeb.WorkingCopyLive.Liveness

`Liveness.since/2` rather than a local copy: "how long ago" is one rule, and the
second implementation of a rule is the one that drifts. It already says "just
now" for a negative duration, which is clock skew between the box that stamped
the turn and this one — worth having once and not worth rediscovering here.
