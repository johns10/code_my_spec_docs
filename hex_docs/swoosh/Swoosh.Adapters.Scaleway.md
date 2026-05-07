# Swoosh.Adapters.Scaleway

An adapter that sends email using the Scaleway API (Transactional emails only).

For reference: [Scaleway API docs](https://www.scaleway.com/en/developers/api/transactional-email/#path-emails-send-an-email)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Scaleway,
      project_id: "my-project-id",
      secret_key: "my-api-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with provider options

    import Swoosh.Email

    new()
    |> from("nora@example.com")
    |> to("shushu@example.com")
    |> subject("Hello, Wally!")
    |> text_body("Hello")
    |> header("Reply-To", "support@example.com")
    |> put_provider_option(:send_before, ~U[2022-11-15 11:00:00Z])

## Provider Options

  * `send_before` (RFC 3339 format) - maximum date to deliver the email.