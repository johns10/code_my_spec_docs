# Swoosh.Adapters.Postal

An adapter that sends email using the Postal API.
[Postal](https://docs.postalserver.io/) is open-source, self-hosted mail delivery platform.

For reference: [Postal API docs](https://apiv1.postalserver.io/)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Configuration options

* `:api_key` - Postal API key.
* `:base_url` - Base URL where Postal server is running.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Postal,
      api_key: "my-api-key",
      base_url: "https://my-postal-server.com/"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with provider options

    import Swoosh.Email

    new()
    |> from({"T Stark", "tony.stark@example.com"})
    |> to({"Steve Rogers", "steve.rogers@example.com"})
    |> to("wasp.avengers@example.com")
    |> reply_to("office.avengers@example.com")
    |> cc({"Bruce Banner", "hulk.smash@example.com"})
    |> cc("thor.odinson@example.com")
    |> bcc({"Clinton Francis Barton", "hawk.eye@example.com"})
    |> bcc("beast.avengers@example.com")
    |> subject("Hello, Avengers!")
    |> html_body("<h1>Hello</h1>")
    |> text_body("Hello")
    |> put_provider_option(:tag, "avengers")
    |> put_provider_option(:bounce, true)