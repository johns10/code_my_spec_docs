# Swoosh.Adapters.SparkPost

An adapter that sends email using the SparkPost API.

For reference: [SparkPost API docs](https://developers.sparkpost.com/api/)

**This adapter requires an API Client.** Swoosh comes with Hackney, Finch and Req out of the box.
See the [installation section](https://hexdocs.pm/swoosh/Swoosh.html#module-installation)
for details.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.SparkPost,
      api_key: "my-api-key",
      endpoint: "https://api.sparkpost.com/api/v1"
      # or "https://YOUR_DOMAIN.sparkpostelite.com/api/v1" for enterprise

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Using with SparkPost templates

    import Swoosh.Email

    new()
    |> from("tony.stark@example.com")
    |> to("steve.rogers@example.com")
    |> subject("Hello, Avengers!")
    |> put_provider_option(:template_id, "my-first-email")
    |> put_provider_option(:substitution_data, %{
      first_name: "Peter",
      last_name: "Parker"
    })

## Setting SparkPost transmission options

Full options can be found at [SparkPost Transmissions API Docs](https://developers.sparkpost.com/api/transmissions/#header-request-body)

    import Swoosh.Email

    new()
    |> from("tony.stark@example.com")
    |> to("steve.rogers@example.com")
    |> subject("Hello, Avengers!")
    |> put_provider_option(:options, %{
      click_tracking: false,
      open_tracking: false,
      transactional: true,
      inline_css: true
    })

## Provider Options

  * `:options` (map) - customization on how the email is sent

  * `:template_id` (string) - id of the template to use

  * `:substitution_data` (map) - data passed to the template language in
    the content, and take precedence over the other data like `:metadata`