# Swoosh.X.TestAssertions

Experimental New TestAssertions Module that may replace the old new in v2.

This module contains a set of assertions functions that you can import in your
test cases.

It is meant to be used with the
[Swoosh.Adapters.Test](Swoosh.Adapters.Test.html) module.

**Note**: `Swoosh.X.TestAssertions` works for unit tests and basic integration tests.
Using it with `Swoosh.Adapters.Test` is not going to work for feature/E2E tests.
The mechanism of `assert_email_sent` is based on messaging sending between processes,
and is expecting the calling process (the one that calls `assert_email_sent`) to be
the calling process of `Mailer.deliver`, or be the parent process of the whatever
does the `Mailer.deliver` call.

For feature/E2E tests, prefer
[Swoosh.Adapters.Sandbox](Swoosh.Adapters.Sandbox.html) so
`assert_email_sent` continues to work across separate processes.
Alternatively, you can use `Swoosh.Adapters.Local` and inspect the local
adapter mailbox directly.

## assert_email_not_sent(email)

Asserts `email` was not sent.

Performs exact matching of the email struct.

## assert_email_sent()

Asserts any email was sent.

## assert_email_sent(email)

Asserts `email` was sent.

You can pass a keyword list to match on specific params
or an anonymous function that returns a boolean.

## Examples

    iex> alias Swoosh.Email
    iex> import Swoosh.X.TestAssertions

    iex> email = Email.new(subject: "Hello, Avengers!")
    iex> Swoosh.Adapters.Test.deliver(email, [])

    # assert a specific email was sent
    iex> assert_email_sent(email)

    # assert an email with specific field(s) was sent
    iex> assert_email_sent(subject: "Hello, Avengers!")

    # assert an email that satisfies a condition
    iex> assert_email_sent(fn email ->
    ...>   assert length(email.to) == 2
    ...> end)

## assert_emails_sent()

Asserts multiple emails were sent.

You can pass a list of maps to match on specific params per email

## Examples

    iex> alias Swoosh.Email
    iex> import Swoosh.TestAssertions

    iex> emails = Enum.map(1..2, fn n -> Email.new(subject: "Hello, Avengers #{n}!") end)
    iex> Swoosh.Adapters.Test.deliver_many(emails, [])

    # assert a specific email was sent
    iex> assert_emails_sent(emails)

    # assert the list of emails with specific field(s) that were sent
    iex> assert_email_sent([
      %{subject: "Hello, Avengers 1!"},
      %{subject: "Hello, Avengers 2!"},
    ])

## assert_no_email_sent()

Asserts no emails were sent.

## flush_emails()

Removes and returns from mailbox all sent emails.

## refute_email_sent()

Asserts no emails were sent.

## refute_email_sent(email)

Asserts email with `attributes` was not sent.

You can pass a keyword list to match on specific params
or an anonymous function that returns a boolean.

## set_swoosh_global(context \\ %{})

Sets Swoosh test adapter to global mode.

In global mode, emails are consumed by the current test process,
doesn't matter which process sent it.

An ExUnit case where tests use Swoosh in global mode cannot be `async: true`.

## Examples

    defmodule MyTest do
      use ExUnit.Case, async: false

      import Swoosh.Email
      import Swoosh.X.TestAssertions

      setup :set_swoosh_global

      test "it sends email" do
        # ...
        assert_email_sent(subject: "Hi Avengers!")
      end
    end