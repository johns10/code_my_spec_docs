# Tesla.Middleware.PathParams

Use templated URLs with provided parameters in either Phoenix style (`:id`)
or OpenAPI style (`{id}`).

Useful when logging or reporting metrics per URL.

## Parameter Values

Parameter values may be `t:struct/0` or must implement the `Enumerable`
protocol and produce `{key, value}` tuples when enumerated.

## Parameter Name Restrictions

Phoenix style parameters may contain letters, numbers, or underscores,
matching this regular expression:

  :[a-zA-Z][_a-zA-Z0-9]*

OpenAPI style parameters may contain letters, numbers, underscores, or
hyphens (`-`), matching this regular expression:

  {[a-zA-Z][-_a-zA-Z0-9]*}

In either case, parameters that begin with underscores (`_`), hyphens (`-`),
or numbers (`0-9`) are ignored and left as-is.

## Examples

```elixir
defmodule MyClient do
  def client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://api.example.com"},
      Tesla.Middleware.Logger,
      Tesla.Middleware.PathParams
    ])
  end

  def user(client, id) do
    params = [id: id]
    Tesla.get(client, "/users/{id}", opts: [path_params: params])
  end

  def posts(client, id, post_id) do
    params = [id: id, post_id: post_id]
    Tesla.get(client, "/users/:id/posts/:post_id", opts: [path_params: params])
  end
end
```