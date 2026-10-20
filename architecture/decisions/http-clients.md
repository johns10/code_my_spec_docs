---
deps: [req, req_llm]
---
# Use Req for HTTP and ReqLLM for model calls

## Status
Accepted

## Context
External HTTP is made with `req`; model providers are reached through `req_llm`.

## Decision
Use Req for HTTP and ReqLLM for model calls.

## Consequences
Recorded so every direct dependency in `mix.exs` is covered by a decision (issue bce21d41); the original reasoning was not written down at the time. Replace this with the real trade-offs when someone revisits the choice.
