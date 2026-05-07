# telemetry

`telemetry` allows you to invoke certain functions whenever a
particular event is emitted.

For more information see the documentation for `attach/4`, `attach_many/4`
and `execute/2`.

## list_handlers(EventPrefix)

Returns all handlers attached to events with given prefix.

Handlers attached to many events at once using `attach_many/4` will be listed once for each
event they're attached to.
Note that you can list all handlers by feeding this function an empty list.

## execute(EventName, Measurements)

Same as [`execute(EventName, Measurements, #{})`](`execute/3`).

## span(EventPrefix, StartMetadata, SpanFunction)

Runs the provided `SpanFunction`, emitting start and stop/exception events, invoking the handlers attached to each.

The `SpanFunction` must return a `{result, stop_metadata}` or a `{result, extra_measurements, stop_metadata}` tuple.

When this function is called, 2 events will be emitted via `execute/3`. Those events will be one of the following
pairs:

  * `EventPrefix ++ [start]` and `EventPrefix ++ [stop]`
  * `EventPrefix ++ [start]` and `EventPrefix ++ [exception]`

However, note that in case the current process crashes due to an exit signal
of another process, then none or only part of those events would be emitted.
Below is a breakdown of the measurements and metadata associated with each individual event.

When providing `StartMetadata` and `StopMetadata`, these values will be sent independently to `start` and
`stop` events. If an exception occurs, exception metadata will be merged onto the `StartMetadata`. In general,
it is **highly recommended** that `StopMetadata` should include the values from `StartMetadata`
so that handlers, such as those used for metrics, can rely entirely on the `stop` event. Failure to include
all of `StartMetadata` in `StopMetadata` can add significant complexity to event handlers.

A default span context is added to event metadata under the `telemetry_span_context` key if this key is not provided
by the user in the `StartMetadata`. This context is useful for tracing libraries to identify unique
executions of span events within a process to match start, stop, and exception events. Metadata keys which
should be available to both `start` and `stop` events need to supplied separately for `StartMetadata` and
`StopMetadata`.

If `SpanFunction` returns `{result, extra_measurements, stop_metadata}`, then a map of extra measurements
will be merged with the measurements automatically provided. This is useful if you want to return, for example,
bytes from an HTTP request. The standard measurements `duration` and `monotonic_time` cannot be overridden.

For `telemetry` events denoting the **start** of a larger event, the following data is provided:

  * Event:

    ```
    EventPrefix ++ [start]
    ```

  * Measurements:

    ```
    #{
      % The current system time in native units from
      % calling: erlang:system_time()
      system_time => integer(),
      monotonic_time => integer(),
    }
    ```

  * Metadata:

    ```
    #{
      telemetry_span_context => term(),
      % User defined metadata as provided in StartMetadata
      ...
    }
    ```



For `telemetry` events denoting the **stop** of a larger event, the following data is provided:

  * Event:

    ```
    EventPrefix ++ [stop]
    ```

  * Measurements:

    ```
    #{
      % The current monotonic time minus the start monotonic time in native units
      % by calling: erlang:monotonic_time() - start_monotonic_time
      duration => integer(),
      monotonic_time => integer(),
      % User defined measurements when returning `SpanFunction` as a 3 element tuple
    }
    ```

  * Metadata:

    ```
    #{
      % An optional error field if the stop event is the result of an error
      % but not necessarily an exception.
      error => term(),
      telemetry_span_context => term(),
      % User defined metadata as provided in StopMetadata
      ...
    }
    ```

For `telemetry` events denoting an **exception** of a larger event, the following data is provided:

  * Event:

    ```
    EventPrefix ++ [exception]
    ```

  * Measurements:

    ```
    #{
      % The current monotonic time minus the start monotonic time in native units
      % by calling: erlang:monotonic_time() - start_monotonic_time
      duration => integer(),
      monotonic_time => integer()
    }
    ```

  * Metadata:

    ```
    #{
      kind => throw | error | exit,
      reason => term(),
      stacktrace => list(),
      telemetry_span_context => term(),
      % User defined metadata as provided in StartMetadata
       ...
    }
    ```

## execute(EventName, Measurements, Metadata)

Emits the event, invoking handlers attached to it.

When the event is emitted, the handler function provided to `attach/4` is called with four
arguments:

  * the event name
  * the map of measurements
  * the map of event metadata
  * the handler configuration given to `attach/4`

#### Best practices and conventions:

While you are able to emit messages of any `t:event_name/0` structure, it is recommended that you follow the
the guidelines laid out in `span/3` if you are capturing start/stop events.

## detach(HandlerId)

Removes the existing handler.

If the handler with given ID doesn't exist, `{error, not_found}` is returned.

## persist()

Persist telemetry handlers.

This will improve performance of calling Telemetry handlers at the cost of
reducing performance of attaching or detaching new handlers.

This function should be used with care.

## attach_many(HandlerId, EventNames, Function, Config)

Attaches the handler to many events.

The handler will be invoked whenever any of the events in the `EventNames` list is emitted. Note
that failure of the handler on any of these invocations will detach it from all the events in
`EventNames` (the same applies to manual detaching using `detach/1`).

<b>Note:</b> due to how anonymous functions are implemented in the Erlang VM, it is best to use
function captures (i.e. `fun mod:fun/4` in Erlang or `&Mod.fun/4` in Elixir) as event handlers
to achieve maximum performance. In other words, avoid using literal anonymous functions
(`fun(...) -> ... end` or `fn ... -> ... end`) or local function captures (`fun handle_event/4`
or `&handle_event/4`) as event handlers.

All the handlers are executed by the process dispatching event. If the function fails (raises,
exits or throws) a handler failure event is emitted and then the handler is removed.

Failing handlers emit a failure event, which is documented in `attach/4`.

Note that you should not rely on the order in which handlers are invoked.

## attach(HandlerId, EventName, Function, Config)

Attaches the handler to the event.

`HandlerId` must be unique, if another handler with the same ID already exists the
`{error, already_exists}` tuple is returned.

See `execute/3` to learn how the handlers are invoked.

> #### Function Captures {: .info}
>
> Due to how anonymous functions are implemented in the Erlang VM, it is best to use
> function captures (`fun mod:fun/4` in Erlang or `&Mod.fun/4` in Elixir) as event handlers
> to achieve the best performance. In other words, avoid using literal anonymous functions
> (`fun(...) -> ... end` or `fn ... -> ... end`) or local function captures (`fun handle_event/4`
> or `&handle_event/4`) as event handlers.

All the handlers are executed by the process dispatching event. If the function fails (raises,
exits or throws) then the handler is removed and a failure event is emitted.

Note that you should not rely on the order in which handlers are invoked.

### Failing Handlers

When a handler fails, it is removed and a **failure event** is emitted.
This is useful for monitoring and diagnostic purposes.

Handler failure events are executed as:

  * Event name: `[telemetry, handler, failure]`
  * Measurements:
    * `monotonic_time` - The current monotonic time in native units from calling
      `erlang:monotonic_time/0`
    * `system_time` - The current system time in native units from calling
      `erlang:system_time/0`
  * Metadata:
    * `event_name` - The event that failed (`t:event_name/0`)
    * `handler_id` - The ID of the handler that failed
    * `handler_config` - The configuration of the handler that failed
    * `kind` - The kind of failure (`error`, `exit`, `throw`)
    * `reason` - The reason for the failure
    * `stacktrace` - The stacktrace for the failure

These handler failure events should only be used for monitoring and diagnostic purposes.
Re-attaching a failed handler will likely result in the handler failing again.