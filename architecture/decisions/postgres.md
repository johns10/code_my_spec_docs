---
deps: [postgrex]
---
# Use Postgres as the server database alongside SQLite

## Status
Accepted

## Context
The hosted application stores its data in Postgres through `postgrex`; the CLI and harness use SQLite (see the SQLite decision).

## Decision
Use Postgres as the server database alongside SQLite.

## Consequences
Recorded so every direct dependency in `mix.exs` is covered by a decision (issue bce21d41); the original reasoning was not written down at the time. Replace this with the real trade-offs when someone revisits the choice.
