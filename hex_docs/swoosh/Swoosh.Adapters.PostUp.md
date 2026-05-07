# Swoosh.Adapters.PostUp

An adapter that sends email using the PostUp API, specifically triggered mailing. This
corresponds to transactional emails.

API reference: [PostUp API docs](https://apidocs.postup.com/docs/send-a-triggered-mailing)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.PostUp,
      username: "BMO",
      password: "hellofootball"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with provider options

Specify custom tags as a string delimited by semicolons:

    import Swoosh.Email

    new()
    |> from({"BMO", "bmo@example.com"})
    |> to([
      {["FirstName=Finn;LastName=Mertins;custom_tag=Something Else"], "finnthehuman@example.com"},
      {["FirstName=Jake"], "jakethedog@example.com"},
    ])
    |> subject("BMO says hi!")
    |> reply_to("Football@example.com")
    |> html_body("<h1>Hello :)</h1>")
    |> text_body("Hi!")
    |> put_provider_option(:send_template_id, 42)

## Usage with just template and no other options

Use an invalid email address to ignore the `from` option, which is required by Swoosh but causes
email templates to be overwritten as part of the "context" field in the request body.

    import Swoosh.Email

    new()
    |> from("IGNORED")
    |> to([
      {"FirstName=Finn;LastName=Mertins", "finnthehuman@example.com"},
      {"FirstName=Jake", "jakethedog@example.com"},
    ])
    |> put_provider_option(:send_template_id, 42)

## Provider Options

Note that most of these options are nested under the optional "content" field in the JSON request
body alongside "fromEmail", "fromName", "htmlBody", etc.

  * `send_template_id` (integer): unique number assigned to each send template.
    **Required field.**

  * `unsub_content_id` (integer): ID for replacement unsubscribe content in specified template.

  * `reply_content_id` (integer): Same as above for "reply" content.

  * `header_content_id` (integer): Same as above for header content.

  * `footer_content_id` (integer): Same as above for footer content.

  * `forward_to_friend_content_id` (integer): Same as above for "forward to friend" content.