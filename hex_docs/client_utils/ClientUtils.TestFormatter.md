# ClientUtils.TestFormatter

ExUnit formatter that:
- Delegates to CLIFormatter for normal terminal output
- Writes JSON results to a file (if configured)
- Caches test events for later querying

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.