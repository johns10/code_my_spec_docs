# Mox

Mox is a library for defining concurrent mocks in Elixir.

The library follows the principles outlined in
["Mocks and explicit contracts"](https://dashbit.co/blog/mocks-and-explicit-contracts),
summarized below:

  1. No ad-hoc mocks. You can only create mocks based on behaviours

  2. No dynamic generation of modules during tests. Mocks are preferably defined
     in your `test_helper.exs` or in a `setup_all` block and not per test

  3. Concurrency support. Tests using the same mock can still use `async: true`

  4. Rely on pattern matching and function clauses for asserting on the
     input instead of complex expectation rules

## Example

Imagine that you have an app that has to display the weather. At first,
you use an external API to give you the data given a lat/long pair:

    defmodule MyApp.HumanizedWeather do
      def display_temp({lat, long}) do
        {:ok, temp} = MyApp.WeatherAPI.temp({lat, long})
        "Current temperature is #{temp} degrees"
      end

      def display_humidity({lat, long}) do
        {:ok, humidity} = MyApp.WeatherAPI.humidity({lat, long})
        "Current humidity is #{humidity}%"
      end
    end

However, you want to test the code above without performing external
API calls. How to do so?

First, it is important to define the `WeatherAPI` behaviour that we want
to mock. And we will define a proxy function that will dispatch to
the desired implementation:

    defmodule MyApp.WeatherAPI do
      @callback temp(MyApp.LatLong.t()) :: {:ok, integer()}
      @callback humidity(MyApp.LatLong.t()) :: {:ok, integer()}

      def temp(lat_long), do: impl().temp(lat_long)
      def humidity(lat_long), do: impl().humidity(lat_long)
      defp impl, do: Application.get_env(:my_app, :weather, MyApp.ExternalWeatherAPI)
    end

By default, we will dispatch to MyApp.ExternalWeatherAPI, which now contains
the external API implementation.

If you want to mock the WeatherAPI behaviour during tests, the first step
is to define the mock with `defmock/2`, usually in your `test_helper.exs`,
and configure your application to use it:

    Mox.defmock(MyApp.MockWeatherAPI, for: MyApp.WeatherAPI)
    Application.put_env(:my_app, :weather, MyApp.MockWeatherAPI)

Now in your tests, you can define expectations with `expect/4` and verify
them via `verify_on_exit!/1`:

    defmodule MyApp.HumanizedWeatherTest do
      use ExUnit.Case, async: true

      import Mox

      # Make sure mocks are verified when the test exits
      setup :verify_on_exit!

      test "gets and formats temperature and humidity" do
        MyApp.MockWeatherAPI
        |> expect(:temp, fn {_lat, _long} -> {:ok, 30} end)
        |> expect(:humidity, fn {_lat, _long} -> {:ok, 60} end)

        assert MyApp.HumanizedWeather.display_temp({50.06, 19.94}) ==
                 "Current temperature is 30 degrees"

        assert MyApp.HumanizedWeather.display_humidity({50.06, 19.94}) ==
                 "Current humidity is 60%"
      end
    end

All expectations are defined based on the current process. This
means multiple tests using the same mock can still run concurrently
unless the Mox is set to global mode. See the "Multi-process collaboration"
section.

One last note, if the mock is used throughout the test suite, you might want
the implementation to fall back to a stub (or actual) implementation when no
expectations are defined. You can use `stub_with/2` in a case template that
is used throughout your test suite:

    defmodule MyApp.Case do
      use ExUnit.CaseTemplate

      setup _ do
        Mox.stub_with(MyApp.MockWeatherAPI, MyApp.StubWeatherAPI)
        :ok
      end
    end

Now, for every test case that uses `ExUnit.Case`, it can use `MyApp.Case`
instead. Then, if no expectations are defined it will call the implementation
in `MyApp.StubWeatherAPI`.

## Multiple behaviours

Mox supports defining mocks for multiple behaviours.

Suppose your library also defines a behaviour for getting past weather:

    defmodule MyApp.PastWeather do
      @callback past_temp(MyApp.LatLong.t(), DateTime.t()) :: {:ok, integer()}
    end

You can mock both the weather and past weather behaviour:

    Mox.defmock(MyApp.MockWeatherAPI, for: [MyApp.Weather, MyApp.PastWeather])

## Compile-time requirements

If the mock needs to be available during the project compilation, for
instance because you get undefined function warnings, then instead of
defining the mock in your `test_helper.exs`, you should instead define
it under `test/support/mocks.ex`:

    Mox.defmock(MyApp.MockWeatherAPI, for: MyApp.WeatherAPI)

Then you need to make sure that files in `test/support` get compiled
with the rest of the project. Edit your `mix.exs` file to add the
`test/support` directory to compilation paths:

    def project do
      [
        ...
        elixirc_paths: elixirc_paths(Mix.env),
        ...
      ]
    end

    defp elixirc_paths(:test), do: ["test/support", "lib"]
    defp elixirc_paths(_),     do: ["lib"]

## Multi-process collaboration

Mox supports multi-process collaboration via two mechanisms:

  1. explicit allowances
  2. global mode

The allowance mechanism can still run tests concurrently while
the global one doesn't. We explore both next.

### Explicit allowances

An allowance permits a child process to use the expectations and stubs
defined in the parent process while still being safe for async tests.

    test "invokes add and mult from a task" do
      MyApp.MockWeatherAPI
      |> expect(:temp, fn _loc -> {:ok, 30} end)
      |> expect(:humidity, fn _loc -> {:ok, 60} end)

      parent_pid = self()

      Task.async(fn ->
        MyApp.MockWeatherAPI |> allow(parent_pid, self())

        assert MyApp.HumanizedWeather.display_temp({50.06, 19.94}) ==
                 "Current temperature is 30 degrees"

        assert MyApp.HumanizedWeather.display_humidity({50.06, 19.94}) ==
                 "Current humidity is 60%"
      end)
      |> Task.await
    end

Note: if you're running on Elixir 1.8.0 or greater and your concurrency comes
from a `Task` then you don't need to add explicit allowances. Instead
`$callers` is used to determine the process that actually defined the
expectations.

#### Explicit allowances as lazy/deferred functions

Under some circumstances, the process might not have been already started
when the allowance happens. In such a case, you might specify the allowance
as a function in the form `(-> pid())`. This function would be resolved late,
at the very moment of dispatch. If the function does not return an existing
PID, Mox will raise a `Mox.UnexpectedCallError` exception.

### Global mode

Mox supports global mode, where any process can consume mocks and stubs
defined in your tests. `set_mox_from_context/0` automatically calls
`set_mox_global/1` but only if the test context **doesn't** include
`async: true`.

By default the mode is `:private`.

    setup :set_mox_from_context
    setup :verify_on_exit!

    test "invokes add and mult from a task" do
      MyApp.MockWeatherAPI
      |> expect(:temp, fn _loc -> {:ok, 30} end)
      |> expect(:humidity, fn _loc -> {:ok, 60} end)

      Task.async(fn ->
        assert MyApp.HumanizedWeather.display_temp({50.06, 19.94}) ==
                  "Current temperature is 30 degrees"

        assert MyApp.HumanizedWeather.display_humidity({50.06, 19.94}) ==
                  "Current humidity is 60%"
      end)
      |> Task.await
    end

### Blocking on expectations

If your mock is called in a different process than the test process,
in some cases there is a chance that the test will finish executing
before it has a chance to call the mock and meet the expectations.
Imagine this:

    test "calling a mock from a different process" do
      expect(MyApp.MockWeatherAPI, :temp, fn _loc -> {:ok, 30} end)

      spawn(fn -> MyApp.HumanizedWeather.temp({50.06, 19.94}) end)

      verify!()
    end

The test above has a race condition because there is a chance that the
`verify!/0` call will happen before the spawned process calls the mock.
In most cases, you don't control the spawning of the process so you can't
simply monitor the process to know when it dies in order to avoid this
race condition. In those cases, the way to go is to "sync up" with the
process that calls the mock by sending a message to the test process
from the expectation and using that to know when the expectation has been
called.

    test "calling a mock from a different process" do
      parent = self()
      ref = make_ref()

      expect(MyApp.MockWeatherAPI, :temp, fn _loc ->
        send(parent, {ref, :temp})
        {:ok, 30}
      end)

      spawn(fn -> MyApp.HumanizedWeather.temp({50.06, 19.94}) end)

      assert_receive {^ref, :temp}

      verify!()
    end

This way, we'll wait until the expectation is called before calling
`verify!/0`.

## allow(mock, owner_pid, allowed_via)

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

## defmock(name, options)

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

## deny(mock, name, arity)

Ensures that `name`/`arity` in `mock` is not invoked.

When `deny/3` is invoked, any previously declared `stub` for the same `name` and arity will
be removed. This ensures that `deny` will fail if the function is called. If a `stub/3` is
invoked **after** `deny/3` for the same `name` and `arity`, the stub will be used instead, so
`deny` will have no effect.

## Examples

To expect `MockWeatherAPI.get_temp/1` to never be called:

    deny(MockWeatherAPI, :get_temp, 1)

## expect(mock, name, n \\ 1, code)

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

## set_mox_from_context(context)

Chooses the Mox mode based on context.

When `async: true` is used, `set_mox_private/1` is called,
otherwise `set_mox_global/1` is used.

## Examples

    setup :set_mox_from_context

## set_mox_global(context \\ %{})

Sets the Mox to global mode.

In global mode, mocks can be consumed by any process.

An ExUnit case where tests use Mox in global mode cannot be
`async: true`.

## Examples

    setup :set_mox_global

## set_mox_private(context \\ %{})

Sets the Mox to private mode.

In private mode, mocks can be set and consumed by the same
process unless other processes are explicitly allowed.

## Examples

    setup :set_mox_private

## stub(mock, name, code)

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

## stub_with(mock, module)

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

## verify!()

Verifies that all expectations set by the current process
have been called.

## verify!(mock)

Verifies that all expectations in `mock` have been called.

## verify_on_exit!(context \\ %{})

Verifies the current process after it exits.

If you want to verify expectations for all tests, you can use
`verify_on_exit!/1` as a setup callback:

    setup :verify_on_exit!

## t/0

A mock module.

This type is available since version 1.1+ of Mox.