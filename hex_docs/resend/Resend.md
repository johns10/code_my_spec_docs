# Resend

Documentation for `Resend`.

## client(config \\ config())

Returns a Resend client.

Accepts a keyword list of config opts, though if omitted then it will attempt to load
them from the application environment.

## config()

Loads config values from the application environment.

Config options are as follows:

```ex
config :resend, Resend.Client
  api_key: "re_1234567",
  base_url: "https://api.resend.com",
  client: Resend.Client.TeslaClient
```

The only required config option is `:api_key`. If you would like to replace the
HTTP client used by Resend, configure the `:client` option. By default, this library
uses [Tesla](https://github.com/elixir-tesla/tesla), but changing it is as easy as
defining your own client module. See the `Resend.Client` module docs for more info.