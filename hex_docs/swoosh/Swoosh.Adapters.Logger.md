# Swoosh.Adapters.Logger

An adapter that only logs email using Logger.

It can be useful in environments where you do not necessarily want to send real
emails (eg. staging environments) or in development.

By default it only prints the recipient of the email but you can print the full
email by using `log_full_email: true` in the adapter configuration.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Logger,
      level: :debug

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end