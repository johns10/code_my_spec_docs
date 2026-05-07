# Swoosh.Adapters.SMTP2GO

An adapter that sends email using the SMTP2GO API.

For reference: [SMTP2GO API docs](https://apidoc.smtp2go.com/documentation/#/POST%20/email/send)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.SMTP2GO,
      api_key: "my-api-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Usage

    import Swoosh.Email

    new()
    |> from({"Tony", "ironman@example.com"})
    |> to({"Thanos", "thanos@example.com"})
    |> reply_to("avengers@example.com")
    |> cc("hulk@example.com")
    |> bcc({"Steve Rogers", "steve.rogers@example.com"})
    |> subject("I'm Ironman")
    |> html_body("<h1>Hello</h1>")
    |> text_body("Hello")

with template:

    import Swoosh.Email

    new()
    |> from({"Tony", "ironman@example.com"})
    |> to({"Thanos", "thanos@example.com"})
    |> subject("I'm Ironman")
    |> put_provider_option(:template_id, "123456")
    |> put_provider_option(:template_data, %{"var1" => "value1"})