# Tesla

A HTTP toolkit for building API clients using middlewares.

## Building API client

Use `Tesla.client/2` to build a client with the given middleware and adapter.

### Examples

```elixir
defmodule ExampleApi do
  def client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "http://api.example.com"},
      Tesla.Middleware.JSON
    ])
  end

  def fetch_data(client) do
    Tesla.get(client, "/data")
  end
end
```

Now you can use `ExampleApi.client/0` to make requests to the API.

```elixir
client = ExampleApi.client()
ExampleApi.fetch_data(client)
```

## Direct usage

It is also possible to do request directly with `Tesla` module.

```elixir
Tesla.get("https://example.com")
```

## Default adapter

By default `Tesla` is using `Tesla.Adapter.Httpc`, because `:httpc` is
included in Erlang/OTP and does not require installation of any additional
dependency. It can be changed globally with config:

```elixir
config :tesla, :adapter, Tesla.Adapter.Mint
```

## build_url(env)

Builds a URL from the given `t:Tesla.Env.t/0` struct.

Combines the `url` and `query` fields, and allows specifying the `encoding`
strategy before calling `build_url/3`.

## build_url(url, query, encoding \\ :www_form)

Builds URL with the given URL and query params.

Useful when you need to create a URL with dynamic query params from a Keyword
list

Allows to specify the `encoding` strategy to be one either `:www_form` or
`:rfc3986`. Read more about encoding at `URI.encode_query/2`.

- `url` - the base URL to which the query params will be appended.
- `query` - a list of key-value pairs to be encoded as query params.
- `encoding` - the encoding strategy to use. Defaults to `:www_form`

## Examples

    iex> Tesla.build_url("https://api.example.com", [user: 3, page: 2])
    "https://api.example.com?user=3&page=2"

URL that already contains query params:

    iex> url = "https://api.example.com?user=3"
    iex> Tesla.build_url(url, [page: 2, status: true])
    "https://api.example.com?user=3&page=2&status=true"

Default encoding `:www_form`:

    iex> Tesla.build_url("https://api.example.com", [user_name: "John Smith"])
    "https://api.example.com?user_name=John+Smith"

Specified encoding strategy `:rfc3986`:

    iex> Tesla.build_url("https://api.example.com", [user_name: "John Smith"], :rfc3986)
    "https://api.example.com?user_name=John%20Smith"

## client(middleware, adapter \\ nil)

Dynamically build client from list of middlewares and/or adapter.

```
# add dynamic middleware
client = Tesla.client([{Tesla.Middleware.Headers, [{"authorization", token}]}])
Tesla.get(client, "/path")

# configure adapter in runtime
client = Tesla.client([], Tesla.Adapter.Hackney)
client = Tesla.client([], {Tesla.Adapter.Hackney, pool: :my_pool})
Tesla.get(client, "/path")

# complete module example
defmodule MyApi do
  @middleware [
    {Tesla.Middleware.BaseUrl, "https://example.com"},
    Tesla.Middleware.JSON,
    Tesla.Middleware.Logger
  ]

  @adapter Tesla.Adapter.Hackney

  def new(opts) do
    # do any middleware manipulation you need
    middleware = [
      {Tesla.Middleware.BasicAuth, username: opts[:username], password: opts[:password]}
    ] ++ @middleware

    # allow configuring adapter in runtime
    adapter = opts[:adapter] || @adapter

    # use Tesla.client/2 to put it all together
    Tesla.client(middleware, adapter)
  end

  def get_something(client, id) do
    # pass client directly to Tesla.get/2
    Tesla.get(client, "/something/#{id}")
    # ...
  end
end

client = MyApi.new(username: "admin", password: "secret")
MyApi.get_something(client, 42)
```

## delete(client, url, opts)

Perform a DELETE request.

See `request/1` or `request/2` for options definition.

    delete("/users")
    delete("/users", query: [scope: "admin"])
    delete(client, "/users")
    delete(client, "/users", query: [scope: "admin"])
    delete(client, "/users", body: %{name: "Jon"})

## delete!(client, url, opts)

Perform a DELETE request.

See `request!/1` or `request!/2` for options definition.

    delete!("/users")
    delete!("/users", query: [scope: "admin"])
    delete!(client, "/users")
    delete!(client, "/users", query: [scope: "admin"])
    delete!(client, "/users", body: %{name: "Jon"})

## get(client, url, opts)

Perform a GET request.

See `request/1` or `request/2` for options definition.

    get("/users")
    get("/users", query: [scope: "admin"])
    get(client, "/users")
    get(client, "/users", query: [scope: "admin"])
    get(client, "/users", body: %{name: "Jon"})

## get!(client, url, opts)

Perform a GET request.

See `request!/1` or `request!/2` for options definition.

    get!("/users")
    get!("/users", query: [scope: "admin"])
    get!(client, "/users")
    get!(client, "/users", query: [scope: "admin"])
    get!(client, "/users", body: %{name: "Jon"})

## get_header(env, key)

Returns value of header specified by `key` from `:headers` field in `Tesla.Env`.

## Examples

    # non existing header
    iex> env = %Tesla.Env{headers: [{"server", "Cowboy"}]}
    iex> Tesla.get_header(env, "some-key")
    nil

    # existing header
    iex> env = %Tesla.Env{headers: [{"server", "Cowboy"}]}
    iex> Tesla.get_header(env, "server")
    "Cowboy"

    # first of multiple headers with the same name
    iex> env = %Tesla.Env{headers: [{"cookie", "chocolate"}, {"cookie", "biscuits"}]}
    iex> Tesla.get_header(env, "cookie")
    "chocolate"

## head(client, url, opts)

Perform a HEAD request.

See `request/1` or `request/2` for options definition.

    head("/users")
    head("/users", query: [scope: "admin"])
    head(client, "/users")
    head(client, "/users", query: [scope: "admin"])
    head(client, "/users", body: %{name: "Jon"})

## head!(client, url, opts)

Perform a HEAD request.

See `request!/1` or `request!/2` for options definition.

    head!("/users")
    head!("/users", query: [scope: "admin"])
    head!(client, "/users")
    head!(client, "/users", query: [scope: "admin"])
    head!(client, "/users", body: %{name: "Jon"})

## options(client, url, opts)

Perform a OPTIONS request.

See `request/1` or `request/2` for options definition.

    options("/users")
    options("/users", query: [scope: "admin"])
    options(client, "/users")
    options(client, "/users", query: [scope: "admin"])
    options(client, "/users", body: %{name: "Jon"})

## options!(client, url, opts)

Perform a OPTIONS request.

See `request!/1` or `request!/2` for options definition.

    options!("/users")
    options!("/users", query: [scope: "admin"])
    options!(client, "/users")
    options!(client, "/users", query: [scope: "admin"])
    options!(client, "/users", body: %{name: "Jon"})

## patch(client, url, body, opts)

Perform a PATCH request.

See `request/1` or `request/2` for options definition.

    patch("/users", %{name: "Jon"})
    patch("/users", %{name: "Jon"}, query: [scope: "admin"])
    patch(client, "/users", %{name: "Jon"})
    patch(client, "/users", %{name: "Jon"}, query: [scope: "admin"])

## patch!(client, url, body, opts)

Perform a PATCH request.

See `request!/1` or `request!/2` for options definition.

    patch!("/users", %{name: "Jon"})
    patch!("/users", %{name: "Jon"}, query: [scope: "admin"])
    patch!(client, "/users", %{name: "Jon"})
    patch!(client, "/users", %{name: "Jon"}, query: [scope: "admin"])

## post(client, url, body, opts)

Perform a POST request.

See `request/1` or `request/2` for options definition.

    post("/users", %{name: "Jon"})
    post("/users", %{name: "Jon"}, query: [scope: "admin"])
    post(client, "/users", %{name: "Jon"})
    post(client, "/users", %{name: "Jon"}, query: [scope: "admin"])

## post!(client, url, body, opts)

Perform a POST request.

See `request!/1` or `request!/2` for options definition.

    post!("/users", %{name: "Jon"})
    post!("/users", %{name: "Jon"}, query: [scope: "admin"])
    post!(client, "/users", %{name: "Jon"})
    post!(client, "/users", %{name: "Jon"}, query: [scope: "admin"])

## put(client, url, body, opts)

Perform a PUT request.

See `request/1` or `request/2` for options definition.

    put("/users", %{name: "Jon"})
    put("/users", %{name: "Jon"}, query: [scope: "admin"])
    put(client, "/users", %{name: "Jon"})
    put(client, "/users", %{name: "Jon"}, query: [scope: "admin"])

## put!(client, url, body, opts)

Perform a PUT request.

See `request!/1` or `request!/2` for options definition.

    put!("/users", %{name: "Jon"})
    put!("/users", %{name: "Jon"}, query: [scope: "admin"])
    put!(client, "/users", %{name: "Jon"})
    put!(client, "/users", %{name: "Jon"}, query: [scope: "admin"])

## put_opt(env, key, value)

Adds given key/value pair to `:opts` field in `Tesla.Env`.

Useful when there's a need to store additional middleware data in `Tesla.Env`

## Examples

    iex> %Tesla.Env{opts: []} |> Tesla.put_opt(:option, "value")
    %Tesla.Env{opts: [option: "value"]}

## request(client \\ %Tesla.Client{}, options)

Perform a request.

## Options

- `:method` - the request method, one of [`:head`, `:get`, `:delete`, `:trace`, `:options`, `:post`, `:put`, `:patch`]
- `:url` - either full url e.g. "http://example.com/some/path" or just "/some/path" if using `Tesla.Middleware.BaseUrl`
- `:query` - a keyword list of query params, e.g. `[page: 1, per_page: 100]`
- `:headers` - a keyword list of headers, e.g. `[{"content-type", "text/plain"}]`
- `:body` - depends on used middleware:
    - by default it can be a binary
    - if using e.g. JSON encoding middleware it can be a nested map
    - if adapter supports it it can be a Stream with any of the above
- `:opts` - custom, per-request middleware or adapter options

## Examples

    ExampleApi.request(method: :get, url: "/users/path")

    # use shortcut methods
    ExampleApi.get("/users/1")
    ExampleApi.post(client, "/users", %{name: "Jon"})

## request!(client \\ %Tesla.Client{}, options)

Perform request and raise in case of error.

This is similar to `request/2` behaviour from Tesla 0.x

See `request/2` for list of available options.

## trace(client, url, opts)

Perform a TRACE request.

See `request/1` or `request/2` for options definition.

    trace("/users")
    trace("/users", query: [scope: "admin"])
    trace(client, "/users")
    trace(client, "/users", query: [scope: "admin"])
    trace(client, "/users", body: %{name: "Jon"})

## trace!(client, url, opts)

Perform a TRACE request.

See `request!/1` or `request!/2` for options definition.

    trace!("/users")
    trace!("/users", query: [scope: "admin"])
    trace!(client, "/users")
    trace!(client, "/users", query: [scope: "admin"])
    trace!(client, "/users", body: %{name: "Jon"})

## option/0

Options that may be passed to a request function. See `request/2` for detailed descriptions.