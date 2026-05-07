# Finch

An HTTP client with a focus on performance, built on top of
[Mint](https://github.com/elixir-mint/mint) and [NimblePool](https://github.com/dashbitco/nimble_pool).

We attempt to achieve this goal by providing efficient connection pooling strategies and avoiding copying of memory wherever possible.

Most developers will most likely prefer to use the fabulous HTTP client [Req](https://github.com/wojtekmach/req) which takes advantage of Finch's pooling and provides an extremely friendly and pleasant to use API.

## Usage

In order to use Finch, you must start it and provide a `:name`. Often in your
supervision tree:

```elixir
children = [
  {Finch, name: MyFinch}
]
```

Or, in rare cases, dynamically:

```elixir
Finch.start_link(name: MyFinch)
```

Once you have started your instance of Finch, you are ready to start making requests:

```elixir
Finch.build(:get, "https://hex.pm") |> Finch.request(MyFinch)
```

When using HTTP/1, Finch will parse the passed in URL into a `{scheme, host, port}`
tuple, and maintain one or more connection pools for each `{scheme, host, port}` you
interact with.

You can also configure a pool size and count to be used for specific URLs that are
known before starting Finch. The passed URLs will be parsed into `{scheme, host, port}`,
and the corresponding pools will be started. See `Finch.start_link/1` for configuration
options.

```elixir
children = [
  {Finch,
   name: MyConfiguredFinch,
   pools: %{
     :default => [size: 10, count: 2],
     "https://hex.pm" => [size: 32, count: 8]
   }}
]
```

Pools will be started for each configured `{scheme, host, port}` when Finch is started.
For any unconfigured `{scheme, host, port}`, the pool will be started the first time
it is requested using the `:default` configuration. This means given the pool
configuration above each origin/`{scheme, host, port}` will launch 2 (`:count`) new pool
processes. So, if you encountered 10 separate combinations, that'd be 20 pool processes.

Note pools are not automatically terminated by default, if you need to
terminate them after some idle time, use the `pool_max_idle_time` option (available only for HTTP1 pools).

## Telemetry

Finch uses Telemetry to provide instrumentation. See the `Finch.Telemetry`
module for details on specific events.

## Logging TLS Secrets

Finch supports logging TLS secrets to a file. These can be later used in a tool such as
Wireshark to decrypt HTTPS sessions. To use this feature you must specify the file to
which the secrets should be written. If you are using TLSv1.3 you must also add
`keep_secrets: true` to your pool `:transport_opts`. For example:

```elixir
{Finch,
 name: MyFinch,
 pools: %{
   default: [conn_opts: [transport_opts: [keep_secrets: true]]]
 }}
```

There are two different ways to specify this file:

1. The `:ssl_key_log_file` connection option in your pool configuration. For example:

```elixir
{Finch,
 name: MyFinch,
 pools: %{
   default: [
     conn_opts: [
       ssl_key_log_file: "/writable/path/to/the/sslkey.log"
     ]
   ]
 }}
```

2. Alternatively, you could also set the `SSLKEYLOGFILE` environment variable.

## async_request(req, name, opts \\ [])

Sends an HTTP request asynchronously, returning a request reference.

If the request is sent using HTTP1, an extra process is spawned to
consume messages from the underlying socket. The messages are sent
to the current process as soon as they arrive, as a firehose.  If
you wish to maximize request rate or have more control over how
messages are streamed, a strategy using `request/3` or `stream/5`
should be used instead.

## Receiving the response

Response information is sent to the calling process as it is received
in `{ref, response}` tuples.

If the calling process exits before the request has completed, the
request will be canceled.

Responses include:

  * `{:status, status}` - HTTP response status
  * `{:headers, headers}` - HTTP response headers
  * `{:data, data}` - section of the HTTP response body
  * `{:error, exception}` - an error occurred during the request
  * `:done` - request has completed successfully

On a successful request, a single `:status` message will be followed
by a single `:headers` message, after which more than one `:data`
messages may be sent. If trailing headers are present, a final
`:headers` message may be sent. Any `:done` or `:error` message
indicates that the request has succeeded or failed and no further
messages are expected.

## Example

    iex> req = Finch.build(:get, "https://httpbin.org/stream/5")
    iex> ref = Finch.async_request(req, MyFinch)
    iex> flush()
    {ref, {:status, 200}}
    {ref, {:headers, [...]}}
    {ref, {:data, "..."}}
    {ref, :done}

## Options

Shares options with `request/3`.

## build(method, url, headers \\ [], body \\ nil, opts \\ [])

Builds an HTTP request to be sent with `request/3` or `stream/4`.

It is possible to send the request body in a streaming fashion. In order to do so, the
`body` parameter needs to take form of a tuple `{:stream, body_stream}`, where `body_stream`
is a `Stream`.

## cancel_async_request(request_ref)

Cancels a request sent with `async_request/3`.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## get_pool_status(finch_name, url)

Get pool metrics.

When given a URL or SHP tuple, this returns the metrics list for that specific
pool. The number of items in the metrics list depends on the configured
`:count` option and each entry will have a `pool_index` going from 1 to
`:count`.

When `:default` is provided, Finch returns the metrics for all pools started
from the `:default` configuration. In this case the return value is a map
keyed by each pool's `{scheme, host, port}` tuple with the corresponding
metrics list as the value.

The metrics struct depends on the pool scheme defined in the `:protocols`
option: `Finch.HTTP1.PoolMetrics` for `:http1` and `Finch.HTTP2.PoolMetrics`
for `:http2`. See the documentation for those modules for more details.

`{:error, :not_found}` is returned in the following scenarios:

  * There is no pool registered for the given Finch instance and URL/SHP.
  * The pool has `start_pool_metrics?: false` (the default).
  * `:default` is provided but no pools have been started from the
    `:default` configuration (or none have metrics enabled).

## Examples

    iex> Finch.get_pool_status(MyFinch, "https://httpbin.org")
    {:ok, [
      %Finch.HTTP1.PoolMetrics{
        pool_index: 1,
        pool_size: 50,
        available_connections: 43,
        in_use_connections: 7
      },
      %Finch.HTTP1.PoolMetrics{
        pool_index: 2,
        pool_size: 50,
        available_connections: 37,
        in_use_connections: 13
      }]
    }

    iex> Finch.get_pool_status(MyFinch, :default)
    {:ok,
     %{
       {:https, "httpbin.org", 443} => [
         %Finch.HTTP1.PoolMetrics{
           pool_index: 1,
           pool_size: 50,
           available_connections: 43,
           in_use_connections: 7
         }
       ]
     }}

## request(req, name, opts \\ [])

Sends an HTTP request and returns a `Finch.Response` struct.

It can still raise exceptions if it was not possible to check out a connection in the given `:pool_timeout`.

## Options

  * `:pool_timeout` - This timeout is applied when we check out a connection from the pool.
    Default value is `5_000`.

  * `:receive_timeout` - The maximum time to wait for each chunk to be received before returning an error.
    Default value is `15_000`.

  * `:request_timeout` - The amount of time to wait for a complete response before returning an error.
    This timeout only applies to HTTP/1, and its current implementation is a best effort timeout,
    it does not guarantee the call will return precisely when the time has elapsed.
    Default value is `:infinity`.

## request!(req, name, opts \\ [])

Sends an HTTP request and returns a `Finch.Response` struct
or raises an exception in case of failure.

See `request/3` for more detailed information.

## start_link(opts)

Start an instance of Finch.

## Options

  * `:name` - The name of your Finch instance. This field is required.

  * `:pools` - A map specifying the configuration for your pools. The keys should be URLs
  provided as binaries, a tuple `{scheme, {:local, unix_socket}}` where `unix_socket` is the path for
  the socket, or the atom `:default` to provide a catch-all configuration to be used for any
  unspecified URLs - meaning that new pools for unspecified URLs will be started using the `:default`
  configuration. See "Pool Configuration Options" below for details on the possible map
  values. Default value is `%{default: [size: 50, count: 1]}`.

### Pool Configuration Options

* `:protocol` - *This option is deprecated. Use `:protocols` instead.*

* `:protocols` - The type of connections to support.

  If using `:http1` only, an HTTP1 pool without multiplexing is used. If using `:http2` only, an HTTP2 pool with multiplexing is used. If both are listed, then both HTTP1/HTTP2 connections are supported (via ALPN), but there is no multiplexing.

  The default value is `[:http1]`.

* `:size` (`t:pos_integer/0`) - Number of connections to maintain in each pool. Used only by HTTP1 pools since HTTP2 is able to multiplex requests through a single connection. In other words, for HTTP2, the size is always 1 and the `:count` should be configured in order to increase capacity. The default value is `50`.

* `:count` (`t:pos_integer/0`) - Number of pools to start. HTTP1 pools are able to re-use connections in the same pool and establish new ones only when necessary. However, if there is a high pool count and few requests are made, these requests will be scattered across pools, reducing connection reuse. It is recommended to increase the pool count for HTTP1 only if you are experiencing high checkout times. The default value is `1`.

* `:max_idle_time` (`t:timeout/0`) - *This option is deprecated. Use :conn_max_idle_time instead.* The maximum number of milliseconds an HTTP1 connection is allowed to be idle before being closed during a checkout attempt.

* `:conn_opts` (`t:keyword/0`) - These options are passed to `Mint.HTTP.connect/4` whenever a new connection is established. `:mode` is not configurable as Finch must control this setting. Typically these options are used to configure proxying, https settings, or connect timeouts. The default value is `[]`.

* `:pool_max_idle_time` (`t:timeout/0`) - The maximum number of milliseconds that a pool can be idle before being terminated, used only by HTTP1 pools. This options is forwarded to NimblePool and it starts and idle verification cycle that may impact performance if misused. For instance setting a very low timeout may lead to pool restarts. For more information see NimblePool's `handle_ping/2` documentation. The default value is `:infinity`.

* `:conn_max_idle_time` (`t:timeout/0`) - The maximum number of milliseconds an HTTP1 connection is allowed to be idle before being closed during a checkout attempt. The default value is `:infinity`.

* `:start_pool_metrics?` (`t:boolean/0`) - When true, pool metrics will be collected and available through `get_pool_status/2` The default value is `false`.

## stop_pool(finch_name, url)

Stops the pool of processes associated with the given scheme, host, port (aka SHP).

This function can be invoked to manually stop the pool to the given SHP when you know it's not
going to be used anymore.

Note that this function is not safe with respect to concurrent requests. Invoking it while
another request to the same SHP is taking place might result in the failure of that request. It
is the responsibility of the client to ensure that no request to the same SHP is taking place
while this function is being invoked.

## stream(req, name, acc, fun, opts \\ [])

Streams an HTTP request and returns the accumulator.

A function of arity 2 is expected as argument. The first argument
is a tuple, as listed below, and the second argument is the
accumulator. The function must return a potentially updated
accumulator.

See also `stream_while/5`.

> ### HTTP2 streaming and back-pressure {: .warning}
>
> At the moment, streaming over HTTP2 connections do not provide
> any back-pressure mechanism: this means the response will be
> sent to the client as quickly as possible. Therefore, you must
> not use streaming over HTTP2 for non-terminating responses or
> when streaming large responses which you do not intend to keep
> in memory.

## Stream commands

  * `{:status, status}` - the http response status
  * `{:headers, headers}` - the http response headers
  * `{:data, data}` - a streaming section of the http response body
  * `{:trailers, trailers}` - the http response trailers

## Options

Shares options with `request/3`.

## Examples

    path = "/tmp/archive.zip"
    file = File.open!(path, [:write, :exclusive])
    url = "https://example.com/archive.zip"
    request = Finch.build(:get, url)

    Finch.stream(request, MyFinch, nil, fn
      {:status, status}, _acc ->
        IO.inspect(status)

      {:headers, headers}, _acc ->
        IO.inspect(headers)

      {:data, data}, _acc ->
        IO.binwrite(file, data)
    end)

    File.close(file)

## stream_while(req, name, acc, fun, opts \\ [])

Streams an HTTP request until it finishes or `fun` returns `{:halt, acc}`.

A function of arity 2 is expected as argument. The first argument
is a tuple, as listed below, and the second argument is the
accumulator.

The function must return:

  * `{:cont, acc}` to continue streaming
  * `{:halt, acc}` to halt streaming

See also `stream/5`.

> ### HTTP2 streaming and back-pressure {: .warning}
>
> At the moment, streaming over HTTP2 connections do not provide
> any back-pressure mechanism: this means the response will be
> sent to the client as quickly as possible. Therefore, you must
> not use streaming over HTTP2 for non-terminating responses or
> when streaming large responses which you do not intend to keep
> in memory.

## Stream commands

  * `{:status, status}` - the http response status
  * `{:headers, headers}` - the http response headers
  * `{:data, data}` - a streaming section of the http response body
  * `{:trailers, trailers}` - the http response trailers

## Options

Shares options with `request/3`.

## Examples

    path = "/tmp/archive.zip"
    file = File.open!(path, [:write, :exclusive])
    url = "https://example.com/archive.zip"
    request = Finch.build(:get, url)

    Finch.stream_while(request, MyFinch, nil, fn
      {:status, status}, acc ->
        IO.inspect(status)
        {:cont, acc}

      {:headers, headers}, acc ->
        IO.inspect(headers)
        {:cont, acc}

      {:data, data}, acc ->
        IO.binwrite(file, data)
        {:cont, acc}
    end)

    File.close(file)

## name/0

The `:name` provided to Finch in `start_link/1`.

## pool_metrics/0

Pool metrics returned by `get_pool_status/2` for a single pool.

## default_pool_metrics/0

Pool metrics grouped by SHP when querying the `:default` configuration.

## request_opts/0

Options used by request functions.

## stream/1

The stream function given to `stream/5`.

## stream_while/1

The stream function given to `stream_while/5`.

## request_ref/0

The reference used to identify a request sent using `async_request/3`.