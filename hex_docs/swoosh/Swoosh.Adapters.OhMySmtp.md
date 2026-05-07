# Swoosh.Adapters.OhMySmtp

**Deprecated - use MailPace now**

> Moving from OhMySMTP to MailPace
> https://docs.mailpace.com/guide/moving_from_ohmysmtp

An adapter that sends email using the OhMySMTP API.

For reference: [OhMySMTP API docs](https://docs.ohmysmtp.com/reference/overview)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.OhMySmtp,
      api_key: "my-api-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end