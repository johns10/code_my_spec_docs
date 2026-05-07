# Tesla.Middleware.FormUrlencoded

Send request body as `application/x-www-form-urlencoded`.

Performs encoding of `body` from a `Map` such as `%{"foo" => "bar"}` into
URL-encoded data.

Performs decoding of the response into a map when urlencoded and content-type
is `application/x-www-form-urlencoded`, so `"foo=bar"` becomes
`%{"foo" => "bar"}`.

## Examples

```elixir
defmodule Myclient do
  def client do
    Tesla.client([
      {Tesla.Middleware.FormUrlencoded,
        encode: &Plug.Conn.Query.encode/1,
        decode: &Plug.Conn.Query.decode/1}
    ])
  end
end

client = Myclient.client()
Myclient.post(client, "/url", %{key: :value})
```

## Options

- `:decode` - decoding function, defaults to `URI.decode_query/1`
- `:encode` - encoding function, defaults to `URI.encode_query/1`

## Nested Maps

Natively, nested maps are not supported in the body, so
`%{"foo" => %{"bar" => "baz"}}` won't be encoded and raise an error.
Support for this specific case is obtained by configuring the middleware to
encode (and decode) with `Plug.Conn.Query`

```elixir
defmodule Myclient do
  def client do
    Tesla.client([
      {Tesla.Middleware.FormUrlencoded,
        encode: &Plug.Conn.Query.encode/1,
        decode: &Plug.Conn.Query.decode/1}
    ])
  end
end

client = Myclient.client()
Myclient.post(client, "/url", %{key: %{nested: "value"}})
```

## decode(env, opts)

Decode response body as querystring.

It is used by `Tesla.Middleware.DecodeFormUrlencoded`.

## encode(env, opts)

Encode response body as querystring.

It is used by `Tesla.Middleware.EncodeFormUrlencoded`.