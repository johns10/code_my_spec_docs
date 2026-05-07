# Tesla.Client



## adapter(client)

Returns the client's adapter in the same form it was provided.
This can be used to copy an adapter from one client to another.

## Examples

    iex> client = Tesla.client([], {Tesla.Adapter.Hackney, [recv_timeout: 30_000]})
    iex> Tesla.Client.adapter(client)
    {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

## middleware(client)

Returns the client's middleware in the same form it was provided.
This can be used to copy middleware from one client to another.

## Examples

    iex> middleware = [Tesla.Middleware.JSON, {Tesla.Middleware.BaseUrl, "https://api.github.com"}]
    iex> client = Tesla.client(middleware)
    iex> Tesla.Client.middleware(client)
    [Tesla.Middleware.JSON, {Tesla.Middleware.BaseUrl, "https://api.github.com"}]