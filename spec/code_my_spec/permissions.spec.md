# CodeMySpec.Permissions

Asking a human to approve something an agent cannot decide alone, and applying
their answer.

Today that is one thing: tapping out of the autonomous loop. An agent in
continuous mode cannot clear `session.continuous` itself — that is the point of
the flag — so it raises a request, a human approves or rejects it on their
phone, and the decision comes back over a socket and is applied to the session.

## Why a context, when three modules already do the work

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
above is what the context is actually for; the socket is one of its parts.

## Type

context

## Dependencies

- CodeMySpec.Auth
- CodeMySpec.Repo
- CodeMySpec.Sessions
- CodeMySpec.Users
- Phoenix.PubSub

## Public API

Delegating, deliberately — the behaviour stays in the modules that have it and
are already tested through it.

- `request/2` — register a tap-out request on a session. Returns `{:ok, request_id}`
  immediately; the decision arrives later.
- `respond/4` — apply a human's `:approve` or `:reject` to a pending request.
- `topic/0` — the PubSub topic carrying `{:tap_out_requested, …}` and
  `{:tap_out_decision, …}`.

`PermissionSocket` stays internal. It is a supervised client the application
starts, not something a caller reaches for, and the two controllers that name it
today should move to this context when they next change.
