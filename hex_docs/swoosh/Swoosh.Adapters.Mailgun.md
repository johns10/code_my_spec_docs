# Swoosh.Adapters.Mailgun

An adapter that sends email using the Mailgun API.

For reference: [Mailgun API docs](https://documentation.mailgun.com/en/latest/api-sending.html#sending)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

> ### Dependency {: .info}
>
> Mailgun adapter requires `Plug` and [`:multipart`](https://hex.pm/packages/multipart) to work properly.

## Configuration options

* `:api_key` - the API key used with Mailgun
* `:domain` - the domain you will be sending emails from. For sandbox domains, make sure to use the sandbox address, for example: `https://api.mailgun.net/v3/sandbox123456.mailgun.org/messages` then you should set `domain: "sandbox123456.mailgun.org"`.
* `:base_url` - the url to use as the API endpoint. For EU domains, use https://api.eu.mailgun.net/v3

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Mailgun,
      api_key: "my-api-key",
      domain: "avengers.com"

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
    |> put_provider_option(:custom_vars, %{"key" => "value"})
    |> put_provider_option(:recipient_vars, %{"steve.rogers@example.com": %{var1: 123}, "juan.diaz@example.com": %{var1: 456}})
    |> put_provider_option(:sending_options, %{dkim: "yes", tracking: "no"})
    |> put_provider_option(:tags, ["worldwide-peace", "unity"])
    |> put_provider_option(:template_name, "avengers-templates")
    |> put_provider_option(:template_options, %{version: "initial"})

## Provider options

  * `:custom_vars` (map) - used to translate to `v:my-var`, now
    `h:X-Mailgun-Variables`, add custom data to email

  * `:recipient_vars` (map) - `recipient-variables`, assign
    custom variable for each email recipient

  * `:sending_options` (map) - `o:my-key`, all the sending options

  * `:tags` (list[string]) - `o:tag`, was added in before `:sending_options`,
    kept for backward compatibility, use `:sending_options` instead

  * `:template_name` (string) - `template`, name of template created at Mailgun

  * `:template_options` (map) - `version`, `text`, `variables` and/or any future possible values

## Custom headers

Headers added via `Email.header/3` will be translated to (`h:`) values that
Mailgun recognizes.