# Credo.Check.Warning.OperationOnSameValues

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Operations on the same values always yield the same result and therefore make
little sense in production code.

Examples:

    x == x  # always returns true
    x <= x  # always returns true
    x >= x  # always returns true
    x != x  # always returns false
    x > x   # always returns false
    y / y   # always returns 1
    y - y   # always returns 0

In practice they are likely the result of a debugging session or were made by
mistake.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).