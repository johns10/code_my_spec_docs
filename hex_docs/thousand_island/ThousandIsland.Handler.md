# ThousandIsland.Handler

`ThousandIsland.Handler` defines the behaviour required of the application layer of a Thousand Island server. When starting a
Thousand Island server, you must pass the name of a module implementing this behaviour as the `handler_module` parameter.
Thousand Island will then use the specified module to handle each connection that is made to the server.

The lifecycle of a Handler instance is as follows:

1. After a client connection to a Thousand Island server is made, Thousand Island will complete the initial setup of the
connection (performing a TLS handshake, for example), and then call `c:handle_connection/2`.

2. A handler implementation may choose to process a client connection within the `c:handle_connection/2` callback by
calling functions against the passed `ThousandIsland.Socket`. In many cases, this may be all that may be required of
an implementation & the value `{:close, state}` can be returned which will cause Thousand Island to close the connection
to the client.

3. In cases where the server wishes to keep the connection open and wait for subsequent requests from the client on the
same socket, it may elect to return `{:continue, state}`. This will cause Thousand Island to wait for client data
asynchronously; `c:handle_data/3` will be invoked when the client sends more data.

4. In the meantime, the process which is hosting connection is idle & able to receive messages sent from elsewhere in your
application as needed. The implementation included in the `use ThousandIsland.Handler` macro uses a `GenServer` structure,
so you may implement such behaviour via standard `GenServer` patterns. Note that in these cases that state is provided (and
must be returned) in a `{socket, state}` format, where the second tuple is the same state value that is passed to the various `handle_*` callbacks
defined on this behaviour. It also critical to maintain the socket's `read_timeout` value by
ensuring the relevant timeout value is returned as your callback's final argument. Both of these
concerns are illustrated in the following example:

    ```elixir
    defmodule ExampleHandler do
      use ThousandIsland.Handler

      # ...handle_data and other Handler callbacks

      @impl GenServer
      def handle_call(msg, from, {socket, state}) do
        # Do whatever you'd like with msg & from
        {:reply, :ok, {socket, state}, socket.read_timeout}
      end

      @impl GenServer
      def handle_cast(msg, {socket, state}) do
        # Do whatever you'd like with msg
        {:noreply, {socket, state}, socket.read_timeout}
      end

      @impl GenServer
      def handle_info(msg, {socket, state}) do
        # Do whatever you'd like with msg
        {:noreply, {socket, state}, socket.read_timeout}
      end
    end
    ```

It is fully supported to intermix synchronous `ThousandIsland.Socket.recv` calls with async return values from `c:handle_connection/2`
and `c:handle_data/3` callbacks.

# Example

A simple example of a Hello World server is as follows:

```elixir
defmodule HelloWorld do
  use ThousandIsland.Handler

  @impl ThousandIsland.Handler
  def handle_connection(socket, state) do
    ThousandIsland.Socket.send(socket, "Hello, World")
    {:close, state}
  end
end
```

Another example of a server that echoes back all data sent to it is as follows:

```elixir
defmodule Echo do
  use ThousandIsland.Handler

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    ThousandIsland.Socket.send(socket, data)
    {:continue, state}
  end
end
```

Note that in this example there is no `c:handle_connection/2` callback defined. The default implementation of this
callback will simply return `{:continue, state}`, which is appropriate for cases where the client is the first
party to communicate.

Another example of a server which can send and receive messages asynchronously is as follows:

```elixir
defmodule Messenger do
  use ThousandIsland.Handler

  @impl ThousandIsland.Handler
  def handle_data(msg, _socket, state) do
    IO.puts(msg)
    {:continue, state}
  end

  def handle_info({:send, msg}, {socket, state}) do
    ThousandIsland.Socket.send(socket, msg)
    {:noreply, {socket, state}, socket.read_timeout}
  end
end
```

Note that in this example we make use of the fact that the handler process is really just a GenServer to send it messages
which are able to make use of the underlying socket. This allows for bidirectional sending and receiving of messages in
an asynchronous manner.

You can pass options to the default handler underlying `GenServer` by passing a `genserver_options` key to `ThousandIsland.start_link/1`
containing `t:GenServer.options/0` to be passed to the last argument of `GenServer.start_link/3`.

Please note that you should not pass the `name` `t:GenServer.option/0`. If you need to register handler processes for
later lookup and use, you should perform process registration in `handle_connection/2`, ensuring the handler process is
registered only after the underlying connection is established and you have access to the connection socket and metadata
via `ThousandIsland.Socket.peername/1`.

For example, using a custom process registry via `Registry`:

```elixir

defmodule Messenger do
  use ThousandIsland.Handler

  @impl ThousandIsland.Handler
  def handle_connection(socket, state) do
    {:ok, {ip, port}} = ThousandIsland.Socket.peername(socket)
    {:ok, _pid} = Registry.register(MessengerRegistry, {state[:my_key], address}, nil)
    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    ThousandIsland.Socket.send(socket, data)
    {:continue, state}
  end
end
```

This example assumes you have started a `Registry` and registered it under the name `MessengerRegistry`.

# When Handler Isn't Enough

The `use ThousandIsland.Handler` implementation should be flexible enough to power just about any handler, however if
this should not be the case for you, there is an escape hatch available. If you require more flexibility than the
`ThousandIsland.Handler` behaviour provides, you are free to specify any module which implements `start_link/1` as the
`handler_module` parameter. The process of getting from this new process to a ready-to-use socket is somewhat
delicate, however. The steps required are as follows:

1. Thousand Island calls `start_link/1` on the configured `handler_module`, passing in a tuple
consisting of the configured handler and genserver opts. This function is expected to return a
conventional `GenServer.on_start()` style tuple. Note that this newly created process is not
passed the connection socket immediately.
2. The raw `t:ThousandIsland.Transport.socket()` socket will be passed to the new process via a
message of the form `{:thousand_island_ready, raw_socket, handler_config, acceptor_span,
start_time}`.
3. Your implementation must turn this into a `to:ThousandIsland.Socket.t()` socket by using the
`ThousandIsland.Socket.new/3` call.
4. Your implementation must then call `ThousandIsland.Socket.handshake/1` with the socket as the
sole argument in order to finalize the setup of the socket.
5. The socket is now ready to use.

In addition to this process, there are several other considerations to be aware of:

* The underlying socket is closed automatically when the handler process ends.

* Handler processes should have a restart strategy of `:temporary` to ensure that Thousand Island does not attempt to
restart crashed handlers.

* Handler processes should trap exit if possible so that existing connections can be given a chance to cleanly shut
down when shutting down a Thousand Island server instance.

* Some of the `:connection` family of telemetry span events are emitted by the
`ThousandIsland.Handler` implementation. If you use your own implementation in its place it is
likely that such spans will not behave as expected.

## __using__/1

This callback is called when a handler process has gone more than `timeout` ms without receiving
either remote data or a local message. The value used for `timeout` defaults to the
`read_timeout` value specified at server startup, and may be overridden on a one-shot or
persistent basis based on values returned from `c:handle_connection/2` or `c:handle_data/3`
calls. Note that it is NOT called on explicit `ThousandIsland.Socket.recv/3` calls as they have
their own timeout semantics. The underlying socket has NOT been closed by the time this callback
is called. The return value is ignored.