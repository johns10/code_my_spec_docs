# Postgrex.Notifications

API for notifications (pub/sub) in PostgreSQL.

In order to use it, first you need to start the notification process.
In your supervision tree:

    {Postgrex.Notifications, name: MyApp.Notifications}

Then you can listen to certain channels:

    {:ok, listen_ref} = Postgrex.Notifications.listen(MyApp.Notifications, "channel")

Now every time a message is broadcast on said channel, for example via
PostgreSQL command line:

    NOTIFY "channel", "Oh hai!";

You will receive a message in the format:

    {:notification, notification_pid, listen_ref, channel, message}

## Async connect, auto-reconnects and missed notifications

By default, the notification system establishes a connection to the
database on initialization, you can configure the connection to happen
asynchronously. You can also configure the connection to automatically
reconnect.

Note however that when the notification system is waiting for a connection,
any notifications that occur during the disconnection period are not queued
and cannot be recovered. Similarly, any listen command will be queued until
the connection is up.

There is a race condition between starting to listen and notifications being
issued "at the same time", as explained [in the PostgreSQL documentation](https://www.postgresql.org/docs/current/sql-listen.html).
If your application needs to keep a consistent representation of data, follow
the three-step approach of first subscribing, then obtaining the current
state of data, then handling the incoming notifications.

Beware that the same
race condition applies to auto-reconnects. A simple way of dealing with this
issue is not using the auto-reconnect feature directly, but monitoring and
re-starting the Notifications process, then subscribing to channel messages
over again, using the same three-step approach.

## A note on casing

While PostgreSQL seems to behave as case-insensitive, it actually has a very
peculiar behaviour on casing. When you write:

    SELECT * FROM POSTS

PostgreSQL actually converts `POSTS` into the lowercase `posts`. That's why
both `SELECT * FROM POSTS` and `SELECT * FROM posts` feel equivalent.
However, if you wrap the table name in quotes, then the casing in quotes
will be preserved.

These same rules apply to PostgreSQL notification channels. More importantly,
whenever `Postgrex.Notifications` listens to a channel, it wraps the channel
name in quotes. Therefore, if you listen to a channel named "fooBar" and
you send a notification without quotes in the channel name, such as:

    NOTIFY fooBar, "Oh hai!";

The notification will not be received by Postgrex.Notifications because the
notification will be effectively sent to `"foobar"` and not `"fooBar"`. Therefore,
you must guarantee one of the two following properties:

  1. If you can wrap the channel name in quotes when sending a notification,
     then make sure the channel name has the exact same casing when listening
     and sending notifications

  2. If you cannot wrap the channel name in quotes when sending a notification,
     then make sure to give the lowercased channel name when listening

## listen(pid, channel, opts \\ [])

Listens to an asynchronous notification channel using the `LISTEN` command.

A message `{:notification, connection_pid, ref, channel, payload}` will be
sent to the calling process when a notification is received.

It returns `{:ok, reference}`. It may also return `{:eventually, reference}`
if the notification process is not currently connected to the database and
it was started with `:sync_connect` set to false or `:auto_reconnect` set
to true. The `reference` can be used to issue an `unlisten/3` command.

## Options

  * `:timeout` - Call timeout (default: `5000`)

## listen!(pid, channel, opts \\ [])

Listens to an asynchronous notification channel `channel`. See `listen/2`.

## start_link(opts)

Start the notification connection process and connect to postgres.

The options that this function accepts are the same as those accepted by
`Postgrex.start_link/1`, as well as the extra options `:sync_connect`,
`:auto_reconnect`, `:reconnect_backoff`, and `:configure`.

## Options

  * `:sync_connect` - controls if the connection should be established on boot
    or asynchronously right after boot. Defaults to `true`.

  * `:auto_reconnect` - automatically attempt to reconnect to the database
    in event of a disconnection. See the
    [note about async connect and auto-reconnects](#module-async-connect-and-auto-reconnects)
    above. Defaults to `false`, which means the process terminates.

  * `:reconnect_backoff` - time (in ms) between reconnection attempts when
    `auto_reconnect` is enabled. Defaults to `500`.

  * `:idle_interval` - while also accepted on `Postgrex.start_link/1`, it has
    a default of `5000ms` in `Postgrex.Notifications` (instead of 1000ms).

  * `:configure` - A function to run before every connect attempt to dynamically
    configure the options as a `{module, function, args}`, where the current
    options will prepended to `args`. Defaults to `nil`.

## unlisten(pid, ref, opts \\ [])

Stops listening on the given channel by passing the reference returned from
`listen/2`.

## Options

  * `:timeout` - Call timeout (default: `5000`)

## unlisten!(pid, ref, opts \\ [])

Stops listening on the given channel by passing the reference returned from
`listen/2`.