# Anubis.Server.Registry

Behaviour for pluggable session registries and deterministic naming utilities.

The registry is responsible for mapping session IDs to PIDs. Different transports
have different needs:

- STDIO: single session, no registry needed (`Registry.None`)
- HTTP: multiple sessions, need lookup by session ID (`Registry.Local`)

## Naming Utilities

The module also provides deterministic atom naming for internal processes.
These are safe because server modules are compile-time bounded.