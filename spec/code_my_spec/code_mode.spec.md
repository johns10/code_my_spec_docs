# CodeMySpec.CodeMode

The sandboxed Lua runtime an agent's tools are called from, and the documentation it looks them up in.

Owns three things: the binding layer that projects Anubis tool modules into a Lua VM (their `schema do` block is already a machine-readable signature and `execute/2` is already a uniform entry point, so both bindings and docs generate from the modules that exist); the evaluation itself, sandboxed by `Lua.new/1` and bounded by `max_instructions` and `max_call_depth`; and the docs surface — an index, focused pages, and search — so a tool's arguments are looked up rather than carried.

Built on `luerl` via the `lua` package. Pure Erlang, no NIFs, which is what makes it safe to ship inside the Burrito binary.

Its MCP surface is two tools on LocalServer. Everything else about the tool list is a registration decision on that server, not this context's business.

## Type

context
