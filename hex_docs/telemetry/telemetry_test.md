# telemetry_test

Functions for testing execution of Telemetry events.

Testing that the correct Telemetry events are emitted with the
right measurements and metadata is essential for library authors.
It helps to maintain stable APIs and avoid accidental changes
to events.

## attach_event_handlers(DestinationPID, Events)

Attaches a "message" handler to the given events.

The attached handler sends a message to `DestinationPID` every time it handles one of the
events in `events`. The function returns a reference that you can use to make sure that
messages come from this handler. This reference is also used as the handler ID, so you
can use it to detach the handler with `telemetry:detach/1`.

The shape of messages sent to `DestinationPID` is:

<!-- tabs-open -->

### Erlang

```erlang
{Event, Ref, Measurements, Metadata}
```

### Elixir

```elixir
{event, ref, measurements, metadata}
```

<!-- tabs-close -->

## Examples

<!-- tabs-open -->

### Erlang

An example of a test in Erlang (using [`ct`](https://www.erlang.org/docs/23/man/ct)) could
look like this:

```erlang
Ref = telemetry_test:attach_event_handlers(self(), [[some, event]]),
function_that_emits_the_event(),
receive
    {[some, event], Ref, #{measurement := _}, #{meta := _}} ->
        telemetry:detach(Ref)
after 1000 ->
    ct:fail(timeout_receive_attach_event_handlers)
end.
```

### Elixir

An example of an ExUnit test in Elixir could look like this:

```elixir
ref = :telemetry_test.attach_event_handlers(self(), [[:some, :event]])
function_that_emits_the_event()
assert_received {[:some, :event], ^ref, %{measurement: _}, %{meta: _}}
```

<!-- tabs-close -->