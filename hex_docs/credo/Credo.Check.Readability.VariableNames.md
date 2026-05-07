# Credo.Check.Readability.VariableNames

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Variable names are always written in snake_case in Elixir.

    # snake_case:

    incoming_result = handle_incoming_message(message)

    # not snake_case

    incomingResult = handle_incoming_message(message)

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).