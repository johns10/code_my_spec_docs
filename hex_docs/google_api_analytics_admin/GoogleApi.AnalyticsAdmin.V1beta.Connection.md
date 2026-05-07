# GoogleApi.AnalyticsAdmin.V1beta.Connection

Handle Tesla connections for GoogleApi.AnalyticsAdmin.V1beta.

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

## execute(connection, request)

Execute a request on this connection

## Returns

*   `{:ok, Tesla.Env.t}` - If the call was successful
*   `{:error, reason}` - If the call failed

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

## new()

Configure an authless client connection

## Returns

*   `Tesla.Env.client`

## new(token)

Configure a client connection using a function which yields a Bearer token.

## Parameters

*   `token_fetcher` (*type:* `list(String.t()) -> String.t()`) - Callback
    which provides an OAuth2 token given a list of scopes

## Returns

*   `Tesla.Env.client`

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