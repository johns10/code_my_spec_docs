# Mint.HTTP2

Process-less HTTP/2 client connection.

This module provides a data structure that represents an HTTP/2 connection to
a given server. The connection is represented as an opaque struct `%Mint.HTTP2{}`.
The connection is a data structure and is not backed by a process, and all the
connection handling happens in the process that creates the struct.

This module and data structure work exactly like the ones described in the `Mint.HTTP`
module, with the exception that `Mint.HTTP2` specifically deals with HTTP/2 while
`Mint.HTTP` deals seamlessly with HTTP/1.1 and HTTP/2. For more information on
how to use the data structure and client architecture, see `Mint.HTTP`.

## HTTP/2 Streams and Requests

HTTP/2 introduces the concept of **streams**. A stream is an isolated conversation
between the client and the server. Each stream is unique and identified by a unique
**stream ID**, which means that there's no order when data comes on different streams
since they can be identified uniquely. A stream closely corresponds to a request, so
in this documentation and client we will mostly refer to streams as "requests".
We mentioned data on streams can come in arbitrary order, and streams are requests,
so the practical effect of this is that performing request A and then request B
does not mean that the response to request A will come before the response to request B.
This is why we identify each request with a unique reference returned by `request/5`.
See `request/5` for more information.

## Closed Connection

In HTTP/2, the connection can either be open, closed, or only closed for writing.
When a connection is closed for writing, the client cannot send requests or stream
body chunks, but it can still read data that the server might be sending. When the
connection gets closed on the writing side, a `:server_closed_connection` error is
returned. `{:error, request_ref, error}` is returned for requests that haven't been
processed by the server, with the reason of `error` being `:unprocessed`.
These requests are safe to retry.

## HTTP/2 Settings

HTTP/2 supports settings negotiation between servers and clients. The server advertises
its settings to the client and the client advertises its settings to the server. A peer
(server or client) has to acknowledge the settings advertised by the other peer before
those settings come into action (that's why it's called a negotiation).

A first settings negotiation happens right when the connection starts.
Servers and clients can renegotiate settings at any time during the life of the
connection.

Mint users don't need to care about settings acknowledgements directly since they're
handled transparently by `stream/2`.

To retrieve the server settings, you can use `get_server_setting/2`. Doing so is often
useful to be able to tune your requests based on the server settings.

To communicate client settings to the server, use `put_settings/2` or pass them when
starting up a connection with `connect/4`. Note that the server needs to acknowledge
the settings sent through `put_setting/2` before those settings come into effect. The
server ack is processed transparently by `stream/2`, but this means that if you change
a setting through `put_settings/2` and try to retrieve the value of that setting right
after with `get_client_setting/2`, you'll likely get the old value of that setting. Once
the server acknowledges the new settings, the updated value will be returned by
`get_client_setting/2`.

## Server Push

HTTP/2 supports [server push](https://en.wikipedia.org/wiki/HTTP/2_Server_Push), which
is a way for a server to send a response to a client without the client needing to make
the corresponding request. The server sends a `:push_promise` response to a normal request:
this creates a new request reference. Then, the server sends normal responses for the newly
created request reference.

Let's see an example. We will ask the server for `"/index.html"` and the server will
send us a push promise for `"/style.css"`.

    {:ok, conn} = Mint.HTTP2.connect(:https, "example.com", 443)
    {:ok, conn, request_ref} = Mint.HTTP2.request(conn, "GET", "/index.html", _headers = [], _body = "")

    next_message =
      receive do
        msg -> msg
      end

    {:ok, conn, responses} = Mint.HTTP2.stream(conn, next_message)

    [
      {:push_promise, ^request_ref, promised_request_ref, promised_headers},
      {:status, ^request_ref, 200},
      {:headers, ^request_ref, []},
      {:data, ^request_ref, "<html>..."},
      {:done, ^request_ref}
    ] = responses

    promised_headers
    #=> [{":method", "GET"}, {":path", "/style.css"}]

As you can see in the example above, when the server sends a push promise then a
`:push_promise` response is returned as a response to a request. The `:push_promise`
response contains a `promised_request_ref` and some `promised_headers`. The
`promised_request_ref` is the new request ref that pushed responses will be tagged with.
`promised_headers` are headers that tell the client *what request* the promised response
will respond to. The idea is that the server tells the client a request the client will
want to make and then preemptively sends a response for that request. Promised headers
will always include `:method`, `:path`, and `:authority`.

    next_message =
      receive do
        msg -> msg
      end

    {:ok, conn, responses} = Mint.HTTP2.stream(conn, next_message)

    [
      {:status, ^promised_request_ref, 200},
      {:headers, ^promised_request_ref, []},
      {:data, ^promised_request_ref, "body { ... }"},
      {:done, ^promised_request_ref}
    ]

The response to a promised request is like a response to any normal request.

> #### Disabling Server Pushes {: .tip}
>
> HTTP/2 exposes a boolean setting for enabling or disabling server pushes with `:enable_push`.
> You can pass this option when connecting or in `put_settings/2`. By default server push
> is enabled.

## cancel_request(conn, request_ref)

Cancels an in-flight request.

This function is HTTP/2 specific. It cancels an in-flight request. The server could have
already sent responses for the request you want to cancel: those responses will be parsed
by the connection but not returned to the user. No more responses
to a request will be returned after you call `cancel_request/2` on that request.

If there's no error in canceling the request, `{:ok, conn}` is returned where `conn` is
the updated connection. If there's an error, `{:error, conn, reason}` is returned where
`conn` is the updated connection and `reason` is the error reason.

## Examples

    {:ok, conn, ref} = Mint.HTTP2.request(conn, "GET", "/", _headers = [])
    {:ok, conn} = Mint.HTTP2.cancel_request(conn, ref)

## close(conn)

See `Mint.HTTP.close/1`.

## connect(scheme, address, port, opts \\ [])

Same as `Mint.HTTP.connect/4`, but forces a HTTP/2 connection.

## controlling_process(conn, new_pid)

See `Mint.HTTP.controlling_process/2`.

## delete_private(conn, key)

See `Mint.HTTP.delete_private/2`.

## get_client_setting(conn, name)

Gets the value of the given HTTP/2 client setting.

This function returns the value of the given HTTP/2 setting that the client
advertised to the server. Client settings can be advertised through `put_settings/2`
or when starting up a connection.

Client settings have to be acknowledged by the server before coming into effect.

This function is HTTP/2 specific. For more information on HTTP/2 settings, see
[the related section in the RFC](https://httpwg.org/specs/rfc7540.html#SettingValues).

See the "HTTP/2 settings" section in the module documentation for more information.

## Supported settings

The possible settings that can be retrieved are described in `t:setting/0`.
Any other atom passed as `name` will raise an error.

## Examples

    Mint.HTTP2.get_client_setting(conn, :max_concurrent_streams)
    #=> 500

## get_private(conn, key, default \\ nil)

See `Mint.HTTP.get_private/3`.

## get_proxy_headers(conn)

See `Mint.HTTP.get_proxy_headers/1`.

## get_server_setting(conn, name)

Gets the value of the given HTTP/2 server settings.

This function returns the value of the given HTTP/2 setting that the server
advertised to the client. This function is HTTP/2 specific.
For more information on HTTP/2 settings, see [the related section in
the RFC](https://httpwg.org/specs/rfc7540.html#SettingValues).

See the "HTTP/2 settings" section in the module documentation for more information.

## Supported settings

The possible settings that can be retrieved are described in `t:setting/0`.
Any other atom passed as `name` will raise an error.

## Examples

    Mint.HTTP2.get_server_setting(conn, :max_concurrent_streams)
    #=> 500

## get_socket(conn)

See `Mint.HTTP.get_socket/1`.

## get_window_size(conn, connection_or_request)

Returns the window size of the connection or of a single request.

This function is HTTP/2 specific. It returns the window size of
either the connection if `connection_or_request` is `:connection` or of a single
request if `connection_or_request` is `{:request, request_ref}`.

Use this function to check the window size of the connection before sending a
full request. Also use this function to check the window size of both the
connection and of a request if you want to stream body chunks on that request.

For more information on flow control and window sizes in HTTP/2, see the section
below.

## HTTP/2 Flow Control

In HTTP/2, flow control is implemented through a
window size. When the client sends data to the server, the window size is decreased
and the server needs to "refill" it on the client side. You don't need to take care of
the refilling of the client window as it happens behind the scenes in `stream/2`.

A window size is kept for the entire connection and all requests affect this window
size. A window size is also kept per request.

The only thing that affects the window size is the body of a request, regardless of
if it's a full request sent with `request/5` or body chunks sent through
`stream_request_body/3`. That means that if we make a request with a body that is
five bytes long, like `"hello"`, the window size of the connection and the window size
of that particular request will decrease by five bytes.

If we use all the window size before the server refills it, functions like
`request/5` will return an error.

## Examples

On the connection:

    HTTP2.get_window_size(conn, :connection)
    #=> 65_536

On a single streamed request:

    {:ok, conn, request_ref} = HTTP2.request(conn, "GET", "/", [], :stream)
    HTTP2.get_window_size(conn, {:request, request_ref})
    #=> 65_536

    {:ok, conn} = HTTP2.stream_request_body(conn, request_ref, "hello")
    HTTP2.get_window_size(conn, {:request, request_ref})
    #=> 65_531

## open?(conn, type \\ :write)

See `Mint.HTTP.open?/1`.

## open_request_count(conn)

See `Mint.HTTP.open_request_count/1`.

In HTTP/2, the number of open requests is the number of requests **opened by the client**
that have not yet received a `:done` response. It's important to note that only
requests opened by the client (with `request/5`) count towards the number of open
requests, as requests opened from the server with server pushes (see the "Server push"
section in the module documentation) are not considered open requests. We do this because
clients might need to know how many open requests there are because the server limits
the number of concurrent requests the client can open. To know how many requests the client
can open, see `get_server_setting/2` with the `:max_concurrent_streams` setting.

## ping(conn, payload \\ :binary.copy(<<0>>, 8))

Pings the server.

This function is specific to HTTP/2 connections. It sends a **ping** request to
the server `conn` is connected to. A `{:ok, conn, request_ref}` tuple is returned,
where `conn` is the updated connection and `request_ref` is a unique reference that
identifies this ping request. The response to a ping request is returned by `stream/2`
as a `{:pong, request_ref}` tuple. If there's an error, this function returns
`{:error, conn, reason}` where `conn` is the updated connection and `reason` is the
error reason.

`payload` must be an 8-byte binary with arbitrary content. When the server responds to
a ping request, it will use that same payload. By default, the payload is an 8-byte
binary with all bits set to `0`.

Pinging can be used to measure the latency with the server and to ensure the connection
is alive and well.

## Examples

    {:ok, conn, ref} = Mint.HTTP2.ping(conn)

## put_log(conn, log?)

See `Mint.HTTP.put_log/2`.

## put_private(conn, key, value)

See `Mint.HTTP.put_private/3`.

## put_settings(conn, settings)

Communicates the given **client settings** to the server.

This function is HTTP/2-specific.

This function takes a connection and a keyword list of HTTP/2 settings and sends
the values of those settings to the server. The settings won't be effective until
the server acknowledges them, which will be handled transparently by `stream/2`.

This function returns `{:ok, conn}` when sending the settings to the server is
successful, with `conn` being the updated connection. If there's an error, this
function returns `{:error, conn, reason}` with `conn` being the updated connection
and `reason` being the reason of the error.

## Supported Settings

See `t:setting/0` for the supported settings. You can see the meaning
of these settings [in the corresponding section in the HTTP/2
RFC](https://httpwg.org/specs/rfc7540.html#SettingValues).

See the "HTTP/2 settings" section in the module documentation for more information.

## Examples

    {:ok, conn} = Mint.HTTP2.put_settings(conn, max_frame_size: 100)

## recv(conn, byte_count, timeout)

See `Mint.HTTP.recv/3`.

## request(conn, method, path, headers, body)

See `Mint.HTTP.request/5`.

In HTTP/2, opening a request means opening a new HTTP/2 stream (see the
module documentation). This means that a request could fail because the
maximum number of concurrent streams allowed by the server has been reached.
In that case, the error reason `:too_many_concurrent_requests` is returned.
If you want to avoid incurring in this error, you can retrieve the value of
the maximum number of concurrent streams supported by the server through
`get_server_setting/2` (passing in the `:max_concurrent_streams` setting name).

## Header list size

In HTTP/2, the server can optionally specify a maximum header list size that
the client needs to respect when sending headers. The header list size is calculated
by summing the length (in bytes) of each header name plus value, plus 32 bytes for
each header. Note that pseudo-headers (like `:path` or `:method`) count towards
this size. If the size is exceeded, an error is returned. To check what the size
is, use `get_server_setting/2`.

## Request body size

If the request body size will exceed the window size of the HTTP/2 stream created by the
request or the window size of the connection Mint will return a `:exceeds_window_size`
error.

To ensure you do not exceed the window size it is recommended to stream the request
body by initially passing `:stream` as the body and sending the body in chunks using
`stream_request_body/3` and using `get_window_size/2` to get the window size of the
request and connection.

## set_mode(conn, mode)

See `Mint.HTTP.set_mode/2`.

## stream(conn, message)

See `Mint.HTTP.stream/2`.

## stream_request_body(conn, request_ref, chunk)

See `Mint.HTTP.stream_request_body/3`.

## setting/0

HTTP/2 setting with its value.

This type represents both server settings as well as client settings. To retrieve
server settings use `get_server_setting/2` and to retrieve client settings use
`get_client_setting/2`. To send client settings to the server, see `put_settings/2`.

The supported settings are the following:

  * `:header_table_size` - corresponds to `SETTINGS_HEADER_TABLE_SIZE`.

  * `:enable_push` - corresponds to `SETTINGS_ENABLE_PUSH`. Sets whether
    push promises are supported. If you don't want to support push promises,
    use `put_settings/2` to tell the server that your client doesn't want push promises.

  * `:max_concurrent_streams` - corresponds to `SETTINGS_MAX_CONCURRENT_STREAMS`.
    Tells what is the maximum number of streams that the peer sending this (client or server)
    supports. As mentioned in the module documentation, HTTP/2 streams are equivalent to
    requests, so knowing the maximum number of streams that the server supports can be useful
    to know how many concurrent requests can be open at any time. Use `get_server_setting/2`
    to find out how many concurrent streams the server supports.

  * `:initial_window_size` -  corresponds to `SETTINGS_INITIAL_WINDOW_SIZE`.
    Tells what is the value of the initial HTTP/2 window size for the peer
    that sends this setting.

  * `:max_frame_size` - corresponds to `SETTINGS_MAX_FRAME_SIZE`. Tells what is the
    maximum size of an HTTP/2 frame for the peer that sends this setting.

  * `:max_header_list_size` - corresponds to `SETTINGS_MAX_HEADER_LIST_SIZE`.

  * `:enable_connect_protocol` - corresponds to `SETTINGS_ENABLE_CONNECT_PROTOCOL`.
    Sets whether the client may invoke the extended connect protocol which is used to
    bootstrap WebSocket connections.

## settings/0

HTTP/2 settings.

See `t:setting/0`.

## error_reason/0

An HTTP/2-specific error reason.

The values can be:

  * `:closed` - when you try to make a request or stream a body chunk but the connection
    is closed.

  * `:closed_for_writing` - when you try to make a request or stream a body chunk but
    the connection is closed for writing. This means you cannot issue any more requests.
    See the "Closed connection" section in the module documentation for more information.

  * `:too_many_concurrent_requests` - when the maximum number of concurrent requests
    allowed by the server is reached. To find out what this limit is, use `get_setting/2`
    with the `:max_concurrent_streams` setting name.

  * `{:max_header_list_size_exceeded, size, max_size}` - when the maximum size of
    the header list is reached. `size` is the actual value of the header list size,
    `max_size` is the maximum value allowed. See `get_setting/2` to retrieve the
    value of the max size.

  * `{:exceeds_window_size, what, window_size}` - when the data you're trying to send
    exceeds the window size of the connection (if `what` is `:connection`) or of a request
    (if `what` is `:request`). `window_size` is the allowed window size. See
    `get_window_size/2`.

  * `{:stream_not_found, stream_id}` - when the given request is not found.

  * `:unknown_request_to_stream` - when you're trying to stream data on an unknown
    request.

  * `:request_is_not_streaming` - when you try to send data (with `stream_request_body/3`)
    on a request that is not open for streaming.

  * `:unprocessed` - when a request was closed because it was not processed by the server.
    When this error is returned, it means that the server hasn't processed the request at all,
    so it's safe to retry the given request on a different or new connection.

  * `{:server_closed_request, error_code}` - when the server closes the request.
    `error_code` is the reason why the request was closed.

  * `{:server_closed_connection, reason, debug_data}` - when the server closes the connection
    gracefully or because of an error. In HTTP/2, this corresponds to a `GOAWAY` frame.
    `error` is the reason why the connection was closed. `debug_data` is additional debug data.

  * `{:frame_size_error, frame}` - when there's an error with the size of a frame.
    `frame` is the frame type, such as `:settings` or `:window_update`.

  * `{:protocol_error, debug_data}` - when there's a protocol error.
    `debug_data` is a string that explains the nature of the error.

  * `{:compression_error, debug_data}` - when there's a header compression error.
    `debug_data` is a string that explains the nature of the error.

  * `{:flow_control_error, debug_data}` - when there's a flow control error.
    `debug_data` is a string that explains the nature of the error.

## t/0

A Mint HTTP/2 connection struct.

The struct's fields are private.