# Credo.Check.Warning.OperationWithConstantResult

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Some numerical operations always yield the same result and therefore make
little sense in production code.

Examples:

    x * 1   # always returns x
    x * 0   # always returns 0

In practice they are likely the result of a debugging session or were made by
mistake.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).