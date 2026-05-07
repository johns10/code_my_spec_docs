# Credo.Check.Readability.Semicolons

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:formatter` {: .info}
>
> This means you can disable this check when also using Elixir's formatter.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Don't use ; to separate statements and expressions.
Statements and expressions should be separated by lines.

    # preferred

    a = 1
    b = 2

    # NOT preferred

    a = 1; b = 2

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).