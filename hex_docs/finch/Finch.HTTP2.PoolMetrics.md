# Finch.HTTP2.PoolMetrics

HTTP2 Pool metrics.

Available metrics:

  * `:pool_index` - Index of the pool
  * `:in_flight_requests` - Number of requests currently on the connection

Caveats:

  * HTTP2 pools have only one connection and leverage the multiplex nature
  of the protocol. That's why we only keep the in flight requests, representing
  the number of streams currently running on the connection.