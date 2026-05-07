# Credo.Check.Warning.BoolOperationOnSameValues

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Boolean operations with identical values on the left and right side are
most probably a logical fallacy or a copy-and-paste error.

Examples:

    x && x
    x || x
    x and x
    x or x

Each of these cases behaves the same as if you were just writing `x`.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).