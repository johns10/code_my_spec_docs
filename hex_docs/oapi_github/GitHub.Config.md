# GitHub.Config

Configuration for the API client and plugins

> #### Note {:.info}
>
> Functions in this module is unlikely to be used directly by applications. Instead, they are
> useful for plugins. See `GitHub.Plugin` for more information.

Callers of API operation functions can pass in some configuration directly using the final
argument. Configuration passed in this way always takes precedence over global configuration.

    # Local options:
    GitHub.Repos.get("aj-foster", "open-api-github", server: "https://gh.example.com")

    # Application environment (ex. config/config.exs):
    config :oapi_github, server: "https://gh.example.com"

## Options

The following configuration is available using **local options**:

  * `server` (URL): API server to use. Useful if the client would like to target a GitHub
    Enterprise installation. Defaults to `https://api.github.com`.

  * `stack` (list of plugins): Plugins to control the execution of client requests. See
    `GitHub.Plugin` for more information. Defaults to the default stack below.

  * `version` (string): API version to use. Setting this option is not recommended, as the default
    value is the version of the API used to generate this client's code. Overriding it risks the
    client raising an error. To see the default value, open `.api-version` in the root of this
    project.

  * `wrap` (boolean): Whether to wrap the results of the API call in a tagged tuple. When
    `true`, the response body will be wrapped as `{:ok, response}` on success or
    `{:error, error}` otherwise. When false, the Operation or Error is returned directly.
    Defaults to `true`.

    **Note**: Unwrapped responses violate the type specifications provided for each client
    operation. To avoid Dialyzer errors, consider using `GitHub.raw/4` instead.

The following configuration is available using the **application environment**:

  * `app_name` (string): Name of the application using this client, used for User Agent and
    logging purposes.

  * `apps` (list of tuples): GitHub App configurations. Each app config is a 3-tuple containing
    a name (atom), app ID (integer), and private key (string, PEM format). See `GitHub.app/1`
    for more information.

  * `default_auth` (`t:GitHub.Auth.auth/0`): Default API authentication credentials to use when
    authentication was not provided for a request. OAuth applications can provide their client ID
    and secret to increase their unauthenticated rate limit.

  * `server` (URL): API server to use. Useful if the client would like to target a GitHub
    Enterprise installation. Defaults to `https://api.github.com`.

  * `stack` (list of plugins): Plugins to control the execution of client requests. See
    `GitHub.Plugin` for more information. Defaults to the default stack below.

  * `webhook_secret` (string): Secret value provided to GitHub for signing webhook requests.
    See `GitHub.Webhook` for more information. Defaults to no signature verification.

## Plugins

Client requests are implemented using a series of plugins. Each plugin accepts a
`GitHub.Operation` struct and returns either a modified operation or an error. The collection of
plugins configured for a request form a **stack**.

The default stack uses `Jason` as a serializer/deserializer and `HTTPoison` as an HTTP client:

```elixir
[
  {GitHub.Plugin.JasonSerializer, :encode_body, []},
  {GitHub.Plugin.HTTPoisonClient, :request, []},
  {GitHub.Plugin.JasonSerializer, :decode_body, []},
  {GitHub.Plugin.TypedDecoder, :decode_response, []},
  {GitHub.Plugin.TypedDecoder, :normalize_errors, []}
]
```

In general, plugins can be defined as 2- or 3-tuples specifying the module and function name and
any options to pass to the function. For example:

    {MyPlugin, :my_function}
    #=> MyPlugin.my_function(operation)

    {MyPlugin, :my_function, some: :option}
    #=> MyPlugin.my_function(operation, some: :option)

By modifying the stack, applications can easily use a different HTTP client library or serializer.

> #### Warning {:.warning}
>
> Stack entries without options, like `{GitHub.Plugin.TestClient, :request}`, look like keyword
> list items. If you have stacks configured in multiple Mix environments that all use this
> 2-tuple format, Elixir will try to merge them as keyword lists. Adding an empty options
> element to any stack item will prevent this behaviour.

## app(app_name)

Get the configuration of a GitHub App by its name

## Example

    iex> Config.app(:my_app)
    {:ok, {:my_app, 12345, "\"-----BEGIN RSA PRIVATE KEY..."}}

## app_name()

Get the configured app name

## Example

    iex> Config.app_name()
    "Test App"

## default_auth()

Get the configured default auth credentials

## Example

    iex> Config.default_auth()
    {"client_one", "abc123"}

## plugin_config(config \\ [], plugin, key, default)

Get configuration namespaced with a plugin module

Plugins can provide a keyword list of options (such as a pre-merged keyword list of the plugin
options argument and the operation's options) to be used if the given key is present. Otherwise,
the response will fall back to the application environment given with the following form:

    config :oapi_github, MyPlugin, some: :option

Where `MyPlugin` is the `plugin` module given as the second argument.

See `plugin_config!/3` for a variant that raises if the configuration is not found.

## plugin_config!(config \\ [], plugin, key)

Get configuration namespaced with a plugin module, or raise if not present

Plugins can provide a keyword list of options (such as a pre-merged keyword list of the plugin
options argument and the operation's options) to be used if the given key is present. Otherwise,
the response will fall back to the application environment given with the following form:

    config :oapi_github, MyPlugin, some: :option

Where `MyPlugin` is the `plugin` module given as the second argument.

See `plugin_config/4` for a variant that accepts a default value.

## server(opts)

Get the configured default API server, or `https://api.github.com` by default

## Example

    iex> Config.server([])
    "https://api.github.com"

    iex> Config.server(server: "https://gh.example.com")
    "https://gh.example.com"

## stack(opts)

Get the configured plugin stack

## Example

    iex> Config.stack([])
    [
      {GitHub.Plugin.JasonSerializer, :encode_body},
      # ...
    ]

## Default

The following stack is the default if none is configured or passed as an option:

```elixir
[
  {GitHub.Plugin.JasonSerializer, :encode_body, []},
  {GitHub.Plugin.HTTPoisonClient, :request, []},
  {GitHub.Plugin.JasonSerializer, :decode_body, []},
  {GitHub.Plugin.TypedDecoder, :decode_response, []},
  {GitHub.Plugin.TypedDecoder, :normalize_errors, []}
]
```

## version(opts)

Get the configured API version, or `2022-11-28` by default

## Example

    iex> Config.version([])
    "2022-11-28"

    iex> Config.version(version: "2020-01-01")
    "2020-01-01"

## wrap(opts)

Whether to wrap the result

Passing `wrap: false` to a client call can be useful if you need additional information about
the response, such as response headers.

## Example

    iex> Config.wrap([])
    true

    iex> Config.wrap(wrap: false)
    false

## plugin/0

Plugin definition

Plugins are defined in the stack using module and function tuples with an optional keyword list.
Options, if provided, will be passed as the second argument.