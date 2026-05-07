# Swoosh.Adapters.MsGraph

An adapter that sends email using the Microsoft Graph API.

For reference: [Microsoft Graph API docs](https://learn.microsoft.com/en-us/graph/api/user-sendmail)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

> ### Dependency {: .info}
>
> Microsoft Graph adapter requires `:gen_smtp` to work properly.
> `:gen_smtp` is only used to encode the email body to MIME format.

## Configuration options

* `:auth` - either a function, a {mod, func, args} tuple, or a string that returns/is an OAuth 2.0 access token.
* `:base_url` - the base URL to use as the Microsoft Graph API endpoint.  Defaults to the standard Microsoft Graph API endpoint.
* `:url` - the full URL to use as the Microsoft Graph API endpoint. If this is provided, `:base_url` is ignored. Useful for doing delegated sends such that the from of the email is maintained, but auth is done using the full URL (like when using a Distribution List).

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.MsGraph,
      auth: fn -> Sample.OAuthTokenRequester.request_token() end

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end