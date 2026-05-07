# OAuth2.Client

This module defines the `OAuth2.Client` struct and is responsible for building
and establishing a request for an access token.

### Notes

* If a full url is given (e.g. "http://www.example.com/api/resource") then it
will use that otherwise you can specify an endpoint (e.g. "/api/resource") and
it will append it to the `Client.site`.

* The headers from the `Client.headers` are appended to the request headers.

### Examples

    client = OAuth2.Client.new(token: "abc123")

    case OAuth2.Client.get(client, "/some/resource") do
      {:ok, %OAuth2.Response{body: body}} ->
        "Yay!!"
      {:error, %OAuth2.Response{body: body}} ->
        "Something bad happen: #{inspect body}"
      {:error, %OAuth2.Error{reason: reason}} ->
        reason
    end

    response = OAuth2.Client.get!(client, "/some/resource")

    response = OAuth2.Client.post!(client, "/some/other/resources", %{foo: "bar"})

## authorize_url!(client, params \\ [])

Returns the authorize url based on the client configuration.

## Example

    iex> OAuth2.Client.authorize_url!(%OAuth2.Client{})
    "/oauth/authorize?client_id=&redirect_uri=&response_type=code"

## basic_auth(client)

Adds `authorization` header for basic auth.

## delete(client, url, body \\ "", headers \\ [], opts \\ [])

Makes a `DELETE` request to the given URL using the `OAuth2.AccessToken`.

## delete!(client, url, body \\ "", headers \\ [], opts \\ [])

Same as `delete/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception
if the request results in an error.

An `OAuth2.Error` exception is raised if the request results in an
error tuple (`{:error, reason}`).

## delete_serializer(client, mime)

Un-register a serialization module for a given mime type.

## Example

    iex> client = OAuth2.Client.delete_serializer(%OAuth2.Client{}, "application/json")
    %OAuth2.Client{}
    iex> OAuth2.Client.get_serializer(client, "application/json")
    nil

## get(client, url, headers \\ [], opts \\ [])

Makes a `GET` request to the given `url` using the `OAuth2.AccessToken`
struct.

## get!(client, url, headers \\ [], opts \\ [])

Same as `get/4` but returns a `OAuth2.Response` or `OAuth2.Error` exception if
the request results in an error.

## get_token(client, params \\ [], headers \\ [], opts \\ [])

Fetches an `OAuth2.AccessToken` struct by making a request to the token endpoint.

Returns the `OAuth2.Client` struct loaded with the access token which can then
be used to make authenticated requests to an OAuth2 provider's API.

## Arguments

* `client` - a `OAuth2.Client` struct with the strategy to use, defaults to
  `OAuth2.Strategy.AuthCode`
* `params` - a keyword list of request parameters which will be encoded into
  a query string or request body depending on the selected strategy
* `headers` - a list of request headers
* `opts` - a Keyword list of request options which will be merged with
  `OAuth2.Client.request_opts`

## Options

* `:recv_timeout` - the timeout (in milliseconds) of the request
* `:proxy` - a proxy to be used for the request; it can be a regular url or a
  `{host, proxy}` tuple

## get_token!(client, params \\ [], headers \\ [], opts \\ [])

Same as `get_token/4` but raises `OAuth2.Error` if an error occurs during the
request.

## merge_params(client, params)

Set multiple params in the client in one call.

## new(client \\ %Client{}, opts)

Builds a new `OAuth2.Client` struct using the `opts` provided.

## Client struct fields

* `authorize_url` - absolute or relative URL path to the authorization
  endpoint. Defaults to `"/oauth/authorize"`
* `client_id` - the client_id for the OAuth2 provider
* `client_secret` - the client_secret for the OAuth2 provider
* `headers` - a list of request headers
* `params` - a map of request parameters
* `redirect_uri` - the URI the provider should redirect to after authorization
   or token requests
* `request_opts` - a keyword list of request options that will be sent to the
  `hackney` client. See the [hackney documentation] for a list of available
  options.
* `site` - the OAuth2 provider site host
* `strategy` - a module that implements the appropriate OAuth2 strategy,
  default `OAuth2.Strategy.AuthCode`
* `token` - `%OAuth2.AccessToken{}` struct holding the token for requests.
* `token_method` - HTTP method to use to request token (`:get` or `:post`).
  Defaults to `:post`
* `token_url` - absolute or relative URL path to the token endpoint.
  Defaults to `"/oauth/token"`

## Example

    iex> OAuth2.Client.new(token: "123")
    %OAuth2.Client{authorize_url: "/oauth/authorize", client_id: "",
    client_secret: "", headers: [], params: %{}, redirect_uri: "", site: "",
    strategy: OAuth2.Strategy.AuthCode,
    token: %OAuth2.AccessToken{access_token: "123", expires_at: nil,
    other_params: %{}, refresh_token: nil, token_type: "Bearer"},
    token_method: :post, token_url: "/oauth/token"}

    iex> token = OAuth2.AccessToken.new("123")
    iex> OAuth2.Client.new(token: token)
    %OAuth2.Client{authorize_url: "/oauth/authorize", client_id: "",
    client_secret: "", headers: [], params: %{}, redirect_uri: "", site: "",
    strategy: OAuth2.Strategy.AuthCode,
    token: %OAuth2.AccessToken{access_token: "123", expires_at: nil,
    other_params: %{}, refresh_token: nil, token_type: "Bearer"},
    token_method: :post, token_url: "/oauth/token"}

[hackney documentation]: https://github.com/benoitc/hackney/blob/master/doc/hackney.md#request5

## patch(client, url, body \\ "", headers \\ [], opts \\ [])

Makes a `PATCH` request to the given `url` using the `OAuth2.AccessToken`
struct.

## patch!(client, url, body \\ "", headers \\ [], opts \\ [])

Same as `patch/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception if
the request results in an error.

An `OAuth2.Error` exception is raised if the request results in an
error tuple (`{:error, reason}`).

## post(client, url, body \\ "", headers \\ [], opts \\ [])

Makes a `POST` request to the given URL using the `OAuth2.AccessToken`.

## post!(client, url, body \\ "", headers \\ [], opts \\ [])

Same as `post/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception
if the request results in an error.

An `OAuth2.Error` exception is raised if the request results in an
error tuple (`{:error, reason}`).

## put(client, url, body \\ "", headers \\ [], opts \\ [])

Makes a `PUT` request to the given `url` using the `OAuth2.AccessToken`
struct.

## put!(client, url, body \\ "", headers \\ [], opts \\ [])

Same as `put/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception if
the request results in an error.

An `OAuth2.Error` exception is raised if the request results in an
error tuple (`{:error, reason}`).

## put_header(client, key, value)

Adds a new header `key` if not present, otherwise replaces the
previous value of that header with `value`.

## put_headers(client, list)

Set multiple headers in the client in one call.

## put_param(client, key, value)

Puts the specified `value` in the params for the given `key`.

The key can be a `string` or an `atom`. Atoms are automatically
convert to strings.

## put_serializer(client, mime, module)

Register a serialization module for a given mime type.

## Example

    iex> client = OAuth2.Client.put_serializer(%OAuth2.Client{}, "application/json", Jason)
    %OAuth2.Client{serializers: %{"application/json" => Jason}}
    iex> OAuth2.Client.get_serializer(client, "application/json")
    Jason

## refresh_token(token, params \\ [], headers \\ [], opts \\ [])

Refreshes an existing access token using a refresh token.

## refresh_token!(client, params \\ [], headers \\ [], opts \\ [])

Calls `refresh_token/4` but raises `Error` if there an error occurs.