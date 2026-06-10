# Mox



## set_mox_private/1

Sets the Mox to private mode.

In private mode, mocks can be set and consumed by the same
process unless other processes are explicitly allowed.

## Examples

    setup :set_mox_private

## set_mox_global/1

Sets the Mox to global mode.

In global mode, mocks can be consumed by any process.

An ExUnit case where tests use Mox in global mode cannot be
`async: true`.

## Examples

    setup :set_mox_global

## set_mox_from_context/1

Chooses the Mox mode based on context.

When `async: true` is used, `set_mox_private/1` is called,
otherwise `set_mox_global/1` is used.

## Examples

    setup :set_mox_from_context

## defmock/2

Defines a mock with the given name `:for` the given behaviour(s).

    Mox.defmock(MyMock, for: MyBehaviour)

With multiple behaviours:

    Mox.defmock(MyMock, for: [MyBehaviour, MyOtherBehaviour])

## Options

  * `:for` - module or list of modules to define the mock module for.

  * `:moduledoc` - `@moduledoc` for the defined mock module.

  * `:skip_optional_callbacks` - boolean to determine whether to skip
    or generate optional callbacks in the mock module.

## Skipping optional callbacks

By default, functions are created for all the behaviour's callbacks,
including optional ones. But if for some reason you want to skip one or more
of its `@optional_callbacks`, you can provide the list of callback names to
skip (along with their arities) as `:skip_optional_callbacks`:

    Mox.defmock(MyMock, for: MyBehaviour, skip_optional_callbacks: [on_success: 2])

This will define a new mock (`MyMock`) that has a defined function for each
callback on `MyBehaviour` except for `on_success/2`. Note: you can only skip
optional callbacks, not required callbacks.

You can also pass `true` to skip all optional callbacks, or `false` to keep
the default of generating functions for all optional callbacks.

## Passing `@moduledoc`

You can provide value for `@moduledoc` with `:moduledoc` option.

    Mox.defmock(MyMock, for: MyBehaviour, moduledoc: false)
    Mox.defmock(MyMock, for: MyBehaviour, moduledoc: "My mock module.")

## expect/4

Expects the `name` in `mock` with arity given by `code`
to be invoked `n` times.

If you're calling your mock from an asynchronous process and want
to wait for the mock to be called, see the "Blocking on expectations"
section in the module documentation.

When `expect/4` is invoked, any previously declared `stub` for the same `name` and arity will
be removed. This ensures that `expect` will fail if the function is called more than `n` times.
If a `stub/3` is invoked **after** `expect/4` for the same `name` and arity, the stub will be
used after all expectations are fulfilled.

## Examples

To expect `MockWeatherAPI.get_temp/1` to be called once:

    expect(MockWeatherAPI, :get_temp, fn _ -> {:ok, 30} end)

To expect `MockWeatherAPI.get_temp/1` to be called five times:

    expect(MockWeatherAPI, :get_temp, 5, fn _ -> {:ok, 30} end)

To expect `MockWeatherAPI.get_temp/1` not to be called (see also `deny/3`):

    expect(MockWeatherAPI, :get_temp, 0, fn _ -> {:ok, 30} end)

`expect/4` can also be invoked multiple times for the same name/arity,
allowing you to give different behaviours on each invocation. For instance,
you could test that your code will try an API call three times before giving
up:

    MockWeatherAPI
    |> expect(:get_temp, 2, fn _loc -> {:error, :unreachable} end)
    |> expect(:get_temp, 1, fn _loc -> {:ok, 30} end)

    log = capture_log(fn ->
      assert Weather.current_temp(location)
        == "It's currently 30 degrees"
    end)

    assert log =~ "attempt 1 failed"
    assert log =~ "attempt 2 failed"
    assert log =~ "attempt 3 succeeded"

    MockWeatherAPI
    |> expect(:get_temp, 3, fn _loc -> {:error, :unreachable} end)

    assert Weather.current_temp(location) == "Current temperature is unavailable"

## deny/3

Ensures that `name`/`arity` in `mock` is not invoked.

When `deny/3` is invoked, any previously declared `stub` for the same `name` and arity will
be removed. This ensures that `deny` will fail if the function is called. If a `stub/3` is
invoked **after** `deny/3` for the same `name` and `arity`, the stub will be used instead, so
`deny` will have no effect.

## Examples

To expect `MockWeatherAPI.get_temp/1` to never be called:

    deny(MockWeatherAPI, :get_temp, 1)

## stub/3

Allows the `name` in `mock` with arity given by `code` to
be invoked zero or many times.

Unlike expectations, stubs are never verified.

If expectations and stubs are defined for the same function
and arity, the stub is invoked only after all expectations are
fulfilled.

## Examples

To allow `MockWeatherAPI.get_temp/1` to be called any number of times:

    stub(MockWeatherAPI, :get_temp, fn _loc -> {:ok, 30} end)

`stub/3` will overwrite any previous calls to `stub/3`.

## stub_with/2

Stubs all functions described by the shared behaviours in the `mock` and `module`.

## Examples

    defmodule MyApp.WeatherAPI do
      @callback temp(MyApp.LatLong.t()) :: {:ok, integer()}
      @callback humidity(MyApp.LatLong.t()) :: {:ok, integer()}
    end

    defmodule MyApp.StubWeatherAPI do
      @behaviour MyApp.WeatherAPI
      def temp(_loc), do: {:ok, 30}
      def humidity(_loc), do: {:ok, 60}
    end

    defmock(MyApp.MockWeatherAPI, for: MyApp.WeatherAPI)

    setup do
      stub_with(MyApp.MockWeatherAPI, MyApp.StubWeatherAPI)
      :ok
    end

This is the same as calling `stub/3` for each callback in `MyApp.MockWeatherAPI`:

    stub(MyApp.MockWeatherAPI, :temp, &MyApp.StubWeatherAPI.temp/1)
    stub(MyApp.MockWeatherAPI, :humidity, &MyApp.StubWeatherAPI.humidity/1)

## allow/3

Allows other processes to share expectations and stubs
defined by owner process.

## Examples

To allow `child_pid` to call any stubs or expectations defined for `MyMock`:

    allow(MyMock, self(), child_pid)

`allow/3` also accepts named process or via references:

    allow(MyMock, self(), SomeChildProcess)

If the process is not yet started at the moment of allowance definition,
it might be allowed as a function, assuming at the moment of invocation
it would have been started. If the function cannot be resolved to a `pid`
during invocation, the expectation will not succeed.

    allow(MyMock, self(), fn -> GenServer.whereis(Deferred) end)

## verify_on_exit!/1

Verifies the current process after it exits.

If you want to verify expectations for all tests, you can use
`verify_on_exit!/1` as a setup callback:

    setup :verify_on_exit!

## verify!/0

Verifies that all expectations set by the current process
have been called.

## verify!/1

Verifies that all expectations in `mock` have been called.