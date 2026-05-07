# Mint.WebSocket

HTTP/1 and HTTP/2 WebSocket support for the Mint functional HTTP client

Like Mint, `Mint.WebSocket` provides a functional, process-less interface
for operating a WebSocket connection. Prospective Mint.WebSocket users
may wish to first familiarize themselves with `Mint.HTTP`.

Mint.WebSocket is not fully spec-conformant on its own. Runtime behaviors
such as responding to pings with pongs must be implemented by the user of
Mint.WebSocket.

## Usage

A connection formed with `Mint.HTTP.connect/4` can be upgraded to a WebSocket
connection with `upgrade/5`.

```elixir
{:ok, conn} = Mint.HTTP.connect(:http, "localhost", 9_000)
{:ok, conn, ref} = Mint.WebSocket.upgrade(:ws, conn, "/", [])
```

`upgrade/5` sends an upgrade request to the remote server. The WebSocket
connection is then built by awaiting the HTTP response from the server.

```elixir
http_reply_message = receive(do: (message -> message))
{:ok, conn, [{:status, ^ref, status}, {:headers, ^ref, resp_headers}, {:done, ^ref}]} =
  Mint.WebSocket.stream(conn, http_reply_message)

{:ok, conn, websocket} =
  Mint.WebSocket.new(conn, ref, status, resp_headers)
```

Once the WebSocket connection has been established, use the `websocket`
data structure to encode and decode frames with `encode/2` and `decode/2`,
and send and stream messages with `stream_request_body/3` and `stream/2`.

For example, one may send a "hello world" text frame across a connection
like so:

```elixir
{:ok, websocket, data} = Mint.WebSocket.encode(websocket, {:text, "hello world"})
{:ok, conn} = Mint.WebSocket.stream_request_body(conn, ref, data)
```

Say that the remote is echoing messages. Use `stream/2` and `decode/2` to
decode a received WebSocket frame:

```elixir
echo_message = receive(do: (message -> message))
{:ok, conn, [{:data, ^ref, data}]} = Mint.WebSocket.stream(conn, echo_message)
{:ok, websocket, [{:text, "hello world"}]} = Mint.WebSocket.decode(websocket, data)
```

## HTTP/2 Support

Mint.WebSocket supports WebSockets over HTTP/2 as defined in rfc8441.
rfc8441 is an extension to the HTTP/2 specification. At the time of
writing, very few HTTP/2 server libraries support or enable HTTP/2
WebSockets by default.

`upgrade/5` works on both HTTP/1 and HTTP/2 connections. In order to select
HTTP/2, the `:http2` protocol should be explicitly selected in
`Mint.HTTP.connect/4`.

```elixir
{:ok, conn} =
  Mint.HTTP.connect(:http, "websocket.example", 80, protocols: [:http2])
:http2 = Mint.HTTP.protocol(conn)
{:ok, conn, ref} = Mint.WebSocket.upgrade(:ws, conn, "/", [])
```

If the server does not support the extended CONNECT method needed to bootstrap
WebSocket connections over HTTP/2, `upgrade/4` will return an error tuple
with the `:extended_connect_disabled` error reason.

```elixir
{:error, conn, %Mint.WebSocketError{reason: :extended_connect_disabled}}
```

Why use HTTP/2 for WebSocket connections in the first place? HTTP/2
can multiplex many requests over the same connection, which can
reduce the latency incurred by forming new connections for each request.
A WebSocket connection only occupies one stream of a HTTP/2 connection, so
even if an HTTP/2 connection has an open WebSocket communication, it can be
used to transport more requests.

## WebSocket Secure

Encryption of connections is handled by Mint functions. To start a WSS
connection, select `:https` as the scheme in `Mint.HTTP.connect/4`:

```elixir
{:ok, conn} = Mint.HTTP.connect(:https, "websocket.example", 443)
```

And pass the `:wss` scheme to `upgrade/5`. See the Mint documentation
on SSL for more information.

## Extensions

The WebSocket protocol allows for _extensions_. Extensions act as a
middleware for encoding and decoding frames. For example "permessage-deflate"
compresses and decompresses the body of data frames, which minifies the amount
of bytes which must be sent over the network.

See `Mint.WebSocket.Extension` for more information about extensions and
`Mint.WebSocket.PerMessageDeflate` for information about the
"permessage-deflate" extension.

## decode(websocket, data)

Decodes a binary into a list of frames.

The binary may received from the connection with `stream/2`.

This function will invoke the `c:Mint.WebSocket.Extension.decode/2` callback
for any accepted extensions.

## Examples

    message = receive(do: (message -> message))
    {:ok, conn, [{:data, ^ref, data}]} = Mint.HTTP.stream(conn, message)
    {:ok, websocket, frames} = Mint.WebSocket.decode(websocket, data)

## encode(websocket, frame)

Encodes a frame into a binary.

The resulting binary may be sent with `stream_request_body/3`.

This function will invoke the `c:Mint.WebSocket.Extension.encode/2` callback
for any accepted extensions.

## Examples

    {:ok, websocket, data} = Mint.WebSocket.encode(websocket, {:text, "hello world"})
    {:ok, conn} = Mint.WebSocket.stream_request_body(conn, websocket_ref, data)

## new(conn, request_ref, status, response_headers, opts \\ [])

Creates a new WebSocket data structure given the server's reply to the
upgrade request.

`request_ref` should be the reference of the request made with `upgrade/5`.
`status` and `response_headers` should be the status code and headers
of the server's response to the upgrade request—see the example below.

The returned [WebSocket data structure](`t:t/0`) is used to encode and decode frames.

This function will setup any extensions accepted by the server using
the `c:Mint.WebSocket.Extension.init/2` callback.

## Options

  * `:mode` - (default: `:active`) either `:active` or `:passive`. This
    corresponds to the same option in `Mint.HTTP.connect/4`.

## Examples

    http_reply = receive(do: (message -> message))

    {:ok, conn, [{:status, ^ref, status}, {:headers, ^ref, headers}, {:done, ^ref}]} =
      Mint.WebSocket.stream(conn, http_reply)

    {:ok, conn, websocket} =
      Mint.WebSocket.new(conn, ref, status, headers)

## recv(conn, byte_count, timeout)

Receives data from the socket.

This function is used instead of `stream/2` when the connection is
in `:passive` mode. You must pass the `mode: :passive` option to
`new/5` in order to use `recv/3`.

This function wraps `Mint.HTTP.recv/3`. See the `Mint.HTTP.recv/3`
documentation for more information.

## Examples

    {:ok, conn, [{:data, ^ref, data}]} = Mint.WebSocket.recv(conn, 0, 5_000)

    {:ok, websocket, [{:text, "hello world!"}]} =
      Mint.WebSocket.decode(websocket, data)

## stream(conn, message)

A wrapper around `Mint.HTTP.stream/2` for streaming HTTP and WebSocket
messages.

**This function does not decode WebSocket frames**. Instead, once a WebSocket
connection has been established, decode any `{:data, request_ref, data}`
frames with `decode/2`.

This function is a drop-in replacement for `Mint.HTTP.stream/2`, which
enables streaming WebSocket data after the bootstrapping HTTP/1 connection
has concluded. It decodes both WebSocket and regular HTTP messages.

## Examples

    message = receive(do: (message -> message))

    {:ok, conn, [{:data, ^websocket_ref, data}]} =
      Mint.WebSocket.stream(conn, message)

    {:ok, websocket, [{:text, "hello world!"}]} =
      Mint.WebSocket.decode(websocket, data)

## stream_request_body(conn, request_ref, data)

Streams chunks of data on the connection.

`stream_request_body/3` should be used to send encoded data on an
established WebSocket connection that has already been upgraded with
`upgrade/5`.

> #### Encoding {: .warning}
>
> This function doesn't perform any encoding. You should use `encode/2`
> to encode frames before sending them with `stream_request_body/3`.

This function is a wrapper around `Mint.HTTP.stream_request_body/3`. It
delegates to that function unless the `request_ref` belongs to an HTTP/1
WebSocket connection. When the request is an HTTP/1 WebSocket, this
function allows sending data on a request which Mint considers to be
closed, but is actually a valid WebSocket connection.

See the `Mint.HTTP.stream_request_body/3` documentation for more
information.

## Examples

    {:ok, websocket, data} = Mint.WebSocket.encode(websocket, {:text, "hello world!"})
    {:ok, conn} = Mint.WebSocket.stream_request_body(conn, websocket_ref, data)

## upgrade(scheme, conn, path, headers, opts \\ [])

Requests that a connection be upgraded to the WebSocket protocol

This function wraps `Mint.HTTP.request/5` to provide a single interface
for bootstrapping an upgrade for HTTP/1 and HTTP/2 connections.

For HTTP/1 connections, this function performs a GET request with
WebSocket-specific headers. For HTTP/2 connections, this function performs
an extended CONNECT request which opens a stream to be used for the WebSocket
connection.

The `scheme` argument should be either `:ws` or `:wss`, using `:ws` for
connections established by passing `:http` to `Mint.HTTP.connect/4` and
`:wss` corresponding to `:https`.

## Options

  * `:extensions` - a list of extensions to negotiate. See the extensions
    section below.

## Extensions

Extensions should be declared by passing the `:extensions` option in the
`opts` keyword list. Note that in the WebSocket protocol, extensions are
negotiated: the client proposes a list of extensions and the server may
accept any (or none) of them. See `Mint.WebSocket.Extension` for more
information about extension negotiation.

Extensions may be passed as a list of `Mint.WebSocket.Extension` structs
or with the following shorthand notations:

  * `module` - shorthand for `{module, []}`
  * `{module, params}` - shorthand for `{module, params, []}`
  * `{module, params, opts}` - a shorthand which is expanded to a
    `Mint.WebSocket.Extension` struct

## Examples

First, establish the Mint connection:

    {:ok, conn} = Mint.HTTP.connect(:http, "localhost", 9_000)

Then, send the upgrade request (with an extension in this example):

    {:ok, conn, ref} =
      Mint.WebSocket.upgrade(:ws, conn, "/", [], extensions: [Mint.WebSocket.PerMessageDeflate])

Here's an example of providing extension parameters:

    {:ok, conn, ref} =
      Mint.WebSocket.upgrade(
        :ws,
        conn,
        "/",
        [],
        extensions: [{Mint.WebSocket.PerMessageDeflate, [:client_max_window_bits]]}]
      )

## shorthand_frame/0

Shorthand notations for control frames.

  * `:ping` - shorthand for `{:ping, ""}`
  * `:pong` - shorthand for `{:pong, ""}`
  * `:close` - shorthand for `{:close, nil, nil}`

These may be passed to `encode/2`. Frames decoded with `decode/2` are always
in `t:frame/0` format.

## frame/0

A WebSocket frame.

  * `{:binary, binary}` - a frame containing binary data. Binary frames
    can be used to send arbitrary binary data such as a PDF.
  * `{:text, text}` - a frame containing string data. Text frames must be
    valid utf8. Elixir has wonderful support for utf8: `String.valid?/1`
    can detect valid and invalid utf8.
  * `{:ping, binary}` - a control frame which the server should respond to
    with a pong. The binary data must be echoed in the pong response.
  * `{:pong, binary}` - a control frame which forms a reply to a ping frame.
    Pings and pongs may be used to check the a connection is alive or to
    estimate latency.
  * `{:close, code, reason}` - a control frame used to request that a connection
    be closed or to acknowledgee a close frame send by the server.

These may be passed to `encode/2` or returned from `decode/2`.

## Close frames

In order to close a WebSocket connection gracefully, either the client or
server sends a close frame. Then the other endpoint responds with a
close with code `1_000` and then closes the TCP/TLS connection. This can be
accomplished in `Mint.WebSocket` like so:

    {:ok, websocket, data} = Mint.WebSocket.encode(websocket, :close)
    {:ok, conn} = Mint.WebSocket.stream_request_body(conn, ref, data)

    close_response = receive(do: (message -> message))
    {:ok, conn, [{:data, ^ref, data}]} = Mint.WebSocket.stream(conn, close_response)
    {:ok, websocket, [{:close, 1_000, ""}]} = Mint.WebSocket.decode(websocket, data)

    Mint.HTTP.close(conn)

[RFC6455 § 7.4.1](https://datatracker.ietf.org/doc/html/rfc6455#section-7.4.1)
documents codes which may be used in the `code` element.

## t/0

An immutable data structure representing WebSocket state.

You will usually want to keep these around:

  * The Mint connection
  * The request reference for the WebSocket upgrade request
  * This WebSocket data structure