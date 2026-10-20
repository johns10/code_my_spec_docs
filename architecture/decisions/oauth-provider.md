---
deps: [ex_oauth2_provider]
---
# Act as an OAuth2 provider with ex_oauth2_provider

## Status
Accepted

## Context
The application issues OAuth2 credentials to clients through `ex_oauth2_provider`.

## Decision
Act as an OAuth2 provider with ex_oauth2_provider.

## Consequences
Recorded so every direct dependency in `mix.exs` is covered by a decision (issue bce21d41); the original reasoning was not written down at the time. Replace this with the real trade-offs when someone revisits the choice.
