# WebSock

Defines the `WebSock` behaviour which describes the functions that
an application such as Phoenix must implement in order to be WebSock compliant;
it is roughly the equivalent of the `Plug` interface, but for WebSocket
connections. It is commonly used in conjunction with the [websock_adapter][]
package which defines concrete adapters on top of [Bandit][] and [Cowboy][];
the two packages are separate to allow for servers which directly expose
`WebSock` support to depend on just the behaviour. Users will almost always
want to depend on [websock_adapter][] instead of this package.

## WebSocket Lifecycle

WebSocket connections go through a well defined lifecycle mediated by `WebSock`
and `WebSock.Adapters`:

* **This step is outside the scope of the WebSock API**. A client will
  attempt to Upgrade an HTTP connection to a WebSocket connection by passing
  a specific set of headers in an HTTP request. An application may choose to
  determine the feasibility of such an upgrade request however it pleases
* An application will then signal an upgrade to be performed by calling
  `WebSockAdapter.upgrade/4`, passing in the `Plug.Conn` to upgrade, along with
  the `WebSock` compliant handler module which will handle the connection once
  it is upgraded
* The underlying server will then attempt to upgrade the HTTP connection to a WebSocket connection
* Assuming the WebSocket connection is successfully negotiated, WebSock will
  call `c:WebSock.init/1` on the configured handler to allow the application to perform any necessary
  tasks now that the WebSocket connection is live
* WebSock will call the configured handler's `c:WebSock.handle_in/2` callback
  whenever data is received from the client
* WebSock will call the configured handler's `c:WebSock.handle_info/2` callback
  whenever other processes send messages to the handler process
* The `WebSock` implementation can send data to the client by returning
  a `{:push,...}` tuple from any of the above `handle_*` callbacks
* At any time, `c:WebSock.terminate/2` (if implemented) may be called to indicate a close, error or
  timeout condition

[Cowboy]: https://github.com/ninenines/cowboy
[Bandit]: https://github.com/mtrudel/bandit/
[websock_adapter]: https://hex.pm/packages/websock_adapter

## handle_control/2

Called by WebSock when a ping or pong frame has been received from the client. Note that
implementations SHOULD NOT send a pong frame in response; this MUST be automatically done by the
web server before this callback has been called.

Despite the name of this callback, it is not called for connection close frames even though they
are technically control frames. WebSock will handle any received connection
close frames and issue calls to `c:terminate/2` as / if appropriate

This callback is optional

The return value from this callback is handled as described in `c:handle_in/2`

## handle_in/2

Called by WebSock when a frame is received from the client. WebSock will only call this function
once a complete frame has been received (that is, once any continuation frames have been
received).

The return value from this callback are processed as follows:

* `{:push, messages(), state()}`: The indicated message(s) are sent to the client. The
  indicated state value is used to update the socket's current state
* `{:reply, term(), messages(), state()}`: The indicated message(s) are sent to the client. The
  indicated state value is used to update the socket's current state. The second element of the
  tuple has no semantic meaning in this context and is ignored. This return tuple is included
  here solely for backwards compatibility with the `Phoenix.Socket.Transport` behaviour; it is in
  all respects semantically identical to the `{:push, ...}` return value previously described
* `{:ok, state()}`: The indicated state value is used to update the socket's current state
* `{:stop, reason :: term(), state()}`: The connection will be closed based on the indicated
  reason. If `reason` is `:normal`, `c:terminate/2` will be called with a `reason` value of
  `:normal`. If the `reason` is `{:shutdown, :restart}`, the server is restarting and
  the WebSocket adapter should close with the `1012` Service Restart code.
  In all other cases, it will be called with `{:error, reason}`. Server
  implementations should also use this value when determining how to close the connection with
  the client
* `{:stop, reason :: term(), close_detail(), state()}`: Similar to the previous clause, but allows
  for the explicit setting of either a plain close code or a close code with a body to be sent to
  the client
* `{:stop, reason :: term(), close_detail(), messages(), state()}`: Similar to the previous clause, but allows
  for the sending of one or more frames before sending the connection close frame to the client

## handle_info/2

Called by WebSock when the socket process receives a `c:GenServer.handle_info/2` call which was
not otherwise processed by the server implementation.

The return value from this callback is handled as described in `c:handle_in/2`

## init/1

Called by WebSock after a WebSocket connection has been established (that is, after the server
has accepted the connection & the WebSocket handshake has been successfully completed).
Implementations can use this callback to perform tasks such as subscribing the client to any
relevant subscriptions within the application, or any other task which should be undertaken at
the time the connection is established

The return value from this callback is handled as described in `c:handle_in/2`

## terminate/2

Called by WebSock when a connection is closed. `reason` may be one of the following:

* `:normal`: The local end shut down the connection normally, by returning a `{:stop, :normal,
  state()}` tuple from one of the `WebSock.handle_*` callbacks
* `:remote`: The remote end shut down the connection
* `:shutdown`: The local server is being shut down
* `:timeout`: No data has been sent or received for more than the configured timeout duration
* `{:error, reason}`: An error occurred. This may be the result of error
  handling in the local server, or the result of a `WebSock.handle_*` callback returning a `{:stop,
  reason, state}` tuple where reason is any value other than `:normal`

This callback is optional

The return value of this callback is ignored

## impl/0

The type of an implementing module

## state/0

The type of state passed into / returned from `WebSock` callbacks

## data_opcode/0

Possible data frame types

## control_opcode/0

Possible control frame types

## opcode/0

All possible frame types

## message/0

The structure of an outbound message

## messages/0

Convenience type for one or many outbound messages

## handle_result/0

The result as returned from init, handle_in, handle_control & handle_info calls

## close_reason/0

Details about why a connection was closed

## close_detail/0

Describes the data to send in a connection close frame