# Anubis.Server.Registry.Local

ETS-based session registry for HTTP transports.

Uses a named ETS table with `read_concurrency: true` for fast lookups.
Monitors registered processes for automatic cleanup on crash/shutdown.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.