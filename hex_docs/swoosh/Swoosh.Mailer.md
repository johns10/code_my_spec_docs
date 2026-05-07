# Swoosh.Mailer

Defines a mailer.

A mailer is a wrapper around an adapter that makes it easy for you to swap the
adapter without having to change your code.

It is also responsible for doing some sanity checks before handing down the
email to the adapter.

When used, the mailer expects `:otp_app` as an option.
The `:otp_app` should point to an OTP application that has the mailer
configuration. For example, the mailer:

    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

Could be configured with:

    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Sendgrid,
      api_key: "SG.x.x"

Most of the configuration that goes into the config is specific to the adapter,
so check the adapter's documentation for more information.

Per module configuration is also supported, it has priority over mix configs:

    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample,
        adapter: Swoosh.Adapters.Sendgrid,
        api_key: "SG.x.x"
    end

## Usage

Once configured you can use your mailer like this:

    # in an IEx console
    iex> email = new |> from("tony.stark@example.com") |> to("steve.rogers@example.com")
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, ...}
    iex> Mailer.deliver(email)
    {:ok, %{...}}

## Dynamic config

You can also pass an extra config argument to `deliver/2` that will be merged
with your Mailer's config:

    # in an IEx console
    iex> email = new |> from("tony.stark@example.com") |> to("steve.rogers@example.com")
    %Swoosh.Email{from: {"", "tony.stark@example.com"}, ...}
    iex> Mailer.deliver(email, domain: "jarvis.com")
    {:ok, %{...}}

## Telemetry

Each mailer outputs the following telemetry events:

- `[:swoosh, :deliver, :start]`: occurs when `Mailer.deliver/2` begins.
- `[:swoosh, :deliver, :stop]`: occurs when `Mailer.deliver/2` completes.
- `[:swoosh, :deliver, :exception]`: occurs when `Mailer.deliver/2` throws an exception.
- `[:swoosh, :deliver_many, :start]`: occurs when `Mailer.deliver_many/2` begins.
- `[:swoosh, :deliver_many, :stop]`: occurs when `Mailer.deliver_many/2` completes.
- `[:swoosh, :deliver_many, :exception]`: occurs when `Mailer.deliver_many/2` throws an exception.

### Capturing events

You can capture events by calling `:telemetry.attach/4` or `:telemetry.attach_many/4`. Here's an example:

    # tracks the number of emails sent successfully/errored
    defmodule MyHandler do
      def handle_event([:swoosh, :deliver, :stop], _measurements, metadata, _config) do
        if Map.get(metadata, :error) do
          StatsD.increment("mail.sent.failure", 1, %{mailer: metadata.mailer})
        else
          StatsD.increment("mail.sent.success", 1, %{mailer: metadata.mailer})
        end
      end

      def handle_event([:swoosh, :deliver, :exception], _measurements, metadata, _config) do
        StatsD.increment("mail.sent.failure", 1, %{mailer: metadata.mailer})
      end

      def handle_event([:swoosh, :deliver_many, :stop], _measurements, metadata, _config) do
        if Map.get(metadata, :error) do
          StatsD.increment("mail.sent.failure", length(metadata.emails), %{mailer: metadata.mailer})
        else
          StatsD.increment("mail.sent.success", length(metadata.emails), %{mailer: metadata.mailer})
        end
      end

      def handle_event([:swoosh, :deliver_many, :exception], _measurements, metadata, _config) do
        StatsD.increment("mail.sent.failure", length(metadata.emails), %{mailer: metadata.mailer})
      end
    end

in `c:Application.start/2` callback:

    :telemetry.attach_many("my-handler", [
       [:swoosh, :deliver, :stop],
       [:swoosh, :deliver, :exception],
       [:swoosh, :deliver_many, :stop],
       [:swoosh, :deliver_many, :exception],
     ], &MyHandler.handle_event/4, nil)

## deliver(email, config)

Delivers an email.

## deliver_many(emails, config)

The implementation for `deliver_many/2` is on case-by-case basis. Check the adapter that you use
to see if it has `deliver_many/2` implemented.