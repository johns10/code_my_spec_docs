# telemetry_poller

A time-based poller to periodically dispatch Telemetry events.

A poller is a process start in your supervision tree with a list
of measurements to perform periodically. On start it expects the
period in milliseconds and a list of measurements to perform. Initial delay
is an optional parameter that sets time delay in milliseconds before starting
measurements:

<!-- tabs-open -->

### Erlang

```
telemetry_poller:start_link([
    {measurements, Measurements},
    {period, Period},
    {init_delay, InitDelay}
])
```

### Elixir

```
:telemetry_poller.start_link(
    measurements: measurements,
    period: period,
    init_delay: init_delay
)
```

<!-- tabs-close -->

## Measurements

The following measurements are supported:

  * `memory` (default)
  * `total_run_queue_lengths` (default)
  * `system_counts` (default)
  * `persistent_term` (default)
  * `{process_info, Proplist}`
  * `{Module, Function, Args}`

We will discuss each measurement in detail. Also note that the
`telemetry_poller` application ships with a built-in poller that
measures `memory`, `total_run_queue_lengths`, `system_counts`, and `persistent_term`. This takes
the VM measurement out of the way so your application can focus
on what is specific to its behaviour.

### Memory

An event emitted as `[vm, memory]`. The measurement includes all
the key-value pairs returned by the `erlang:memory/0` function,
e.g. `total` for total memory, `processes_used` for memory used by
all processes, and so on.

### Total run queue lengths

On startup, the Erlang VM starts many schedulers to do both IO and
CPU work. If a process needs to do some work or wait on IO, it is
allocated to the appropriate scheduler. The measurement includes the
following keys:

  * `total` - all schedulers (CPU + IO)
  * `cpu` - CPU schedulers
  * `io` - IO schedulers

### System counts

The measurement includes:

  * `process_count` - the number of processes currently existing at the local node
  * `atom_count` - the number of atoms currently existing at the local node
  * `port_count` - the number of ports currently existing at the local node
  * `process_limit` - the maximum number of processes allowed at the local node
  * `atom_limit` - the maximum number of atoms allowed at the local node
  * `port_limit` - the maximum number of ports allowed at the local node

### Persistent term (since 1.2.0)

An event emitted as `[vm, persistent_term]`. The measurement includes information
about persistent terms in the system, as returned by `persistent_term:info/0`:

  * `count` - The number of persistent terms
  * `memory` - The total amount of memory (measured in bytes) used by all persistent terms

### Process info

A measurement with information about a given process. It must be specified
alongside a proplist with the process name, the event name, and a list of
keys to be included:

<!-- tabs-open -->

### Erlang

```erlang
{process_info, [
 {name, my_app_worker},
 {event, [my_app, worker]},
 {keys, [message_queue_len, memory]}
]}
```

### Elixir

```elixir
{:process_info, [
 name: my_app_worker,
 event: [my_app, worker],
 keys: [message_queue_len, memory]
]}
```

<!-- tabs-close -->

### Custom measurements

Telemetry poller also allows you to perform custom measurements by passing
a module-function-args tuple:

<!-- tabs-open -->

### Erlang

```erlang
{my_app_example, measure, []}
```

### Elixir

```elixir
{MyApp.Example, :measure, []}
```

<!-- tabs-close -->

The given function will be invoked periodically and they must explicitly invoke the
`telemetry:execute/3` function. If the invocation of the MFA fails,
the measurement is removed from the Poller.

For all options, see `start_link/1`. The options listed there can be given
to the default poller as well as to custom pollers.

### Default poller

A default poller is started with `telemetry_poller` responsible for emitting
measurements for `memory` and `total_run_queue_lengths`. You can customize
the behaviour of the default poller by setting the `default` key under the
`telemetry_poller` application environment. Setting it to `false` disables
the poller.

## Examples

### Example 1: tracking number of active sessions in web application

Let's imagine that you have a web application and you would like to periodically
measure number of active user sessions.

<!-- tabs-open -->

### Erlang

```erlang
-module(example_app).

session_count() ->
   % logic for calculating session count.
```

### Elixir

```elixir
defmodule ExampleApp do
  def session_count do
    # logic for calculating session count
  end
end
```

<!-- tabs-close -->

To achieve that, we need a measurement dispatching the value we're interested in:

<!-- tabs-open -->

### Erlang

```erlang
-module(example_app_measurements).

dispatch_session_count() ->
   telemetry:execute([example_app, session_count], example_app:session_count()).
```

### Elixir

```elixir
defmodule ExampleApp.Measurements do
  def dispatch_session_count do
    :telemetry.execute([:example_app, :session_count], ExampleApp.session_count())
  end
end
```

<!-- tabs-close -->

and tell the Poller to invoke it periodically:

<!-- tabs-open -->

### Erlang

```erlang
telemetry_poller:start_link([{measurements, [{example_app_measurements, dispatch_session_count, []}]).
```

### Elixir

```elixir
:telemetry_poller.start_link(measurements: [{ExampleApp.Measurements, :dispatch_session_count, []}])
```

<!-- tabs-close -->

If you find that you need to somehow label the event values, e.g. differentiate between number of
sessions of regular and admin users, you could use event metadata:

<!-- tabs-open -->

### Erlang

```erlang
-module(example_app_measurements).

dispatch_session_count() ->
   Regulars = example_app:regular_users_session_count(),
   Admins = example_app:admin_users_session_count(),
   telemetry:execute([example_app, session_count], #{count => Admins}, #{role => admin}),
   telemetry:execute([example_app, session_count], #{count => Regulars}, #{role => regular}).
```

### Elixir

```elixir
defmodule ExampleApp.Measurements do
  def dispatch_session_count do
    regulars = ExampleApp.regular_users_session_count()
    admins = ExampleApp.admin_users_session_count()
    :telemetry.execute([:example_app, :session_count], %{count: admins}, %{role: :admin})
    :telemetry.execute([:example_app, :session_count], %{count: regulars}, %{role: :regular})
  end
end
```

<!-- tabs-close -->

> #### Note {: .info}
>
> The other solution would be to dispatch two different events by hooking up
> `example_app:regular_users_session_count/0` and `example_app:admin_users_session_count/0`
> functions directly. However, if you add more and more user roles to your app, you'll find
> yourself creating a new event for each one of them, which will force you to modify existing
event handlers. If you can break down event value by some feature, like user role in this
example, it's usually better to use event metadata than add new events.

This is a perfect use case for poller, because you don't need to write a dedicated process
which would call these functions periodically. Additionally, if you find that you need to collect
more statistics like this in the future, you can easily hook them up to the same poller process
and avoid creating lots of processes which would stay idle most of the time.

## init_delay()

An init delay for the poller.

## period()

A period for the poller.

## measurement()

A measurement for the poller.

## option()

An option for the poller.

## options()

A list of options for the poller.

## t()

The reference to a poller process.

## child_spec(Opts)

Returns a child spec for the poller for running under a supervisor.

## list_measurements(Poller)

Returns a list of measurements used by the poller.

## start_link(Opts)

Starts a poller linked to the calling process.

Useful for starting Pollers as a part of a supervision tree.

## Options

The default options are:

  * `{name, telemetry_poller}`
  * `{period, timer:seconds(5)}`
  * `{init_delay, 0}`