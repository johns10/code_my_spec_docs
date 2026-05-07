# Postgrex.SimpleConnection

A generic connection suitable for simple queries and pubsub functionality.

On its own, a SimpleConnection server only maintains a connection. To execute
queries, process results, or relay notices you must implement a callback module
with the SimpleConnection behaviour.

## Example

The SimpleConnection behaviour abstracts common client/server interactions,
along with optional mechanisms for running queries or relaying notifications.

Let's start with a minimal callback module that executes a query and relays
the result back to the caller.

    defmodule MyConnection do
      @behaviour Postgrex.SimpleConnection

      @impl true
      def init(_args) do
        {:ok, %{from: nil}}
      end

      @impl true
      def handle_call({:query, query}, from, state) do
        {:query, query, %{state | from: from}}
      end

      @impl true
      def handle_result(results, state) when is_list(results) do
        SimpleConnection.reply(state.from, results)

        {:noreply, state}
      end

      @impl true
      def handle_result(%Postgrex.Error{} = error, state) do
        SimpleConnection.reply(state.from, error)

        {:noreply, state}
      end
    end

    # Start the connection
    {:ok, pid} = SimpleConnection.start_link(MyConnection, [], database: "demo")

    # Execute a literal query
    SimpleConnection.call(pid, {:query, "SELECT 1"})
    # => %Postgrex.Result{rows: [["1"]]}

We start a connection by passing the callback module, callback options, and
server options to `SimpleConnection.start_link/3`. The `init/1` function
receives any callback options and returns the callback state.

Queries are sent through `SimpleConnection.call/2`, executed on the server,
and the result is handed off to `handle_result/2`. At that point the callback
can process the result before replying back to the caller with
`SimpleConnection.reply/2`.

## Building a PubSub Connection

With the `notify/3` callback you can also build a pubsub server on top of
`LISTEN/NOTIFY`. Here's a naive pubsub implementation:

    defmodule MyPubSub do
      @behaviour Postgrex.SimpleConnection

      defstruct [:from, listeners: %{}]

      @impl true
      def init(args) do
        {:ok, struct!(__MODULE__, args)}
      end

      @impl true
      def notify(channel, payload, state) do
        for pid <- state.listeners[channel] do
          send(pid, {:notice, channel, payload})
        end
      end

      @impl true
      def handle_call({:listen, channel}, {pid, _} = from, state) do
        listeners = Map.update(state.listeners, channel, [pid], &[pid | &1])

        {:query, ~s(LISTEN "#{channel}"), %{state | from: from, listeners: listeners}}
      end

      def handle_call({:query, query}, from, state) do
        {:query, query, %{state | from: from}}
      end

      @impl true
      def handle_result(_results, state) do
        SimpleConnection.reply(state.from, :ok)

        {:noreply, %{state | from: nil}}
      end
    end

    # Start the connection
    {:ok, pid} = SimpleConnection.start_link(MyPubSub, [], database: "demo")

    # Start listening to the "demo" channel
    SimpleConnection.call(pid, {:listen, "demo"})
    # => %Postgrex.Result{command: :listen}

    # Notify all listeners
    SimpleConnection.call(pid, {:query, ~s(NOTIFY "demo", 'hello')})
    # => %Postgrex.Result{command: :notify}

    # Check the inbox to see the notice message
    flush()
    # => {:notice, "demo", "hello"}

See `Postgrex.Notifications` for a more complex implementation that can
unlisten, handle process exits, and persist across reconnection.

## Name registration

A `Postgrex.SimpleConnection` is bound to the same name registration rules as a
`GenServer`. Read more about them in the `GenServer` docs.

## call(server, message, timeout \\ 5000)

Calls the given server.

Wrapper for `:gen_statem.call/3`.

## reply(from, reply)

Replies to the given client.

Wrapper for `:gen_statem.reply/2`.

## start_link(module, args, opts)

Start the connection process and connect to Postgres.

The options that this function accepts are the same as those accepted by
`Postgrex.start_link/1`, as well as the extra options `:sync_connect`,
`:auto_reconnect`, `:reconnect_backoff`, and `:configure`.

## Options

  * `:auto_reconnect` - automatically attempt to reconnect to the database
    in event of a disconnection. Defaults to `false`, which means the process
    terminates. See the note in `Postgrex.Notifications` about [async connect
    and auto-reconnects][async-caveat].

  * `:configure` - A function to run before every connect attempt to dynamically
    configure the options as a `{module, function, args}`, where the current
    options will prepended to `args`. Defaults to `nil`.

  * `:idle_interval` - while also accepted on `Postgrex.start_link/1`, it has
    a default of `5000ms` in `Postgrex.SimpleConnection` (instead of 1000ms).

  * `:reconnect_backoff` - time (in ms) between reconnection attempts when
    `auto_reconnect` is enabled. Defaults to `500`.

  * `:sync_connect` - controls if the connection should be established on boot
    or asynchronously right after boot. Defaults to `true`.

[async-caveat]: Postgrex.Notifications.html#module-async-connect-auto-reconnects-and-missed-notifications

## handle_call/3

Callback for `SimpleConnection.call/3`.

Replies must be sent with `SimpleConnection.reply/2`.

## handle_connect/1

Invoked after connecting or reconnecting.

This may be called multiple times if `:auto_reconnect` is true.

## handle_disconnect/1

Invoked after disconnection.

This is invoked regardless of the `:auto_reconnect` option.

## handle_info/2

Callback for `Kernel.send/2`.

## handle_result/2

Callback for processing or relaying queries executed via `{:query, query, state}`.

Either a list of successful query results or an error will be passed to this callback.
A list is passed because the simple query protocol allows multiple commands to be
issued in a single query.

## init/1

Callback for process initialization.

This is called once and before the Postgrex connection is established.

## notify/3

Callback for processing or relaying pubsub notifications.