# Swoosh.Adapters.Loops

An adapter that sends email using the Loops API.

For reference: [Loops API docs](https://loops.so/docs/api-reference/send-transactional-email)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Loops,
      api_key: "my-api-key"
    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with provider options

    import Swoosh.Email

    new()
    |> to("katy@example.com")
    |> from("IGNORED") # see note below
    |> put_provider_option(:data_variables, %{
        "name" => "Chris",
        "passwordResetLink" => "https://example.com/reset-password"
      })
    |> put_provider_option(:transactional_id, "clfq6dinn000yl70fgwwyp82l")

Note that we need to provide a `from` because it's required by Swoosh. This will
be ignored though, since Loops API doesn't support setting a sender.

## Provider Options

Supported provider options are the following:

#### Inserted into request payload

  * `:transactional_id` (string) - The ID of the transactional email to send.

  * `:add_to_audience?` (boolean) - If true, a contact will be created in your audience
    using the email value (if a matching contact doesn’t already exist). Disabled by
    default.

  * `:data_variables` (map) - An object containing data as defined by the data variables
    added to the transactional email template. Values can be of type string or number.