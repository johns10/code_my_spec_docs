# Phoenix.Tracker

Provides distributed presence tracking to processes.

Tracker shards use a heartbeat protocol and CRDT to replicate presence
information across a cluster in an eventually consistent, conflict-free
manner. Under this design, there is no single source of truth or global
process. Each node runs a pool of trackers and node-local changes are
replicated across the cluster and handled locally as a diff of changes.

## Implementing a Tracker

To start a tracker, first add the tracker to your supervision tree:

    children = [
      # ...
      {MyTracker, [name: MyTracker, pubsub_server: MyApp.PubSub]}
    ]

Next, implement `MyTracker` with support for the `Phoenix.Tracker`
behaviour callbacks. An example of a minimal tracker could include:

    defmodule MyTracker do
      use Phoenix.Tracker

      def start_link(opts) do
        opts = Keyword.merge([name: __MODULE__], opts)
        Phoenix.Tracker.start_link(__MODULE__, opts, opts)
      end

      def init(opts) do
        server = Keyword.fetch!(opts, :pubsub_server)
        {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
      end

      def handle_diff(diff, state) do
        for {topic, {joins, leaves}} <- diff do
          for {key, meta} <- joins do
            IO.puts "presence join: key \"#{key}\" with meta #{inspect meta}"
            msg = {:join, key, meta}
            Phoenix.PubSub.direct_broadcast!(state.node_name, state.pubsub_server, topic, msg)
          end
          for {key, meta} <- leaves do
            IO.puts "presence leave: key \"#{key}\" with meta #{inspect meta}"
            msg = {:leave, key, meta}
            Phoenix.PubSub.direct_broadcast!(state.node_name, state.pubsub_server, topic, msg)
          end
        end
        {:ok, state}
      end
    end

Trackers must implement `start_link/1`, `c:init/1`, and `c:handle_diff/2`.
The `c:init/1` callback allows the tracker to manage its own state when
running within the `Phoenix.Tracker` server. The `handle_diff` callback
is invoked with a diff of presence join and leave events, grouped by
topic. As replicas heartbeat and replicate data, the local tracker state is
merged with the remote data, and the diff is sent to the callback. The
handler can use this information to notify subscribers of events, as
done above.

An optional `handle_info/2` callback may also be invoked to handle
application specific messages within your tracker.

## Stability and Performance Considerations

Operations within `handle_diff/2` happen *in the tracker server's context*.
Therefore, blocking operations should be avoided when possible, and offloaded
to a supervised task when required. Also, a crash in the `handle_diff/2` will
crash the tracker server, so operations that may crash the server should be
offloaded with a `Task.Supervisor` spawned process.

## Application Shutdown

When a tracker shuts down, the other nodes do not assume it is gone
for good. After all, in a distributed system, it is impossible to know if something
is just temporarily unavailable or if it has crashed.

For this reason, when you call `System.stop()` or the Erlang VM receives a
`SIGTERM`, any presences that the local tracker instance has will continue to
be seen as present by other trackers in the cluster until the `:down_period`
for the instance has passed.

If you want a normal shutdown to immediately cause other nodes to see that
tracker's presences as leaving, pass `permdown_on_shutdown: true`. On the
other hand, if you are using `Phoenix.Presence` for clients which will
immediately attempt to connect to a new node, it may be preferable to use
`permdown_on_shutdown: false`, allowing the disconnected clients time to
reconnect before removing their old presences, to avoid overwhelming clients
with notifications that many users left and immediately rejoined.

If the application crashes or is halted non-gracefully (for instance, with a
`SIGKILL` or a `Ctrl+C` in `iex`), other nodes will still have to wait the
`:down_period` to notice that the tracker's presences are gone.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## get_by_key(tracker_name, topic, key)

Gets presences tracked under a given topic and key pair.

  * `tracker_name` - The registered name of the tracker server
  * `topic` - The `Phoenix.PubSub` topic
  * `key` - The key of the presence

Returns a list of presence metadata.

## Examples

    iex> Phoenix.Tracker.get_by_key(MyTracker, "lobby", "user1")
    [{#PID<0.88.0>, %{name: "User 1"}}, {#PID<0.89.0>, %{name: "User 1"}}]

## graceful_permdown(tracker_name)

Gracefully shuts down by broadcasting permdown to all replicas.

## Examples

    iex> Phoenix.Tracker.graceful_permdown(MyTracker)
    :ok

## list(tracker_name, topic)

Lists all presences tracked under a given topic.

  * `tracker_name` - The registered name of the tracker server
  * `topic` - The `Phoenix.PubSub` topic

Returns a list of presences in key/metadata tuple pairs.

## Examples

    iex> Phoenix.Tracker.list(MyTracker, "lobby")
    [{123, %{name: "user 123"}}, {456, %{name: "user 456"}}]

## start_link(tracker, tracker_arg, pool_opts)

Starts a tracker pool.

  * `tracker` - The tracker module implementing the `Phoenix.Tracker` behaviour
  * `tracker_arg` - The argument to pass to the tracker handler `c:init/1`
  * `pool_opts` - The list of options used to construct the shard pool

## Required `pool_opts`:

  * `:name` - The name of the server, such as: `MyApp.Tracker`
    This will also form the common prefix for all shard names
  * `:pubsub_server` - The name of the PubSub server, such as: `MyApp.PubSub`

## Optional `pool_opts`:

  * `:broadcast_period` - The interval in milliseconds to send delta broadcasts
    across the cluster. Default `1500`
  * `:max_silent_periods` - The max integer of broadcast periods for which no
    delta broadcasts have been sent. Default `10` (15s heartbeat)
  * `:down_period` - The interval in milliseconds to flag a replica
    as temporarily down. Default `broadcast_period * max_silent_periods * 2`
    (30s down detection). Note: This must be at least 2x the `broadcast_period`.
  * `permdown_on_shutdown` - boolean; whether to immediately call
    `graceful_permdown/1` on the tracker during a graceful shutdown. See
    'Application Shutdown' section. You can only safely set this if `Phoenix.Tracker`
    is mounted at the root of your supervision tree and the strategy is `:one_for_one`.
    Default `false`.
  * `:permdown_period` - The interval in milliseconds to flag a replica
    as permanently down, and discard its state.
    Note: This must be at least greater than the `down_period`.
    Default `1_200_000` (20 minutes)
  * `:clock_sample_periods` - The numbers of heartbeat windows to sample
    remote clocks before collapsing and requesting transfer. Default `2`
  * `:max_delta_sizes` - The list of delta generation sizes to keep before
    falling back to sending entire state. Defaults `[100, 1000, 10_000]`.
  * `:log_level` - The log level to log events, defaults `:debug` and can be
    disabled with `false`
  * `:pool_size` - The number of tracker shards to launch. Default `1`

## track(tracker_name, pid, topic, key, meta)

Tracks a presence.

  * `tracker_name` - The registered name of the tracker server
  * `pid` - The Pid to track
  * `topic` - The `Phoenix.PubSub` topic for this presence
  * `key` - The key identifying this presence
  * `meta` - The map of metadata to attach to this presence

A process may be tracked multiple times, provided the topic and key pair
are unique for any prior calls for the given process.

## Examples

    iex> Phoenix.Tracker.track(MyTracker, self(), "lobby", u.id, %{stat: "away"})
    {:ok, "1WpAofWYIAA="}

    iex> Phoenix.Tracker.track(MyTracker, self(), "lobby", u.id, %{stat: "away"})
    {:error, {:already_tracked, #PID<0.56.0>, "lobby", "123"}}

## untrack(tracker_name, pid, topic, key)

Untracks a presence.

  * `tracker_name` - The registered name of the tracker server
  * `pid` - The Pid to untrack
  * `topic` - The `Phoenix.PubSub` topic to untrack for this presence
  * `key` - The key identifying this presence

All presences for a given Pid can be untracked by calling the
`Phoenix.Tracker.untrack/2` signature of this function.

## Examples

    iex> Phoenix.Tracker.untrack(MyTracker, self(), "lobby", u.id)
    :ok
    iex> Phoenix.Tracker.untrack(MyTracker, self())
    :ok

## update(tracker_name, pid, topic, key, meta)

Updates a presence's metadata.

  * `tracker_name` - The registered name of the tracker server
  * `pid` - The Pid being tracked
  * `topic` - The `Phoenix.PubSub` topic to update for this presence
  * `key` - The key identifying this presence
  * `meta` - Either a new map of metadata to attach to this presence,
    or a function. The function will receive the current metadata as
    input and the return value will be used as the new metadata

## Examples

    iex> Phoenix.Tracker.update(MyTracker, self(), "lobby", u.id, %{stat: "zzz"})
    {:ok, "1WpAofWYIAA="}

    iex> Phoenix.Tracker.update(MyTracker, self(), "lobby", u.id, fn meta -> Map.put(meta, :away, true) end)
    {:ok, "1WpAofWYIAA="}