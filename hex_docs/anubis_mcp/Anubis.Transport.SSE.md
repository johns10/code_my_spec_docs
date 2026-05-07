# Anubis.Transport.SSE

A transport implementation that uses Server-Sent Events (SSE) for receiving messages
and HTTP POST requests for sending messages back to the server.

> #### Deprecated {: .warning}
>
> This transport has been deprecated as of MCP specification 2025-03-26 in favor
> of the Streamable HTTP transport (`Anubis.Transport.StreamableHTTP`).
>
> The HTTP+SSE transport from protocol version 2024-11-05 has been replaced by
> the more flexible Streamable HTTP transport which supports optional SSE streaming
> on a single endpoint.
>
> For new implementations, please use `Anubis.Transport.StreamableHTTP` instead.
> This module is maintained for backward compatibility with servers using the
> 2024-11-05 protocol version.

> ## Notes {: .info}
>
> For initialization and setup, check our [Installation & Setup](./installation.html) and
> the [Transport options](./transport_options.html) guides for reference.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## server/0

The options for the MCP server.

- `:base_url` - The base URL of the MCP server (e.g. http://localhost:8000) (required).
- `:base_path` - The base path of the MCP server (e.g. /mcp).
- `:sse_path` - The path to the SSE endpoint (e.g. /mcp/sse) (default `:base_path` + `/sse`).

## option/0

The options for the SSE transport.

- `:name` - The name of the transport process, respecting the `GenServer` "Name Registration" section.
- `:client` - The client to send the messages to, respecting the `GenServer` "Name Registration" section.
- `:server` - The server configuration.
- `:headers` - The headers to send with the HTTP requests.
- `:transport_opts` - The underlying HTTP transport options to pass to the HTTP client. You can check on the [Mint docs](https://hexdocs.pm/mint/Mint.HTTP.html#connect/4-transport-options)
- `:http_options` - The underlying HTTP client options to pass to the HTTP client. You can check on the [Finch docs](https://hexdocs.pm/finch/Finch.html#t:request_opt/0)