# Tesla.Middleware.BaseUrl

Set base URL for all requests.

The base URL will be prepended to request path/URL only
if it does not include http(s).

## Examples

```elixir
defmodule MyClient do
  def client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://example.com/foo"}
    ])
  end
end

client = MyClient.client()

Tesla.get(client, "/path")
# equals to GET https://example.com/foo/path

Tesla.get(client, "path")
# equals to GET https://example.com/foo/path

Tesla.get(client, "")
# equals to GET https://example.com/foo

Tesla.get(client, "http://example.com/bar")
# equals to GET http://example.com/bar
```