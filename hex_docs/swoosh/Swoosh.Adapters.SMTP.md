# Swoosh.Adapters.SMTP

An adapter that sends email using the SMTP protocol.

Underneath this adapter uses the
[gen_smtp](https://github.com/gen-smtp/gen_smtp) library, add it to your mix.exs file.

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
      adapter: Swoosh.Adapters.SMTP,
      relay: "smtp.avengers.com",
      username: "tonystark",
      password: "ilovepepperpotts",
      ssl: true,
      tls: :always,
      auth: :always,
      port: 1025,
      dkim: [
        s: "default", d: "domain.com",
        private_key: {:pem_plain, File.read!("priv/keys/domain.private")}
      ],
      retries: 2,
      no_mx_lookups: false

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end

## Note

With `STARTTLS` you should omit the ssl configuration or set it to false.

For more details, please see [gen_smtp docs](https://hexdocs.pm/gen_smtp/readme.html)