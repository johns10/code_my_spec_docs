# Swoosh.TestAssertions

This module contains a set of assertions functions that you can import in your
test cases.

It is meant to be used with the
[Swoosh.Adapters.Test](Swoosh.Adapters.Test.html) module.

**Note**: `Swoosh.TestAssertions` works for unit tests and basic integration tests
when using `Swoosh.Adapters.Test`.

For feature/E2E tests, use `Swoosh.Adapters.Sandbox` instead.  The sandbox adapter
supports per-test process ownership and explicit allows, so `assert_email_sent`
works even when the delivering process (e.g. a Phoenix endpoint or LiveView) has
no `$callers` ancestry back to the test process.  See
`Swoosh.Adapters.Sandbox` for setup instructions.

Alternatively, you can use `Swoosh.Adapters.Local` and check the local adapter
mailbox or navigate to the preview URL with your E2E tool.

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
    iex> import Swoosh.TestAssertions

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
    iex> assert_emails_sent([
      %{subject: "Hello, Avengers 1!"},
      %{subject: "Hello, Avengers 2!"},
    ])

## assert_no_email_sent()

Asserts no emails were sent.

## set_swoosh_global(context \\ %{})

Sets Swoosh test adapter to global mode.

In global mode, emails are consumed by the current test process,
doesn't matter which process sent it.

An ExUnit case where tests use Swoosh in global mode cannot be `async: true`.

## Examples

    defmodule MyTest do
      use ExUnit.Case, async: false

      import Swoosh.Email
      import Swoosh.TestAssertions

      setup :set_swoosh_global

      test "it sends email" do
        # ...
        assert_email_sent(subject: "Hi Avengers!")
      end
    end

## refute_email_sent()

Asserts no emails were sent.

## refute_email_sent(attributes)

Asserts email with `attributes` was not sent.

Performs pattern matching using the given pattern, equivalent to `pattern = email`.

When a list of attributes is given, they will be converted to a pattern.

It converts list fields (`:to`, `:cc`, `:bcc`) to a single element list if a single value is
given (`to: "email@example.com"` => `to: ["email@example.com"]`).

After conversion, performs pattern matching using a map of email attributes, similar to
`%{attributes...} = email`.