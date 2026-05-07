# Swoosh.Adapters.ProtonBridge

An adapter that sends email using the local Protonmail Bridge.

This is a very thin wrapper around the SMTP adapter.

Underneath this adapter uses the
[gen_smtp](https://github.com/Vagabond/gen_smtp) library, add it to your mix.exs file.

## Example

    # mix.exs
    def deps do
      [
        {:swoosh, "~> 1.3"},
        {:gen_smtp, "~> 1.1"}
      ]
    end

    # config/config.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.ProtonBridge,
      username: "tonystark",
      password: "ilovepepperpotts",

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

### SMTP

You can send emails with Protonmail SMTP service via the following SMTP configs,
using `Swoosh.Adapters.SMTP` adapter.

    [
      relay: "smtp.protonmail.ch",
      ssl: false,
      tls: :always,
      auth: :always,
      port: 587,
      retries: 1,
      no_mx_lookups: false
    ]

This bridge adapter provides a special set of configs that utilize the local Protonmail Bridge.