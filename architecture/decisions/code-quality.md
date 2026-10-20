---
deps: [credo, ex_slop, sobelow]
---
# Gate code with Credo, ExSlop and Sobelow

## Status
Accepted

## Context
Static analysis runs through `credo` (with `ex_slop` checks) and `sobelow`; they are analyzers in the promotion gate.

## Decision
Gate code with Credo, ExSlop and Sobelow.

## Consequences
Recorded so every direct dependency in `mix.exs` is covered by a decision (issue bce21d41); the original reasoning was not written down at the time. Replace this with the real trade-offs when someone revisits the choice.
