# CodeMySpec.Permissions

Asking a human to approve something an agent cannot decide alone, and applying
their answer.

Today that is one thing: tapping out of the autonomous loop. An agent in
continuous mode cannot clear `session.continuous` itself — that is the point of
the flag — so it raises a request, a human approves or rejects it on their
phone, and the decision comes back over a socket and is applied to the session.

`TapOut`, `TapOutWaiter` and `PermissionSocket` existed first and callers reached
straight into them: the `tap_out` MCP tool, both permission controllers, a spex
and the fixtures bridge — five consumers, all naming an internal. That is the
coupling a context exists to remove, and every sibling here (`Notifications`,
`Sessions`, `Analysis`) already reads that way.

An earlier version of this spec described "a Slipstream WebSocket client that
connects to the production server's permission channel and waits for a
decision", which is `PermissionSocket`'s job written one level up. That made the
context look like a namespace anchor rather than an API, and the requirement
graph asked for an implementation nobody could justify writing. The description
above is what the context is actually for; the socket is one of its parts, stays
internal, and the two controllers naming it should move here when they next
change.

Everything below delegates — the behaviour stays in the modules that have it and
are already tested through it.

## Type

context

## Delegates

- request/2: Permissions.TapOut.request/2
- respond/4: Permissions.TapOut.respond/4
- topic/0: Permissions.TapOut.topic/0

## Dependencies

- CodeMySpec.Auth
- CodeMySpec.Repo
- CodeMySpec.Sessions
- CodeMySpec.Users
- Phoenix.PubSub

## Components

### Permissions.TapOut

Registers a tap-out request against a session and applies the decision when it
arrives. Owns the PubSub topic both halves talk over.

### Permissions.TapOutWaiter

Holds a pending request until a human answers it, so the agent that raised it is
never blocked on a person.

### Permissions.PermissionSocket

Slipstream client connected to the server's permission channel — how a decision
made on a phone reaches this working copy. Supervised by the application, not
called by anything.
