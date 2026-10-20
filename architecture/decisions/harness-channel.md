---
deps: [slipstream, mint_web_socket]
---
# Connect the harness to the server over a Phoenix channel client

## Status
Accepted

## Context
The harness holds a Phoenix channel to the server using `slipstream`, over `mint_web_socket`.

## Decision
Connect the harness to the server over a Phoenix channel client.

## Consequences
Recorded so every direct dependency in `mix.exs` is covered by a decision (issue bce21d41); the original reasoning was not written down at the time. Replace this with the real trade-offs when someone revisits the choice.
