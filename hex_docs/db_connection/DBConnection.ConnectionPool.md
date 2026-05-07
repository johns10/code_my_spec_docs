# DBConnection.ConnectionPool

The default connection pool.

The queueing algorithm is based on [CoDel](https://queue.acm.org/appendices/codel.html).

You're not supposed to call any functions on this pool directly, but only pass this
as the value of the `:pool` option in functions such as `DBConnection.start_link/2`.

`disconnect_all/3`, which by default will result in connections being
reestablished, can be called periodically to recycle checked-in connections
after a maximum lifetime is reached. `Ecto SQL` users may find it at
https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.html#disconnect_all/3

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.