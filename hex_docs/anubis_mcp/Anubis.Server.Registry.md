# Anubis.Server.Registry

Behaviour for pluggable session registries and deterministic naming utilities.

The registry is responsible for mapping session IDs to PIDs. Different transports
have different needs:

- STDIO: single session, no registry needed (`Registry.None`)
- HTTP: multiple sessions, need lookup by session ID (`Registry.Local`)

## Naming Utilities

The module also provides deterministic atom naming for internal processes.
These are safe because server modules are compile-time bounded.

## resolve_session_name(registry_mod, registry_name, session_id)

Resolves the session GenServer name via the registry adapter.

Falls back to the default atom-based naming if the adapter does not implement
the optional `session_name/2` callback.

## task_store_name(server)

Default atom name for a server's `Anubis.Server.TaskStore` process. Adapters
may override via the optional `resolve_name/2` callback to return a `:via`
tuple for distributed deployments.

## session_name/2

Returns the GenServer name for a session. Override this to return a `:via` tuple
(e.g. `{:via, Horde.Registry, {name, session_id}}`) when using a distributed registry
that auto-registers processes on `start_link`. The default returns a plain atom.

When a `:via` tuple is returned, `register_session/3` should be a no-op since
registration happens automatically on process start.