# GitHub.Config



## app/1

Get the configuration of a GitHub App by its name

## Example

    iex> Config.app(:my_app)
    {:ok, {:my_app, 12345, "\"-----BEGIN RSA PRIVATE KEY..."}}

## app_name/0

Get the configured app name

## Example

    iex> Config.app_name()
    "Test App"

## default_auth/0

Get the configured default auth credentials

## Example

    iex> Config.default_auth()
    {"client_one", "abc123"}

## wrap/1

Whether to wrap the result

Passing `wrap: false` to a client call can be useful if you need additional information about
the response, such as response headers.

## Example

    iex> Config.wrap([])
    true

    iex> Config.wrap(wrap: false)
    false

## plugin_config/4

Get configuration namespaced with a plugin module

Plugins can provide a keyword list of options (such as a pre-merged keyword list of the plugin
options argument and the operation's options) to be used if the given key is present. Otherwise,
the response will fall back to the application environment given with the following form:

    config :oapi_github, MyPlugin, some: :option

Where `MyPlugin` is the `plugin` module given as the second argument.

See `plugin_config!/3` for a variant that raises if the configuration is not found.

## plugin_config!/3

Get configuration namespaced with a plugin module, or raise if not present

Plugins can provide a keyword list of options (such as a pre-merged keyword list of the plugin
options argument and the operation's options) to be used if the given key is present. Otherwise,
the response will fall back to the application environment given with the following form:

    config :oapi_github, MyPlugin, some: :option

Where `MyPlugin` is the `plugin` module given as the second argument.

See `plugin_config/4` for a variant that accepts a default value.