# DBConnection.LogEntry

Struct containing log entry information.

See `t:t/0` for information on the fields.

## t/0

Log entry information.

  * `:call` - The `DBConnection` function called
  * `:query` - The query used by the function
  * `:params` - The params passed to the function (if any)
  * `:result` - The result of the call
  * `:pool_time` - The length of time awaiting a connection from the pool (if
  the connection was not already checked out)
  * `:connection_time` - The length of time using the connection (if a
  connection was used)
  * `:decode_time` - The length of time decoding the result (if decoded the
  result using `DBConnection.Query.decode/3`)
  * `:idle_time` - The amount of time the connection was idle before use

All times are in the native time units of the VM, see
`System.monotonic_time/0`.