# Tesla.Middleware.Logger

Log requests using Elixir's Logger.

With the default settings it logs request method, URL, response status, and
time taken in milliseconds.

## Examples

```elixir
defmodule MyClient do
  def client do
    Tesla.client([Tesla.Middleware.Logger])
  end
end
```

## Options

- `:level` - custom function for calculating log level or atom for fixed level (see below)
- `:log_level` - (deprecated) custom function for calculating log level (see below)
- `:filter_headers` - sanitizes sensitive headers before logging in debug mode (see below)
- `:debug` - use `Logger.debug/2` to log request/response details
- `:format` - custom string template or function for log message (see below)

## Custom log format

The default log format is `"$method $url -> $status ($time ms)"`
which shows in logs like:

```elixir
2018-03-25 18:32:40.397 [info]  GET https://bitebot.io -> 200 (88.074 ms)
```

It can be changed globally with config:

```elixir
config :tesla, Tesla.Middleware.Logger, format: "$method $url ====> $status / time=$time"
```

Or you can customize this setting by providing your own `format` function:

```elixir
defmodule MyClient do
  def client do
    Tesla.client([
      {Tesla.Middleware.Logger, format: &my_format/3}
    ])
  end

  def my_format(request, response, time) do
    "request=#{inspect(request)} response=#{inspect(response)} time=#{time}\n"
  end
end
```

## Custom log levels

By default, the following log levels will be used:

- `:error` - for errors, 5xx and 4xx responses
- `:warn` or `:warning` - for 3xx responses
- `:info` - for 2xx responses

You can customize this setting by providing your own level function that accepts
both success and error cases:

```elixir
defmodule MyClient do
  def client do
    Tesla.client([
      {Tesla.Middleware.Logger, level: &my_level/1}
    ])
  end

  def my_level({:ok, env}) do
    case env.status do
      404 -> :info
      _ -> :default
    end
  end

  def my_level({:error, _reason}) do
    :error
  end
end
```

Or provide a fixed log level:

```elixir
defmodule MyClient do
  def client do
    Tesla.client([
      {Tesla.Middleware.Logger, level: :debug}
    ])
  end
end
```

You can also use the deprecated `log_level` option (will show a deprecation warning):

```elixir
defmodule MyClient do
  def client do
    Tesla.client([
      {Tesla.Middleware.Logger, log_level: &my_log_level/1}
    ])
  end

  def my_log_level(env) do
    case env.status do
      404 -> :info
      _ -> :default
    end
  end
end
```

To disable the deprecation warning for `:log_level`, add this to your config:

```elixir
# config/config.exs
config :tesla, disable_log_level_warning: true
```

## Logger Debug output

`Tesla` will use `Logger.debug/2` to log request & response details using
the `:debug` option. It will require to set the `Logger` log level to `:debug`
in your configuration, example:

```elixir
# config/dev.exs
config :logger, level: :debug
```

If you want to disable detailed request/response logging but keep the
`:debug` log level (i.e. in development) you can set `debug: false` in your
config:

```elixir
# config/dev.local.exs
config :tesla, Tesla.Middleware.Logger, debug: false
```

Note that the logging configuration is evaluated at compile time,
so Tesla must be recompiled for the configuration to take effect:

```shell
mix deps.clean --build tesla
mix deps.compile tesla
```

In order to be able to set `:debug` at runtime we can
pass it as a option to the middleware at runtime.

```elixir
def client do
  middleware = [
    # ...
    {Tesla.Middleware.Logger, debug: false}
  ]

  Tesla.client(middleware)
end
```

### Filter headers

To sanitize sensitive headers such as `authorization` in
debug logs, add them to the `:filter_headers` option.
`:filter_headers` expects a list of header names as strings.

```elixir
# config/dev.local.exs
config :tesla, Tesla.Middleware.Logger,
  filter_headers: ["authorization"]
```