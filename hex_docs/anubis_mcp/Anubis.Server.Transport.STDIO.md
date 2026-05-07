# Anubis.Server.Transport.STDIO

STDIO transport implementation for MCP servers.

This module handles communication with MCP clients via standard input/output streams,
processing incoming JSON-RPC messages and forwarding responses directly to the
Session process.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## option/0

STDIO transport options

- `:server` - The server module (required)
- `:name` - Optional name for registering the GenServer