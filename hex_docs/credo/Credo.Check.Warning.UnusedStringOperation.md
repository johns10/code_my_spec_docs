# Credo.Check.Warning.UnusedStringOperation

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

The result of a call to the String module's functions has to be used.

While this is correct ...

    def salutation(username) do
      username = String.downcase(username)

      "Hi #{username}"
    end

... we forgot to save the downcased username in this example:

    # This is bad because it does not modify the username variable!

    def salutation(username) do
      String.downcase(username)

      "Hi #{username}"
    end

Since Elixir variables are immutable, String operations never work on the
variable you pass in, but return a new variable which has to be used somehow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).