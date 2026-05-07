# Credo.Check.Readability.FunctionNames

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Function, macro, and guard names are always written in snake_case in Elixir.

    # snake_case

    def handle_incoming_message(message) do
    end

    # not snake_case

    def handleIncomingMessage(message) do
    end

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:allow_acronyms`

  Allows acronyms like HTTP or OTP in function names.

*This parameter defaults to* `false`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).