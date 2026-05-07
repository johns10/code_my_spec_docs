# Swoosh.Adapters.Postmark

An adapter that sends email using the Postmark API.

For reference: [Postmark API docs](http://developer.postmarkapp.com/developer-send-api.html)

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Postmark,
      api_key: "my-api-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Example of sending emails using templates

This will use Postmark's `withTemplate` endpoint.

    import Swoosh.Email

    new()
    |> from({"T Stark", "tony.stark@example.com"})
    |> to({"Steve Rogers", "steve.rogers@example.com"})
    |> put_provider_option(:template_id, "123456")
    |> put_provider_option(:template_model, %{name: "Steve", email: "steve@avengers.com"})

You can also use `template_alias` instead of `template_id`, if you use Postmark's
[TemplateAlias](https://postmarkapp.com/developer/api/templates-api#email-with-template) feature.

Note that you must include the `:template_model` provider option even if your template
has no variables to interpolate. In this case you can pass an empty map:

    put_provider_option(email, :template_model, %{})

When sending batch emails using `:deliver_many` do not mix emails using
templates with non-template emails. The use of templates impacts the API
endpoint used and so the batch email collection should be of the same format.

## Example of sending emails with a tag

This will add a tag to the sent Postmark's email.

    import Swoosh.Email

    new()
    |> from({"T Stark", "tony.stark@example.com"})
    |> to({"Steve Rogers", "steve.rogers@example.com"})
    |> subject("Hello, Avengers!")
    |> put_provider_option(:tag, "some tag")

## Provider Options

  * `:message_stream` (string) – `MessageStream`, configure the message stream
    for the email

  * `:metadata` (map) - `Metadata`, add metadata to an email

  * `:tag` (string) - `Tag`, to categorize outgoing email

  * `:template_id` (string) - `TemplateId`, the template used when sending
    email and only required if `:template_alias` is not specified

  * `:template_alias` (string), `TemplateAlias`, the alias of a template used
    when sending email and only required if `:template_id` is not specified

  * `:template_model` (map), `TemplateModel`, a map of key/value field to be
    used in the `HtmlBody`, `TextBody`, and `Subject` field in the template,
    required alongside `:template_id`/`:template_alias`

  * `:track_opens` (boolean) - `TrackOpens`, specify if open tracking needs to be enabled for this email.

  * `:track_links` (string) - `TrackOpens`, specify if link tracking needs to be enabled for this email.
     Valid values are: `None`, `HtmlAndText`, `HtmlOnly`, `TextOnly`

  * `:inline_css` (boolean) - `InlineCss`, specify if Postmark should apply the style blocks as inline
    attributes to the rendered HTML content. Default is true.