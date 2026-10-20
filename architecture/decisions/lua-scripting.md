---
deps: [lua]
---
# Use Lua as the scripting language for code mode

## Status
Accepted

## Context
Agents reach most tools through `run_script`, a sandboxed Lua runtime built on the `lua` package.

## Decision
Use Lua as the scripting language for code mode.

## Consequences
Recorded so every direct dependency in `mix.exs` is covered by a decision (issue bce21d41); the original reasoning was not written down at the time. Replace this with the real trade-offs when someone revisits the choice.
