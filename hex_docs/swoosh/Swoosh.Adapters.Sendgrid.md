# Swoosh.Adapters.Sendgrid

An adapter that sends email using the Sendgrid API.

For reference: [Sendgrid API docs](https://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/index.html)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Sendgrid,
      api_key: "my-api-key",
      compress: true # default false

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

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
    |> put_provider_option(:custom_args, %{
      my_var: %{my_message_id: 123},
      my_other_var: %{my_other_id: 1, stuff: 2}
    })
    |> put_provider_option(:asm, %{
      "group_id" => 1,
      "groups_to_display" => [1, 2, 3]
    })
    |> put_provider_option(:categories, ["welcome"])
    |> put_provider_option(:mail_settings, %{
      sandbox_mode: %{enable: true}
    })
    |> put_provider_option(:tracking_settings, %{
      subscription_tracking: %{enable: false}
    })
    |> put_provider_option(:batch_id, "AsdFgHjklQweRTYuIopzXcVBNm0aSDfGHjklmZcVbNMqWert1znmOP2asDFjkl")
    |> put_provider_option(:ip_pool_name, "my-pool-name")
    |> put_provider_option(:send_at, 1617260400)

## Provider Options

Supported provider options are the following:

#### Inserted into personalization

  * `:custom_args` (map) - key/value pairs custom arguments that specific to
    this personalization

  * `:substitutions` (map) - key/value pairs of substitutions string applied
    to the `:subject` and `:reply-to` parameter

  * `:dynamic_template_data` (map) - key/value pairs of dynamic template data
    used in Dynamic Transactional Templates, see `:template_id`

#### Inserted into request body

  * `:template_id` (string) - an email template ID

  * `:asm` (map) - a map contains fields below on how to handle unsubscribes

  * `:categories` (list[string]) - list of category name for this message

  * `:mail_settings` (map) - collection of mail settings to handle this email

  * `:tracking_settings` (map) - collection of settings to track the metrics
    of responses of email recipients

  * `:send_at` (integer) - A unix timestamp allowing you to specify when
    you want your email to be delivered.

  * `:batch_id` (string) - An ID representing a batch of emails to be sent at
    the same time. It also enables you to cancel or pause the delivery of that batch

  * `:ip_pool_name` (string) - The name of the IP Pool you wish to send using

## Sandbox mode

For [sandbox mode](https://sendgrid.com/docs/for-developers/sending-email/sandbox-mode/), use `put_provider_option/3`:

    iex> new() |> put_provider_option(:mail_settings, %{sandbox_mode: %{enable: true}})