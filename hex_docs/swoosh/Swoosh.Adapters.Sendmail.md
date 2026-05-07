# Swoosh.Adapters.Sendmail

An adapter that sends email using the sendmail binary.

## Example

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Sendmail,
      cmd_path: "/usr/bin/sendmail",
      cmd_args: "-N delay,failure,success",
      qmail: true # Default false

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end