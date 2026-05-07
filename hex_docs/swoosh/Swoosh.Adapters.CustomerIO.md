# Swoosh.Adapters.CustomerIO

An adapter that sends email using the CustomerIO API.

For reference: [CustomerIO API docs](https://customer.io/docs/api/#tag/Transactional)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.CustomerIO,
      api_key: "my-api-key"

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

You can also change the API host, which defaults to `https://api.customer.io/v1`. For example, if
your Customer.io account is configured to use their EU datacenter:

    # config/config.exs
    config :sample, Sample.Mailer,
      base_url: "https://api-eu.customer.io/v1"

This can also be provided to `deliver/2` on a case-by-case basis.

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
    |> put_provider_option(:disable_css_preprocessing, true)
    |> put_provider_option(:disable_message_retention, true)
    |> put_provider_option(:fake_bcc, true)
    |> put_provider_option(:message_data, %{
      my_var: %{my_message_id: 123},
      my_other_var: %{my_other_id: 1, stuff: 2}
    })
    |> put_provider_option(:preheader, "this is the preview")
    |> put_provider_option(:queue_draft, true)
    |> put_provider_option(:send_at, 1617260400)
    |> put_provider_option(:send_to_unsubscribed, true)
    |> put_provider_option(:tracked, false)
    |> put_provider_option(:transactional_message_id, 44)


## Provider Options

Supported provider options are the following:

#### Inserted into request body

  * `:disable_css_preprocessing` (boolean) - Set to true to disable CSS preprocessing.
     This setting overrides the CSS preprocessing setting on the transactional_message_id
     as set in the user interface. Transactional emails have CSS preprocessing enabled by
     default.

  * `:disable_message_retention` (boolean) - If true, the message body is not
    retained in delivery history. Setting this value overrides the value set
    in the settings of your transactional_message_id.

  * `:identifiers` (map) - Identifies the person represented by your transactional
    message by one of, and only one of, id, email, or cio_id.

  * `:fake_bcc` (boolean) - If true, rather than sending true copies to BCC
    addresses, Customer.io sends a copy of the message with the subject line
    containing the recipient address(es).

  * `:message_data` (map) - An object containing the key-value pairs referenced
      using liquid in your message, see `:transactional_message_id`.

  * `:preheader` (string) - Also known as "preview text", this is the block of
    text that users see next to, or underneath, the subject line in their inbox.

  * `:queue_draft` (boolean) - If true, your transactional message is held as
    a draft in Customer.io and not sent directly to your audience. You must go
    to the Deliveries and Drafts page to send your message.

  * `:send_at` (integer) - A unix timestamp determining when the message will be sent.
    The timestamp can be up to 90 days in the future. If this value is in the past,
    your message is sent immediately.

  * `:send_to_unsubscribed` (boolean) - If false, your message is not sent to
    unsubscribed recipients. Setting this value overrides the value set in the
    settings of your transactional_message_id.

  * `:tracked` (boolean) - If true, Customer.io tracks opens and link clicks
    in your message.

  * `:transactional_message_id` (integer or string) - The transactional message template that
    you want to use for your message. You can call the template by its numerical ID
    or by the Trigger Name that you assigned the template (case insensitive).

## Using a template

You can use a template by setting the `from` field to `TEMPLATE`. This will let you set the `from`
address within Customer.io instead of hard-coding it in your code.

    import Swoosh.Email

    new()
    |> from("TEMPLATE")
    |> to({"Katy", "katy@example.com"})
    |> subject("Hello, Ten Rings!")
    |> html_body("<h1>Hello</h1>")
    |> text_body("Hello")
    |> put_provider_option(:transactional_message_id, "my-template-id")