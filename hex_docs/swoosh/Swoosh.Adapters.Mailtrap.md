# Swoosh.Adapters.Mailtrap

An adapter that sends email using the Mailtrap API.

For reference: [Mailtrap API docs](https://api-docs.mailtrap.io/docs/mailtrap-api-docs/67f1d70aeb62c-send-email)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Mailtrap,
      api_key: "my-api-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Sandbox mode

For [sandbox mode](https://api-docs.mailtrap.io/docs/mailtrap-api-docs/bcf61cdc1547e-send-email-early-access), use the following config:

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Mailtrap,
      api_key: "my-api-key",
      sandbox_inbox_id: "111111"

## Using with provider options

    import Swoosh.Email

    new()
    |> from({"Xu Shang-Chi", "xu.shangchi@example.com"})
    |> to({"Katy", "katy@example.com"})
    |> reply_to("xu.xialing@example.com")
    |> cc("yingli@example.com")
    |> cc({"Xu Wenwu", "xu.wenwu@example.com"})
    |> bcc("yingnan@example.com")
    |> bcc({"Jon Jon", "jonjon@example.com"})
    |> subject("Hello, Ten Rings!")
    |> html_body("<h1>Hello</h1>")
    |> text_body("Hello")
    |> put_provider_option(:custom_variables, %{
      my_var: %{my_message_id: 123},
      my_other_var: %{my_other_id: 1, stuff: 2}
    })
    |> put_provider_option(:category, "welcome")

## Provider Options

Supported provider options are the following:

#### Inserted into request body

  * `:category` (string) - an email category

  * `:custom_variables` (map) - a map containing fields