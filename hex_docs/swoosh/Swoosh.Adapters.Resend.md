# Swoosh.Adapters.Resend

An adapter that sends email using the Resend API.

For reference:
* [Sending Email API docs](https://resend.com/docs/api-reference/emails/send-email)
* [Sending Email in Batch API docs](https://resend.com/docs/api-reference/emails/send-batch-emails)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Resend,
      api_key: "re_123456789"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with provider options

    import Swoosh.Email

    new()
    |> from("onboarding@resend.dev")
    |> to("user@example.com")
    |> subject("Hello!")
    |> html_body("<strong>Hello</strong>")
    |> put_provider_option(:tags, [%{name: "category", value: "confirm_email"}])
    |> put_provider_option(:scheduled_at, "2024-08-05T11:52:01.858Z")
    |> put_provider_option(:idempotency_key, "some-unique-key-123")
    |> header("X-Custom-Header", "CustomValue")

## Using Templates

    import Swoosh.Email

    new()
    |> from("onboarding@resend.dev")
    |> to("user@example.com")
    |> put_provider_option(:template, %{
      id: "my-template-id",
      variables: %{
        name: "John",
        action_url: "https://example.com"
      }
    })

Note: When using a template, you cannot send `html_body` or `text_body` in the same email.
The template's `from`, `subject`, and `reply_to` can be overridden in the email struct.

## Inline Images

To embed images inline using Content-ID (CID):

    import Swoosh.Email

    new()
    |> from("onboarding@resend.dev")
    |> to("user@example.com")
    |> subject("Welcome!")
    |> html_body(~s(<h1>Hello!</h1><img src="cid:logo"/>))
    |> attachment(
      Swoosh.Attachment.new(
        {:data, File.read!("logo.png")},
        filename: "logo.png",
        content_type: "image/png",
        type: :inline,
        cid: "logo"
      )
    )

## Provider Options

  * `tags` (list of maps) - List of tag objects with `name` and `value` keys
    for categorizing emails (max 256 chars per value)

  * `scheduled_at` (string) - ISO 8601 formatted date-time string to schedule
    the email for later delivery (not supported in batch sending)

  * `idempotency_key` (string) - A unique key to prevent duplicate email sends.

  * `template` (map) - Template object with:
    * `id` (required) - The ID or alias of the published template
    * `variables` (optional) - Map of template variables (key/value pairs)

## Batch Sending

This adapter supports `deliver_many/2` for sending multiple emails in a single
API call using Resend's batch endpoint. Each email in the batch is independent
and can have different recipients, subjects, content, and tags.

Note: The batch endpoint has a maximum of 100 emails per request and does not
support `scheduled_at` or `attachments` (including inline images).