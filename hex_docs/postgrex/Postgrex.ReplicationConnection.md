# Postgrex.ReplicationConnection

A process that receives and sends PostgreSQL replication messages.

> Note: this module is experimental and may be subject to changes
> in the future.

## Logical replication

Let's see how to use this module for connecting to PostgreSQL
for logical replication. First of all, you need to configure the
wal level in PostgreSQL to logical. Run this inside your PostgreSQL
shell/configuration:

    ALTER SYSTEM SET wal_level='logical';
    ALTER SYSTEM SET max_wal_senders='10';
    ALTER SYSTEM SET max_replication_slots='10';

Then **you must restart your server**. Alternatively, you can set
those values when starting "postgres". This is useful, for example,
when running it from Docker:

    services:
      postgres:
        image: postgres:14
        env:
          ...
        command: ["postgres", "-c", "wal_level=logical"]

For CI, GitHub Actions do not support setting command, so you can
update and restart Postgres instead in a step:

    - name: "Set PG settings"
      run: |
        docker exec ${{ job.services.postgres.id }} sh -c 'echo "wal_level=logical" >> /var/lib/postgresql/data/postgresql.conf'
        docker restart ${{ job.services.pg.id }}

Then you must create a publication to be replicated.
This can be done in any session:

    CREATE PUBLICATION postgrex_example FOR ALL TABLES;

You can also filter if you want to publish insert, update,
delete or a subset of them:

    # Skips updates (keeps inserts, deletes, begins, commits, etc)
    create PUBLICATION postgrex_example FOR ALL TABLES WITH (publish = 'insert,delete');

    # Skips inserts, updates, and deletes (keeps begins, commits, etc)
    create PUBLICATION postgrex_example FOR ALL TABLES WITH (publish = '');

Now we are ready to create module that starts a replication slot
and listens to our publication. Our example will use the pgoutput
for logical replication and print all incoming messages to the
terminal:

    Mix.install([:postgrex])

    defmodule Repl do
      use Postgrex.ReplicationConnection

      def start_link(opts) do
        # Automatically reconnect if we lose connection.
        extra_opts = [
          auto_reconnect: true
        ]

        Postgrex.ReplicationConnection.start_link(__MODULE__, :ok, extra_opts ++ opts)
      end

      @impl true
      def init(:ok) do
        {:ok, %{step: :disconnected}}
      end

      @impl true
      def handle_connect(state) do
        query = "CREATE_REPLICATION_SLOT postgrex TEMPORARY LOGICAL pgoutput NOEXPORT_SNAPSHOT"
        {:query, query, %{state | step: :create_slot}}
      end

      @impl true
      def handle_result(results, %{step: :create_slot} = state) when is_list(results) do
        query = "START_REPLICATION SLOT postgrex LOGICAL 0/0 (proto_version '1', publication_names 'postgrex_example')"
        {:stream, query, [], %{state | step: :streaming}}
      end

      @impl true
      # https://www.postgresql.org/docs/14/protocol-replication.html
      def handle_data(<<?w, _wal_start::64, _wal_end::64, _clock::64, rest::binary>>, state) do
        IO.inspect(rest)
        {:noreply, state}
      end

      def handle_data(<<?k, wal_end::64, _clock::64, reply>>, state) do
        messages =
          case reply do
            1 -> [<<?r, wal_end + 1::64, wal_end + 1::64, wal_end + 1::64, current_time()::64, 0>>]
            0 -> []
          end

        {:noreply, messages, state}
      end

      @epoch DateTime.to_unix(~U[2000-01-01 00:00:00Z], :microsecond)
      defp current_time(), do: System.os_time(:microsecond) - @epoch
    end

    {:ok, pid} =
      Repl.start_link(
        host: "localhost",
        database: "demo_dev",
        username: "postgres",
      )

    Process.sleep(:infinity)

## `use` options

`use Postgrex.ReplicationConnection` accepts a list of options which configures the
child specification and therefore how it runs under a supervisor.
The generated `child_spec/1` can be customized with the following options:

  * `:id` - the child specification identifier, defaults to the current module
  * `:restart` - when the child should be restarted, defaults to `:permanent`
  * `:shutdown` - how to shut down the child, either immediately or by giving
    it time to shut down

For example:

    use Postgrex.ReplicationConnection, restart: :transient, shutdown: 10_000

See the "Child specification" section in the `Supervisor` module for more
detailed information. The `@doc` annotation immediately preceding
`use Postgrex.ReplicationConnection` will be attached to the generated `child_spec/1`
function.

## Name registration

A `Postgrex.ReplicationConnection` is bound to the same name registration rules as a
`GenServer`. Read more about them in the `GenServer` docs.

## call(server, message, timeout \\ 5000)

Calls the given replication server.

## decode_lsn(lsn)

Returns the integer representation of an LSN value, given its string representation.

It returns `:error` if the provided string is not a valid LSN.

## Log Sequence Numbers

PostgreSQL uses two representations for the Log Sequence Number (LSN):

  * An unsigned 64-bit integer. Used internally by PostgreSQL and sent in the XLogData
  replication messages.

  * A string of two hexadecimal numbers of up to eight digits each, separated
  by a slash. e.g. `1/F73E0220`. This is the form accepted by `start_replication/2`.

For more information on Log Sequence Numbers, see
[PostgreSQL pg_lsn docs](https://www.postgresql.org/docs/current/datatype-pg-lsn.html) and
[PostgreSQL WAL internals docs](https://www.postgresql.org/docs/current/wal-internals.html).

## encode_lsn(lsn)

Returns the string representation of an LSN value, given its integer representation.

It returns `:error` if the provided integer falls outside the range for a valid
unsigned 64-bit integer.

## Log Sequence Numbers

PostgreSQL uses two representations for the Log Sequence Number (LSN):

  * An unsigned 64-bit integer. Used internally by PostgreSQL and sent in the XLogData
  replication messages.

  * A string of two hexadecimal numbers of up to eight digits each, separated
  by a slash. e.g. `1/F73E0220`. This is the form accepted by `start_replication/2`.

For more information on Log Sequence Numbers, see
[PostgreSQL pg_lsn docs](https://www.postgresql.org/docs/current/datatype-pg-lsn.html) and
[PostgreSQL WAL internals docs](https://www.postgresql.org/docs/current/wal-internals.html).

## reply(client, reply)

Replies to the given `call/3`.

## start_link(module, arg, opts)

Starts a replication process with the given callback `module`.

## Options

The options that this function accepts are the same as those
accepted by `Postgrex.start_link/1`, except for `:idle_interval`.

It also accepts extra options for connection management, documented below.
Also note this function also automatically set `:replication` to `"database"`
as part of the connection `:parameters` if none is set yet.

### Connection options

  * `:sync_connect` - controls if the connection should be established on boot
    or asynchronously right after boot. Defaults to `true`.

  * `:auto_reconnect` - automatically attempt to reconnect to the database
    in event of a disconnection. See the
    [note about async connect and auto-reconnects](#module-async-connect-and-auto-reconnects)
    above. Defaults to `false`, which means the process terminates.

  * `:reconnect_backoff` - time (in ms) between reconnection attempts when
    `:auto_reconnect` is enabled. Defaults to `500`.

## handle_call/3

Callback for `call/3`.

Replies must be sent with `reply/2`.

If `auto_reconnect: false` (the default) and there is a disconnection,
the process will terminate and the caller will exit even if no reply is
sent. However, if `auto_reconnect` is set to true, a disconnection will
keep the process alive, which means that any command that has not yet
been replied to should eventually do so. One simple approach is to
reply to any pending commands on `c:handle_disconnect/1`.

## handle_connect/1

Invoked after connecting.

This may be invoked multiple times if `:auto_reconnect` is set to true.

## handle_data/2

Callback for `:stream` outputs.

If any callback returns `{:stream, iodata, opts, state}`, then this
callback will be eventually called with the result of the query.
It receives `binary` streaming messages.

This can be useful for replication and copy commands. For replication,
the format of the messages are described [under the START_REPLICATION
section in PostgreSQL docs](https://www.postgresql.org/docs/14/protocol-replication.html).
Replication messages may require explicit acknowledgement, which can
be done by returning a list of binaries according to the replication
protocol.

## handle_disconnect/1

Invoked after disconnecting.

This is only invoked if `:auto_reconnect` is set to true.

## handle_info/2

Callback for `Kernel.send/2`.

## handle_result/2

Callback for `:query` outputs.

If any callback returns `{:query, iodata, state}` or
`{:query, iodata, opts, state}`, then this callback will
be immediately called with the result of the query.
Please note that even though replication connections use
the simple query protocol, Postgres currently limits them to
single command queries.
Due to this constraint, this callback will be passed
either a list with a single successful query result or
an error.

## init/1

Callback for process initialization.

This is called once and before the Postgrex connection is established.

## stream_opts/0

The following options configure streaming:

  * `:max_messages` - The maximum number of replications messages that can be
    accumulated from the wire until they are relayed to `handle_data/2`.
    Defaults to `500`.

## query_opts/0

The following options configure querying:

  * `:timeout` - Query request timeout (default: `infinity`);