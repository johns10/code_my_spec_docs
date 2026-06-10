# OAuth2.Client



## new/2

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

## put_param/3

Puts the specified `value` in the params for the given `key`.

The key can be a `string` or an `atom`. Atoms are automatically
convert to strings.

## merge_params/2

Set multiple params in the client in one call.

## put_header/3

Adds a new header `key` if not present, otherwise replaces the
previous value of that header with `value`.

## put_headers/2

Set multiple headers in the client in one call.

## authorize_url!/2

Returns the authorize url based on the client configuration.

## Example

    iex> OAuth2.Client.authorize_url!(%OAuth2.Client{})
    "/oauth/authorize?client_id=&redirect_uri=&response_type=code"

## put_serializer/3

Register a serialization module for a given mime type.

## Example

    iex> client = OAuth2.Client.put_serializer(%OAuth2.Client{}, "application/json", Jason)
    %OAuth2.Client{serializers: %{"application/json" => Jason}}
    iex> OAuth2.Client.get_serializer(client, "application/json")
    Jason

## delete_serializer/2

Un-register a serialization module for a given mime type.

## Example

    iex> client = OAuth2.Client.delete_serializer(%OAuth2.Client{}, "application/json")
    %OAuth2.Client{}
    iex> OAuth2.Client.get_serializer(client, "application/json")
    nil

## get_token/4

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

## get_token!/4

Same as `get_token/4` but raises `OAuth2.Error` if an error occurs during the
request.

## refresh_token/4

Refreshes an existing access token using a refresh token.

## refresh_token!/4

Calls `refresh_token/4` but raises `Error` if there an error occurs.

## basic_auth/1

Adds `authorization` header for basic auth.

## get/4

Makes a `GET` request to the given `url` using the `OAuth2.AccessToken`
struct.

## get!/4

Same as `get/4` but returns a `OAuth2.Response` or `OAuth2.Error` exception if
the request results in an error.

## put/5

Makes a `PUT` request to the given `url` using the `OAuth2.AccessToken`
struct.

## put!/5

Same as `put/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception if
the request results in an error.

An `OAuth2.Error` exception is raised if the request results in an
error tuple (`{:error, reason}`).

## patch/5

Makes a `PATCH` request to the given `url` using the `OAuth2.AccessToken`
struct.

## patch!/5

Same as `patch/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception if
the request results in an error.

An `OAuth2.Error` exception is raised if the request results in an
error tuple (`{:error, reason}`).

## post/5

Makes a `POST` request to the given URL using the `OAuth2.AccessToken`.

## post!/5

Same as `post/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception
if the request results in an error.

An `OAuth2.Error` exception is raised if the request results in an
error tuple (`{:error, reason}`).

## delete/5

Makes a `DELETE` request to the given URL using the `OAuth2.AccessToken`.

## delete!/5

Same as `delete/5` but returns a `OAuth2.Response` or `OAuth2.Error` exception
if the request results in an error.

An `OAuth2.Error` exception is raised if the request results in an
error tuple (`{:error, reason}`).