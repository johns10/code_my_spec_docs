# Finch



## stream/5

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

## stream_while/5

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

## request/3

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

## request!/3

Sends an HTTP request and returns a `Finch.Response` struct
or raises an exception in case of failure.

See `request/3` for more detailed information.

## async_request/3

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

## cancel_async_request/1

Cancels a request sent with `async_request/3`.

## get_pool_status/2

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

## stop_pool/2

Stops the pool of processes associated with the given scheme, host, port (aka SHP).

This function can be invoked to manually stop the pool to the given SHP when you know it's not
going to be used anymore.

Note that this function is not safe with respect to concurrent requests. Invoking it while
another request to the same SHP is taking place might result in the failure of that request. It
is the responsibility of the client to ensure that no request to the same SHP is taking place
while this function is being invoked.