# Swoosh.Adapters.SocketLabs

An adapter that sends email using the SocketLabs Injection API.

For reference: [SocketLabs API docs](https://inject.docs.socketlabs.com/v1/documentation/introduction)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer
      adapter: Swoosh.Adapters.SocketLabs,
      server_id: "",
      api_key: ""

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with provider options

    import Swoosh.Email

    new()
    |> from({"Sisu", "sisu@example.com"})
    |> to("raya@example.com")
    |> put_provider_option(:api_template, "12345")
    |> put_provider_option(:charset, "12345")
    |> put_provider_option(:mailing_id, "12345")
    |> put_provider_option(:message_id, "12345")
    |> put_provider_option(:merge_data, %{
      "PerMessage" => %{
        "per_message1" => "value1",
        "per_message2" => "value2"
      },
      "Global" => %{
        "global1" => "value1",
        "global2" => "value2"
      }
    })

## Provider Options

  * `:api_template` (string) - `ApiTemplate`, identifier for a content in the
    Email Content Manager

  * `:charset` (string) - `Charset`, character set used when creating the
    email message and default to `UTF8`

  * `:mailing_id` (string) - special header used to track batches of email
    messages

  * `:message_id` (string) - special header used to track individual message

  * `:merge_data` (map) - data storage for inline Merge feature