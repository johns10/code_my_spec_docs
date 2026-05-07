# NimblePool

`NimblePool` is a tiny resource-pool implementation.

Pools in the Erlang VM, and therefore in Elixir, are generally process-based: they manage a group of processes. The downside of said pools is that when they have to manage resources, such as sockets or ports, the additional process leads to overhead.

In such pools, you usually end-up with two scenarios:

  * You invoke the pool manager, which returns the pooled process, which performs the operation on the socket or port for you, returning you the reply. This approach is non-optimal because all of the data sent and returned by the resource needs to be copied between processes

  * You invoke the pool manager, which returns the pooled process, which gives you access to the resource. Then you can act directly on the resource, avoiding the data copying, but you need to keep the state of the resource in sync with the process

NimblePool allows you to implement the second scenario without the addition of processes, which leads to a simpler and more efficient implementation. You should consider using NimblePool whenever you have to manage sockets, ports, or NIF resources and you want the client to perform one-off operations on them. For example, NimblePool is a good solution to manage HTTP/1 connections, ports that need to communicate with long-running programs, etc.

The downside of NimblePool is that, because all resources are under a single process, any resource management operation will happen on this single process, which is more likely to become a bottleneck. This can be addressed, however, by starting one NimblePool per scheduler and by doing scheduler-based dispatches.

NimblePool may not be a good option to manage processes. After all, the goal of NimblePool is to avoid creating processes for resources. If you already have a process, using a process-based pool such as `poolboy` will provide a better abstraction.

Finally, avoid using NimblePool to manage resources that support multiplexing, such as HTTP/2 connections. In fact, pools are not a good option to manage resources with multiplexing in general, as the pool removes the ability to multiplex.

## Types of callbacks

NimblePool has two types of callbacks. Worker callbacks and pool callbacks. The worker callbacks configure the behaviour of each worker, such as initialization, checkin and checkout. The pool callbacks configure general pool behaviour, such as initialization and queueing.

## Examples

To use `NimblePool`, you must define a module that implements the pool worker logic, outlined in the `NimblePool` behaviour.

### Port-based example

The example below keeps ports on the pool and check them out on every command. Please read the docs for `Port` before using the approach below, especially in regards to zombie ports.

```elixir
defmodule PortPool do
  @behaviour NimblePool

  @doc ~S"""
  Executes a given command against a port kept by the pool.

  First we start a pool of ports:

      iex> child = {NimblePool, worker: {PortPool, :cat}, name: PortPool}
      iex> Supervisor.start_link([child], strategy: :one_for_one)

  Now we can run commands against the ports in the pool:

      iex> PortPool.command(PortPool, "hello\n")
      "hello\n"
      iex> PortPool.command(PortPool, "world\n")
      "world\n"

  """
  def command(pool, command, opts \\ []) do
    pool_timeout = Keyword.get(opts, :pool_timeout, 5000)
    receive_timeout = Keyword.get(opts, :receive_timeout, 15000)

    NimblePool.checkout!(pool, :checkout, fn _from, port ->
      send(port, {self(), {:command, command}})

      receive do
        {^port, {:data, data}} ->
          try do
            Process.unlink(port)
            {data, :ok}
          rescue
            _ -> {data, :close}
          end
      after
        receive_timeout ->
          exit(:receive_timeout)
      end
    end, pool_timeout)
  end

  @impl NimblePool
  def init_worker(:cat = pool_state) do
    path = System.find_executable("cat")
    port = Port.open({:spawn_executable, path}, [:binary, args: ["-"]])
    {:ok, port, pool_state}
  end

  @impl NimblePool
  # Transfer the port to the caller
  def handle_checkout(:checkout, {pid, _}, port, pool_state) do
    Port.connect(port, pid)
    {:ok, port, port, pool_state}
  end

  @impl NimblePool
  # We got it back
  def handle_checkin(:ok, _from, port, pool_state) do
    {:ok, port, pool_state}
  end

  def handle_checkin(:close, _from, _port, pool_state) do
    {:remove, :closed, pool_state}
  end

  @impl NimblePool
  # On terminate, effectively close it
  def terminate_worker(_reason, port, pool_state) do
    Port.close(port)
    {:ok, pool_state}
  end
end
```

### HTTP/1-based example

The pool below uses [Mint](https://hexdocs.pm/mint) for HTTP/1 connections. It establishes connections eagerly. A better approach may be to establish connections lazily on checkout, as done by [Finch](https://github.com/keathley/finch), which is built on top of [Mint](https://github.com/elixir-mint/mint) + [NimbleOptions](https://github.com/dashbitco/nimble_options).

```elixir
defmodule HTTP1Pool do
  @behaviour NimblePool

  @doc ~S"""
  Executes a given command against a connection kept by the pool.

  First we start the pool:

      child = {NimblePool, worker: {HTTP1Pool, {:https, "elixir-lang.org", 443}}, name: HTTP1Pool}
      Supervisor.start_link([child], strategy: :one_for_one)

  Then we can use the connections in the pool:

      iex> HTTP1Pool.get(HTTP1Pool, "/")
      {:ok, %{status: 200, ...}}

  """
  def get(pool, path, opts \\ []) do
    pool_timeout = Keyword.get(opts, :pool_timeout, 5000)
    receive_timeout = Keyword.get(opts, :receive_timeout, 15000)

    NimblePool.checkout!(
      pool,
      :checkout,
      fn _from, conn ->
        {{kind, result_or_error}, conn} =
          with {:ok, conn, ref} <- Mint.HTTP1.request(conn, "GET", path, [], nil),
               {:ok, conn, result} <- receive_response([], conn, ref, %{}, receive_timeout) do
            {{:ok, result}, transfer_if_open(conn)}
          end

        {{kind, result_or_error}, conn}
      end,
      pool_timeout
    )
  end

  defp transfer_if_open(conn) do
    if Mint.HTTP1.open?(conn) do
      {:ok, conn}
    else
      :closed
    end
  end

  defp receive_response([], conn, ref, response, timeout) do
    {:ok, conn, entries} = Mint.HTTP1.recv(conn, 0, timeout)
    receive_response(entries, conn, ref, response, timeout)
  end

  defp receive_response([entry | entries], conn, ref, response, timeout) do
    case entry do
      {kind, ^ref, value} when kind in [:status, :headers] ->
        response = Map.put(response, kind, value)
        receive_response(entries, conn, ref, response, timeout)

      {:data, ^ref, data} ->
        response = Map.update(response, :data, data, &(&1 <> data))
        receive_response(entries, conn, ref, response, timeout)

      {:done, ^ref} ->
        {:ok, conn, response}

      {:error, ^ref, error} ->
        {:error, conn, error}
    end
  end

  @impl NimblePool
  def init_worker({scheme, host, port} = pool_state) do
    parent = self()

    async = fn ->
      # TODO: Add back-off
      {:ok, conn} = Mint.HTTP1.connect(scheme, host, port, [])
      {:ok, conn} = Mint.HTTP1.controlling_process(conn, parent)
      conn
    end

    {:async, async, pool_state}
  end

  @impl NimblePool
  # Transfer the conn to the caller.
  # If we lost the connection, then we remove it to try again.
  def handle_checkout(:checkout, _from, conn, pool_state) do
    with {:ok, conn} <- Mint.HTTP1.set_mode(conn, :passive) do
      {:ok, conn, conn, pool_state}
    else
      _ -> {:remove, :closed, pool_state}
    end
  end

  @impl NimblePool
  # We got it back.
  def handle_checkin(state, _from, _old_conn, pool_state) do
    with {:ok, conn} <- state,
         {:ok, conn} <- Mint.HTTP1.set_mode(conn, :active) do
      {:ok, conn, pool_state}
    else
      {:error, _} -> {:remove, :closed, pool_state}
    end
  end

  @impl NimblePool
  # If it is closed, drop it.
  def handle_info(message, conn) do
    case Mint.HTTP1.stream(conn, message) do
      {:ok, _, _} -> {:ok, conn}
      {:error, _, _, _} -> {:remove, :closed}
      :unknown -> {:ok, conn}
    end
  end

  @impl NimblePool
  # On terminate, effectively close it.
  # This will succeed even if it was already closed or if we don't own it.
  def terminate_worker(_reason, conn, pool_state) do
    Mint.HTTP1.close(conn)
    {:ok, pool_state}
  end
end
```

## checkout!(pool, command, function, timeout \\ 5000)

Checks out a worker from the pool.

It expects a command, which will be passed to the `c:handle_checkout/4`
callback. The `c:handle_checkout/4` callback will return a client state,
which is given to the `function`.

The `function` receives two arguments, the request
(`{pid(), reference()}`) and the `client_state`.
The function must return a two-element tuple, where the first element is the
return value for `checkout!/4`, and the second element is the updated `client_state`,
which will be given as the first argument to `c:handle_checkin/4`.

`checkout!/4` also has an optional `timeout` value. This value will be applied
to the checkout operation itself. The "check in" operation happens asynchronously.

## child_spec(init_arg)

Defines a pool to be started under the supervision tree.

It accepts the same options as `start_link/1` with the
addition or `:restart` and `:shutdown` that control the
"Child Specification".

## Examples

    NimblePool.child_spec(worker: {__MODULE__, :some_arg}, restart: :temporary)

## start_link(opts)

Starts a pool.

## Options

  * `:worker` - a `{worker_mod, worker_init_arg}` tuple with the worker
    module that implements the `NimblePool` behaviour and the worker
    initial argument. This argument is **required**.

  * `:pool_size` - how many workers in the pool. Defaults to `10`.

  * `:lazy` - When `true`, workers are started lazily, only when necessary.
    Defaults to `false`.

  * `:worker_idle_timeout` - Timeout in milliseconds to tag a worker as idle.
    If not nil, starts a periodic timer on the same frequency that will ping
    all idle workers using `handle_ping/2` optional callback .
    Defaults to no timeout.

  * `:max_idle_pings` - Defines a limit to the number of workers that can be pinged
    for each cycle of the `handle_ping/2` optional callback.
    Defaults to no limit. See `handle_ping/2` for more details.

## stop(pool, reason \\ :normal, timeout \\ :infinity)

Stops the given `pool`.

The pool exits with the given `reason`. The pool has `timeout` milliseconds
to terminate, otherwise it will be brutally terminated.

## Examples

    NimblePool.stop(pool)
    #=> :ok

## update(from, command)

Sends an **update** instruction to the pool about the checked out worker.

This must be called inside the `checkout!/4` callback function with
the `from` value given to `c:handle_checkout/4`.

This is useful to update the pool's state before effectively
checking the state in, which is handy when transferring
resources requires two steps.

## handle_cancelled/2

Handle cancelled checkout requests.

This callback is executed when a checkout request is cancelled unexpectedly.

The context argument may be `:queued` or `:checked_out`:

* `:queued` means the cancellation happened before resource checkout. This may happen
when the pool is starving under load and can not serve resources.

* `:checked_out` means the cancellation happened after resource checkout. This may happen
when the function given to `checkout!/4` raises.

This callback is optional.

## handle_checkin/4

Checks a worker back in the pool.

It receives the potentially-updated `client_state`, returned by the `checkout!/4`
anonymous function, and it must return either
`{:ok, worker_state, pool_state}` or `{:remove, reason, pool_state}`.

> #### Blocking the pool {: .warning}
>
> This callback is synchronous and therefore will block the pool.
> Avoid performing long work in here, instead do as much work as
> possible on the client.

Once the connection is checked in, it may immediately be handed
to another client, without traversing any of the messages in the
pool inbox.

This callback is optional.

## handle_checkout/4

Checks a worker out.

The `maybe_wrapped_command` is the `command` passed to `checkout!/4` if the worker
doesn't implement the `c:handle_enqueue/2` callback, otherwise it's the possibly-wrapped
command returned by `c:handle_enqueue/2`.

This callback must return one of:

  * `{:ok, client_state, worker_state, pool_state}` — the client state is given to
    the callback function passed to `checkout!/4`. `worker_state` and `pool_state`
    can potentially update the state of the checked-out worker and the pool.

  * `{:remove, reason, pool_state}` — `NimblePool` will remove the checked-out worker and
    attempt to checkout another worker.

  * `{:skip, Exception.t(), pool_state}` — `NimblePool` will skip the checkout, the client will
    raise the returned exception, and the worker will be left ready for the next
    checkout attempt.

> #### Blocking the pool {: .warning}
>
> This callback is synchronous and therefore will block the pool.
> Avoid performing long work in here. Instead, do as much work as
> possible on the client.

Once the worker is checked out, the worker won't handle any
messages targeted to `c:handle_info/2`.

## handle_enqueue/2

Executed by the pool whenever a request to check out a worker is enqueued.

The `command` argument should be treated as an opaque value, but it can be
wrapped with some data to be used in `c:handle_checkout/4`.

It must return either `{:ok, maybe_wrapped_command, pool_state}` or
`{:skip, Exception.t(), pool_state}` if checkout is to be skipped.

> #### Blocking the pool {: .warning}
>
> This callback is synchronous and therefore will block the pool.
> Avoid performing long work in here.

This callback is optional.

## Examples

    @impl NimblePool
    def handle_enqueue(command, pool_state) do
      {:ok, {:wrapped, command}, pool_state}
    end

## handle_info/2

Receives a message in the pool and handles it as each worker.

It receives the `message` and it must return either
`{:ok, worker_state}` to update the worker state, or `{:remove, reason}` to
remove the worker.

Since there is only a single pool process that can receive messages, this
callback is executed once for every worker when the pool receives `message`.

> #### Blocking the pool {: .warning}
>
> This callback is synchronous and therefore will block the pool while it
> executes for each worker. Avoid performing long work in here.

This callback is optional.

## handle_ping/2

Handle pings due to inactivity on the worker.

Executed whenever the idle worker periodic timer verifies that a worker has been idle
on the pool for longer than the `:worker_idle_timeout` pool configuration (in milliseconds).

This callback must return one of the following values:

  * `{:ok, worker_state}`: Updates worker state.

  * `{:remove, user_reason}`: The pool will proceed to the standard worker termination
      defined in `terminate_worker/3`.

  * `{:stop, user_reason}`: The entire pool process will be terminated, and `terminate_worker/3`
      will be called for every worker on the pool.

This callback is optional.

## Max idle pings

The `:max_idle_pings` pool option is useful to prevent sequential termination of a large number
of workers. However, it is important to keep in mind the following behaviours whenever
utilizing it.

  * If you are not terminating workers with `c:handle_ping/2`, you may end up pinging only
    the same workers over and over again because each cycle will ping only the first
    `:max_idle_pings` workers.

  * If you are terminating workers with `c:handle_ping/2`, the last worker may be terminated
    after up to `worker_idle_timeout + worker_idle_timeout * ceil(number_of_workers/max_idle_pings)`,
    instead of `2 * worker_idle_timeout` milliseconds of idle time.

For instance consider a pool with 10 workers and a ping of 1 second.

Given a negligible worker termination time and a worst-case scenario where all the workers
go idle right after a verification cycle is started, then without `max_idle_pings` the
last worker will be terminated in the next cycle (2 seconds), whereas with a
`max_idle_pings` of 2 the last worker will be terminated only in the 5th cycle (6 seconds).

## Disclaimers

  * On lazy pools, if no worker is currently on the pool the callback will never be called.
    Therefore you can not rely on this callback to terminate empty lazy pools.

  * On not lazy pools, if you return `{:remove, user_reason}` you may end up
    terminating and initializing workers at the same time every idle verification cycle.

  * On large pools, if many resources go idle at the same cycle, you may end up terminating
    a large number of workers sequentially, which could lead to the pool being unable to
    fulfill requests. See `:max_idle_pings` option to prevent this.

## handle_update/3

Handles an update instruction from a checked out worker.

See `update/2` for more information.

This callback is optional.

## init_pool/1

Initializes the pool.

It receives the worker argument passed to `start_link/1` and must
return `{:ok, pool_state}` upon successful initialization,
`:ignore` to exit normally, or `{:stop, reason}` to exit with `reason`
and return `{:error, reason}`.

This is a good place to perform a registration, for example.

It must return the `pool_state`. The `pool_state` is given to
`init_worker`. By default, it simply returns the given arguments.

This callback is optional.

## Examples

    @impl NimblePool
    def init_pool(options) do
      Registry.register(options[:registry], :some_key, :some_value)
    end

## init_worker/1

Initializes the worker.

It receives the worker argument passed to `start_link/1` if `c:init_pool/1` is
not implemented, otherwise the pool state returned by `c:init_pool/1`. It must
return `{:ok, worker_state, pool_state}` or `{:async, fun, pool_state}`, where the `fun`
is a zero-arity function that must return the worker state.

If this callback returns `{:async, fun, pool_state}`, `fun` is executed in a **separate
one-off process**. Because of this, if you start resources that the pool needs to "own",
you need to transfer ownership to the pool process. For example, if your async `fun`
opens a `:gen_tcp` socket, you'll have to use `:gen_tcp.controlling_process/2` to transfer
ownership back to the pool.

> #### Blocking the pool {: .warning}
>
> This callback is synchronous and therefore will block the pool, potentially
> for a significant amount of time since it's executed in the pool process once
> per worker. > If you need to perform long initialization, consider using the
> `{:async, fun, pool_state}` return type.

## terminate_pool/2

Handle pool termination.

The `reason` argmument is the same given to GenServer's terminate/2 callback.

It is not necessary to terminate workers here because the
`terminate_worker/3` callback has already been invoked.

This should be used only for clean up extra resources that can not be
handled by `terminate_worker/3` callback.

This callback is optional.

## terminate_worker/3

Terminates a worker.

The `reason` argument is:

  * `:DOWN` whenever the client link breaks
  * `:timeout` whenever the client times out
  * one of `:throw`, `:error`, `:exit` whenever the client crashes with one
    of the reasons above.
  * `reason` if at any point you return `{:remove, reason}`
  * if any callback raises, the raised exception will be given as `reason`.

It receives the latest known `worker_state`, which may not
be the latest state. For example, if a client checks out the
state and crashes, we don't fully know the `client_state`,
so the `c:terminate_worker/3` callback needs to take such scenarios
into account.

This callback must always return `{:ok, pool_state}` with the potentially-updated
pool state.

This callback is optional.