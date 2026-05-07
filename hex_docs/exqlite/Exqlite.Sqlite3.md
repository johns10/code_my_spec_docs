# Exqlite.Sqlite3

The interface to the NIF implementation.

## bind(stmt, args)

Resets a prepared statement and binds values to it.

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?, ?, ?, ?, ?")
    iex> Sqlite3.bind(stmt, [42, 3.14, "Alice", {:blob, <<0, 0, 0>>}, nil])
    iex> Sqlite3.step(conn, stmt)
    {:row, [42, 3.14, "Alice", <<0, 0, 0>>, nil]}

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT :42, @pi, $name, @blob, :null")
    iex> Sqlite3.bind(stmt, %{":42" => 42, "@pi" => 3.14, "$name" => "Alice", :"@blob" => {:blob, <<0, 0, 0>>}, ~c":null" => nil})
    iex> Sqlite3.step(conn, stmt)
    {:row, [42, 3.14, "Alice", <<0, 0, 0>>, nil]}

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?")
    iex> Sqlite3.bind(stmt, [42, 3.14, "Alice"])
    ** (ArgumentError) expected 1 arguments, got 3

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?, ?")
    iex> Sqlite3.bind(stmt, [42])
    ** (ArgumentError) expected 2 arguments, got 1

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?")
    iex> Sqlite3.bind(stmt, [:erlang.list_to_pid(~c"<0.0.0>")])
    ** (ArgumentError) unsupported type: #PID<0.0.0>

## bind_blob(stmt, index, blob)

Binds a blob value to a prepared statement.

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?")
    iex> Sqlite3.bind_blob(stmt, 1, <<0, 0, 0>>)
    :ok

## bind_float(stmt, index, float)

Binds a float value to a prepared statement.

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?")
    iex> Sqlite3.bind_float(stmt, 1, 3.14)
    :ok

## bind_integer(stmt, index, integer)

Binds an integer value to a prepared statement.

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?")
    iex> Sqlite3.bind_integer(stmt, 1, 42)
    :ok

## bind_null(stmt, index)

Binds a null value to a prepared statement.

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?")
    iex> Sqlite3.bind_null(stmt, 1)
    :ok

## bind_parameter_count(stmt)

Returns number of SQL parameters in a prepared statement.

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?, ?")
    iex> Sqlite3.bind_parameter_count(stmt)
    2

## bind_text(stmt, index, text)

Binds a text value to a prepared statement.

    iex> {:ok, conn} = Sqlite3.open(":memory:", [:readonly])
    iex> {:ok, stmt} = Sqlite3.prepare(conn, "SELECT ?")
    iex> Sqlite3.bind_text(stmt, 1, "Alice")
    :ok

## changes(conn)

Get the number of changes recently.

**Note**: If triggers are used, the count may be larger than expected.

See: https://sqlite.org/c3ref/changes.html

## close(conn)

Closes the database and releases any underlying resources.

## deserialize(conn, database \\ "main", serialized)

Disconnect from database and then reopen as an in-memory database based on
the serialized binary.

## enable_load_extension(conn, flag)

Allow loading native extensions.

## execute(conn, sql)

Executes an sql script. Multiple stanzas can be passed at once.

## interrupt(conn)

Interrupt a long-running query.

> #### Warning {: .warning}
> If you are going to interrupt a long running process, it is unsafe to call
> `close/1` immediately after. You run the risk of undefined behavior. This
> is a limitation of the sqlite library itself. Please see the documentation
> https://www.sqlite.org/c3ref/interrupt.html for more information.
>
> If close must be called after, it is best to put a short sleep in order to
> let sqlite finish doing its book keeping.

## open(path, opts \\ [])

Opens a new sqlite database at the Path provided.

`path` can be `":memory"` to keep the sqlite database in memory.

## Options

  * `:mode` - use `:readwrite` to open the database for reading and writing
    , `:readonly` to open it in read-only mode or `[:readonly | :readwrite, :nomutex]`
    to open it with no mutex mode. `:readwrite` will also create
    the database if it doesn't already exist. Defaults to `:readwrite`.
    Note: [:readwrite, :nomutex] is not recommended.

## release(conn, statement)

Once finished with the prepared statement, call this to release the underlying
resources.

This should be called whenever you are done operating with the prepared statement. If
the system has a high load the garbage collector may not clean up the prepared
statements in a timely manner and causing higher than normal levels of memory
pressure.

If you are operating on limited memory capacity systems, definitely call this.

## reset(stmt)

Resets a prepared statement.

See: https://sqlite.org/c3ref/reset.html

## serialize(conn, database \\ "main")

Serialize the contents of the database to a binary.

## set_log_hook(pid)

Send log messages to a process.

Each time a message is logged in SQLite a message will be sent to the pid provided as the argument.

The message is of the form: `{:log, rc, message}`, where:

  * `rc` is an integer [result code](https://www.sqlite.org/rescode.html) or an [extended result code](https://www.sqlite.org/rescode.html#extrc)
  * `message` is a string representing the log message

See [`SQLITE_CONFIG_LOG`](https://www.sqlite.org/c3ref/c_config_covering_index_scan.html) and
["The Error And Warning Log"](https://www.sqlite.org/errlog.html) for more details.

## Restrictions

  * Only one pid can listen to the log messages at a time.
    If this function is called multiple times, only the last pid will
    receive the notifications

## set_update_hook(conn, pid)

Send data change notifications to a process.

Each time an insert, update, or delete is performed on the connection provided
as the first argument, a message will be sent to the pid provided as the second argument.

The message is of the form: `{action, db_name, table, row_id}`, where:

  * `action` is one of `:insert`, `:update` or `:delete`
  * `db_name` is a string representing the database name where the change took place
  * `table` is a string representing the table name where the change took place
  * `row_id` is an integer representing the unique row id assigned by SQLite

## Restrictions

  * There are some conditions where the update hook will not be invoked by SQLite.
    See the documentation for [more details](https://www.sqlite.org/c3ref/update_hook.html)
  * Only one pid can listen to the changes on a given database connection at a time.
    If this function is called multiple times for the same connection, only the last pid will
    receive the notifications
  * Updates only happen for the connection that is opened. For example, there
    are two connections A and B. When an update happens on connection B, the
    hook set for connection A will not receive the update, but the hook for
    connection B will receive the update.

## shrink_memory(conn)

Causes the database connection to free as much memory as it can. This is
useful if you are on a memory restricted system.