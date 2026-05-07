# Anubis.Transport.StreamableHTTP

A transport implementation that uses Streamable HTTP as specified in MCP 2025-03-26.

This transport communicates with MCP servers via HTTP POST requests for sending messages
and optionally uses Server-Sent Events (SSE) for receiving streaming responses.

## Usage

    # Start the transport with a base URL
    {:ok, transport} = Anubis.Transport.StreamableHTTP.start_link(
      client: client_pid,
      base_url: "http://localhost:8000",
      mcp_path: "/mcp"
    )

    # Send a message
    :ok = Anubis.Transport.StreamableHTTP.send_message(transport, encoded_message)

## Session Management

The transport automatically handles MCP session IDs via the `mcp-session-id` header:
- Extracts session ID from server responses
- Includes session ID in subsequent requests
- Maintains session state throughout the connection lifecycle
- Handles session expiration (404 responses) by reinitializing

## Response Handling

Based on the response status and content type:
- 202 Accepted: Message acknowledged, no immediate response
- 200 OK with application/json: Single JSON response forwarded to client
- 200 OK with text/event-stream: SSE stream parsed and events forwarded to client
- 404 Not Found: Session expired, triggers reinitialization

## SSE Support

The transport can establish a separate GET connection for server-initiated messages.
This allows the server to send requests and notifications without a client request.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## option/0

The options for the Streamable HTTP transport.

- `:base_url` - The base URL of the MCP server (e.g. http://localhost:8000) (required).
- `:mcp_path` - The MCP endpoint path (e.g. /mcp) (default "/mcp").
- `:client` - The client to send the messages to.
- `:headers` - The headers to send with the HTTP requests.
- `:transport_opts` - The underlying HTTP transport options.
- `:http_options` - The underlying HTTP client options.
- `:enable_sse` - Whether to establish a GET connection for server-initiated messages (default false).