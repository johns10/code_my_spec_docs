# Swoosh.Adapters.Mailersend

An adapter that sends email using the MailerSend API.

For reference: [MailerSend API docs](https://developers.mailersend.com/api/v1/email.html)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Mailersend,
      api_key: "your-api-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with provider options

    import Swoosh.Email

    new()
    |> from({"T Stark", "tony.stark@example.com"})
    |> to({"Steve Rogers", "steve.rogers@example.com"})
    |> subject("Hello, Avengers!")
    |> html_body("<h1>Hello</h1>")
    |> text_body("Hello")
    |> put_provider_option(:tags, ["onboarding", "welcome"])
    |> put_provider_option(:track_opens, true)
    |> put_provider_option(:track_clicks, true)
    |> put_provider_option(:metadata, %{"user_id" => "123"})

## Using with MailerSend templates

    import Swoosh.Email

    new()
    |> from({"T Stark", "tony.stark@example.com"})
    |> to({"Steve Rogers", "steve.rogers@example.com"})
    |> put_provider_option(:template_id, "template-123")
    |> put_provider_option(:template_variables, %{
      "name" => "Steve",
      "mission" => "Project Insight"
    })

## Personalization without templates

MailerSend supports `{{ variable }}` substitution in subject, HTML, and
text body fields without requiring a template.

    import Swoosh.Email

    new()
    |> from({"T Stark", "tony.stark@example.com"})
    |> to({"Steve Rogers", "steve.rogers@example.com"})
    |> subject("Welcome {{ name }}!")
    |> html_body("<h1>Hello {{ name }}</h1>")
    |> put_provider_option(:personalization, [
      %{"email" => "steve.rogers@example.com", "data" => %{"name" => "Steve"}}
    ])

## Provider Options

  * `:template_id` (string) - MailerSend template ID to use instead of
    html/text body

  * `:template_variables` (map) - variables for template personalization,
    applied to all recipients via the `personalization` array

  * `:personalization` (list of maps) - per-recipient personalization data
    for non-template emails. Each map must have `"email"` and `"data"` keys.
    Values populate `{{ variable }}` placeholders in subject, HTML, and text

  * `:tags` (list of strings) - tags to categorize the email (max 5)

  * `:webhook_id` (string) - webhook ID for delivery tracking

  * `:metadata` (map) - custom metadata to attach to the email

  * `:send_at` (integer or DateTime) - unix timestamp or DateTime for
    scheduled sending

  * `:track_opens` (boolean) - enable open tracking

  * `:track_clicks` (boolean) - enable click tracking

  * `:track_content` (boolean) - enable content tracking

  * `:in_reply_to` (string) - Message-ID of the email being replied to

  * `:references` (list of strings) - list of Message-IDs that the
    current email is referencing

  * `:precedence_bulk` (boolean) - set precedence bulk header, overrides
    domain's advanced settings

  * `:list_unsubscribe` (string) - List-Unsubscribe header value per
    RFC 8058