# Swoosh.Adapters.Mailjet

An adapter that sends email using the Mailjet API.

For reference: [Mailjet API docs](https://dev.mailjet.com/guides/#send-api-v3-1)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

> ### Dependency {: .info}
>
> Mailjet adapter requires `Plug` to work properly.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Mailjet,
      api_key: "my-api-key",
      secret: "my-secret-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with provider options

    import Swoosh.Email

    new()
    |> from({"Billi Wang", "billi_wang@example.com"})
    |> to({"Nai Nai", "nainai@example.com"})
    |> reply_to("a24@example.com")
    |> cc({"Haiyan Wang", "haiyan_wang@example.com"})
    |> cc("lujian@example.com")
    |> bcc({"Hao Hao", "haohao@example.com"})
    |> bcc("aiko@example.com")
    |> subject("Hello, Nai Nai!")
    |> html_body("<h1>Hello</h1>")
    |> text_body("Hello")
    |> put_provider_option(:template_id, 123)
    |> put_provider_option(:template_error_deliver, true)
    |> put_provider_option(:template_error_reporting, "developer@example.com")
    |> put_provider_option(:variables, %{firstname: "lulu", lastname: "wang"})
    |> put_provider_option(:custom_id, "custom_id")
    |> put_provider_option(:event_payload, "event_payload")
    |> put_provider_option(:track_opens, false)
    |> put_provider_option(:track_clicks, false)
    |> put_provider_option(:url_tags, "utm_source=transactional&utm_medium=email")

## Provider options

  * `:template_id` (integer) - `TemplateID`, unique template id of the
    template to be used as email content

  * `:template_error_deliver` (boolean) - `TemplateErrorDeliver`,
    send even if error in template if `true`, otherwise stop email delivery
    immediately upon error

  * `:template_error_reporting` (string | tuple | map) - `TemplateErrorReporting`,
    email address or a tuple of name and email address of a recipient to send a
    carbon copy upon error

  * `:variables` (map) - `Variables`, custom key-value variable for the email
    content

  * `:custom_id` (string) - `CustomID`, custom id for the email

  * `:event_payload` (string | map) - `EventPayload`, custom payload that will
    be attached on the mailjet webhook events

  * `:track_opens` (boolean) - `TrackOpens`, enable or disable open tracking

  * `:track_clicks` (boolean) - `TrackClicks`, enable or disable click tracking

  * `:url_tags` (string) - `URLTags`, URL query parameters to append to all
    URLs in the message (e.g. `"utm_source=transactional&utm_medium=email"`)