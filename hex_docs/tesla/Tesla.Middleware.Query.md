# Tesla.Middleware.Query

Set default query params for all requests

## Examples

```elixir
defmodule MyClient do
  def client do
    Tesla.client([
      {Tesla.Middleware.Query, [token: "some-token"]}
    ])
  end
end
```