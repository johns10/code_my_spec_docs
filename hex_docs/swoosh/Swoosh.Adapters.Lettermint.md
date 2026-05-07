# Swoosh.Adapters.Lettermint

An adapter that sends email using the Lettermint API.

For reference: [Lettermint API docs](https://docs.lettermint.co/api-reference/endpoint/send)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Lettermint,
      api_token: "my-api-token"

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
    |> put_provider_option(:metadata, %{campaign: "welcome"})
    |> put_provider_option(:idempotency_key, "unique-key-123")

## Provider Options

  * `metadata` (map) - Custom tracking metadata
  * `idempotency_key` (string) - Unique key to prevent duplicate sends