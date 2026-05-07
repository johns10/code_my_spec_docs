# Swoosh.Adapters.Mandrill

An adapter that sends email using the Mandrill API.

It supports both the `send` and `send-template` endpoint. In order to use the
latter you need to set `template_name` in the `provider_options` map on
`Swoosh.Email`.

For reference: [Mandrill API docs](https://mandrillapp.com/api/docs/messages.html)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Mandrill,
      api_key: "my-api-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with provider options

    import Swoosh.Email

    new()
    |> from({"Rachel Chu", "rachel.chu@example.com"})
    |> to({"Nick Young", "nick.young@example.com"})
    |> to("astrid.leongteo@example.com")
    |> reply_to("sk.starlight@example.com")
    |> cc({"Goh Peik Lin", "goh.peiklin@example.com"})
    |> cc("goh.wyemun@example.com")
    |> bcc({"Eleanor Sung-Young", "eleanor.sungyoung@example.com"})
    |> bcc("shang.suyi@example.com")
    |> subject("Hello, People!")
    |> html_body("<h1>Hello</h1>")
    |> text_body("Hello")
    |> put_provider_option(:global_merge_vars, [
      %{"name" => "a", "content" => "b"},
      %{"name" => "c", "content" => "d"}
    ])
    |> put_provider_option(:merge_vars, [
      %{"rcpt" => "a@example.com", "vars" => %{"name" => "a", "content" => "b"}},
      %{"rcpt" => "b@example.com", "vars" => %{"name" => "b", "content" => "b"}},
    ])
    |> put_provider_option(:merge_language, "mailchimp")
    |> put_provider_option(:metadata, %{"website" => "www.example.com"})
    |> put_provider_option(:template_name, "welcome-user")
    |> put_provider_option(:template_content, [%{"name" => "a", "content" => "b"}])
    |> put_provider_option(:subaccount, "subaccount-x")
    |> put_provider_option(:tags, ["tag-1", "tag-2"])

## Provider options

  * `:global_merge_vars` (list[map]) - a list of maps of `:name` and
    `:content` global variables for all recipients

  * `:merge_language` (string) - merge tag language to use when evaluating
    merge tags, and possible values are `mailchimp` or `handlebars`

  * `:merge_vars` (list[map]) - a list of maps of `:rcpt` and `vars` for each
    recipient, which will override `:global_merge_vars`

  * `:metadata` (map) - a map of up to 10 fields for a user metadata

  * `:template_content` (list[map]) - a list of maps of `:name` and
    `:content` to be sent within a template

  * `:template_name` (string) - a name or slug of the template that belongs to a
    user

  * `:subaccount` (string) - the unique id of a subaccount for this message

  * `:tags` (list[string]) - a list of strings to tag the message with

  * `:return_path_domain` (string) - a custom domain to use for the message's return-path

  * `:tracking_domain` (string) - a custom domain to use for tracking opens and clicks
    instead of mandrillapp.com

## Template-configured 'from' address

Mandrill templates allow you to configure the 'from' address in the template itself.
To use the 'from' fields configured in the template, rather than specifying the value
explicitly, you can set

  |> from("TEMPLATE")