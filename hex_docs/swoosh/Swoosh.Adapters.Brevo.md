# Swoosh.Adapters.Brevo

An adapter that sends email using the Brevo API (Transactional emails only).

For reference: [Brevo API docs](https://developers.brevo.com/reference/sendtransacemail)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Brevo,
      api_key: "my-api-key"

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
    |> put_provider_option(:id, 42)
    |> put_provider_option(:template_id, 42)
    |> put_provider_option(:params, %{param1: "a", param2: 123})
    |> put_provider_option(:tags, ["tag_1", "tag_2"])
    |> put_provider_option(:schedule_at, ~U[2022-11-15 11:00:00Z])

## Batch Sending

This adapter supports `deliver_many/2` for sending multiple emails in a single API call
using Brevo's `messageVersions` parameter. When using batch sending:

**Global parameters** (applied to all emails in the batch):
  * `sender` - from address (taken from first email)
  * `attachment` - attachments (taken from first email)  
  * `tags` - email tags (taken from first email)
  * `scheduledAt` - scheduled send time (taken from first email)

**Per-email parameters** (can be different for each email):
  * `to`, `cc`, `bcc` - recipients
  * `subject` - email subject
  * `htmlContent`, `textContent` - email content
  * `templateId` - template selection
  * `params` - template variables
  * `headers` - custom headers
  * `replyTo` - reply address

## Provider Options

  * `sender_id` (integer) - `sender`, the sender `id` where this library will
    add email obtained from the `from/1`

  * `template_id` (integer) - `templateId`, the Id of the `active`
    transactional email template

  * `params` (map) - `params`, a map of key/value attributes to customize the
    template

  * `tags` (list[string]) - `tags`, a list of tags for each email for easy
    filtering

  * `schedule_at` (UTC DateTime) - `schedule_at`, a UTC date-time on which the email has to schedule