# Tesla.Middleware.Compression

Compress requests and decompress responses.

Supports "gzip" and "deflate" encodings using Erlang's built-in `:zlib` module.

## Examples

```elixir
defmodule MyClient do
  def client do
    Tesla.client([
      {Tesla.Middleware.Compression, format: "gzip"}
    ])
  end
end
```

## Options

- `:format` - request compression format, `"gzip"` (default) or `"deflate"`

## compress/2

Compress request.

It is used by `Tesla.Middleware.CompressRequest`.

## decompress/1

Decompress response.

It is used by `Tesla.Middleware.DecompressResponse`.