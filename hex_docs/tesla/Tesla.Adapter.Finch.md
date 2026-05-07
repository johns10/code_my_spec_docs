# Tesla.Adapter.Finch

Adapter for [finch](https://github.com/sneako/finch).

Remember to add `{:finch, "~> 0.14.0"}` to dependencies. Also, you need to
recompile tesla after adding the `:finch` dependency:

```shell
mix deps.clean tesla
mix compile
```

## Examples

In order to use Finch, you must start it and provide a `:name`. For example,
in your supervision tree:

```elixir
children = [
  {Finch, name: MyFinch}
]
```

You must provide the same name to this adapter:

```elixir
# set globally in config/config.exs
config :tesla, :adapter, {Tesla.Adapter.Finch, name: MyFinch}

# set per module
defmodule MyClient do
  def client do
    Tesla.client([], {Tesla.Adapter.Finch, name: MyFinch})
  end
end
```

## Adapter specific options

  * `:name` - The `:name` provided to Finch (**required**).

## [Finch options](https://hexdocs.pm/finch/Finch.html#request/3)

  * `:pool_timeout` - This timeout is applied when a connection is checked
    out from the pool. Default value is `5_000`.

  * `:receive_timeout` - The maximum time to wait for a response before
    returning an error. Default value is `15_000`.