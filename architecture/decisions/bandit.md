# Use Bandit as the HTTP server

## Status
Accepted

## Context
Phoenix needs an HTTP server to handle requests. Phoenix 1.8 defaults to Bandit over the previous Cowboy default.

## Options Considered
- **Bandit** — Pure Elixir HTTP server built on Thousand Island. HTTP/2 support, simpler codebase, better Elixir integration.
- **Cowboy** — Erlang HTTP server. Long-standing Phoenix default, battle-tested.

## Decision
Use Bandit (`~> 1.5`) as the HTTP server. It's the Phoenix 1.8 default, provides HTTP/2 support, and is written in pure Elixir for better debugging and integration with the BEAM ecosystem.

## Consequences
- Standard Phoenix 1.8 choice, no special configuration needed
- HTTP/2 support out of the box
- Pure Elixir stack from HTTP to application
