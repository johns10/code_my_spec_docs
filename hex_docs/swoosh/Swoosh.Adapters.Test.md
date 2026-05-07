# Swoosh.Adapters.Test

An adapter that sends emails as messages to the current process.

This is meant to be used during tests and works with the assertions found in
the [Swoosh.TestAssertions](Swoosh.TestAssertions.html) module.

For feature, browser, and E2E tests where the email is delivered from
request-handling or LiveView processes, use the
[Swoosh.Adapters.Sandbox](Swoosh.Adapters.Sandbox.html) adapter instead.

## Example

    # config/test.exs
    config :sample, Sample.Mailer,
      adapter: Swoosh.Adapters.Test

    # lib/sample/mailer.ex
    defmodule Sample.Mailer do
      use Swoosh.Mailer, otp_app: :sample
    end