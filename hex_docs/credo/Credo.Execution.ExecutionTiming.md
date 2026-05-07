# Credo.Execution.ExecutionTiming

The `ExecutionTiming` module can help in timing the execution of code parts and
storing those timing inside the `Credo.Execution` struct.

## all(execution)

Returns all timings for the given `exec`.

## append(arg, execution, tags)

Adds a timing piped from `run/2` to the given `exec` (using the given values of `tags`, `started_at` and `duration`).

## append(execution, tags, started_at, duration)

Adds a timing to the given `exec` using the given values of `tags`, `started_at` and `duration`.

## by_tag(exec, tag_name)

Returns all timings for the given `exec` and `tag_name`.

## by_tag(exec, tag_name, regex)

Returns all timings for the given `exec` and `tag_name` where the tag's value also matches the given `regex`.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## ended_at(exec)

Returns the latest timestamp plus its duration for the given `exec`.

## grouped_by_tag(exec, tag_name)

Groups all timings for the given `exec` and `tag_name`.

## inspect(label, fun)

Runs the given `fun` and prints the time it took with the given `label`.

    iex> Credo.Execution.ExecutionTiming.inspect("foo", fn -> some_complicated_stuff() end)
    foo: 51284

## now()

Returns the current timestamp in the same format (microseconds) as the returned starting times of `run/1`.

## run(fun)

Runs the given `fun` and returns a tuple of `{started_at, duration, result}`.

    iex> Credo.Execution.ExecutionTiming.run(fn -> some_complicated_stuff() end)
    {1540540119448181, 51284, [:whatever, :fun, :returned]}

## run(fun, args)

Same as `run/1` but takes `fun` and `args` separately.

## started_at(exec)

Returns the earliest timestamp for the given `exec`.