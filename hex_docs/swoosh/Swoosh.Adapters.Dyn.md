# Swoosh.Adapters.Dyn

An adapter that sends email using the Dyn API.

For reference: [Dyn API docs](https://help.dyn.com/email-rest-methods-api/sending-api/)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Dyn,
      api_key: "my-api-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Sending sample email

    import Swoosh.Email

    new()
    |> from({"Christine", "christine@example.com"})
    |> to({"constance", "constance@example.com"})
    |> to("ming_fleetfoot@example.com")
    |> bcc([
      {"Dr. Xander Bravestone", "dr.xander_bravestone@example.com"},
      {"Prof. Sheldon Oberon", "prof.sheldon.oberon@example.com"}
    ])
    |> subject("Hello, People!")
    |> html_body("<h1>Hello</h1>")
    |> text_body("Hello")