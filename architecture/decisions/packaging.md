---
deps: [burrito, desktop, desktop_webview, desktop_deployment]
---
# Package the CLI with Burrito and the desktop app with Elixir Desktop

## Status
Accepted

## Context
The `cms` binary is built with Burrito; the desktop app uses the Elixir Desktop packages.

## Decision
Package the CLI with Burrito and the desktop app with Elixir Desktop.

## Consequences
Recorded so every direct dependency in `mix.exs` is covered by a decision (issue bce21d41); the original reasoning was not written down at the time. Replace this with the real trade-offs when someone revisits the choice.
