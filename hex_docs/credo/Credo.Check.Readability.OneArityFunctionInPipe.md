# Credo.Check.Readability.OneArityFunctionInPipe

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Use parentheses for one-arity functions when using the pipe operator (|>).

    # not preferred
    some_string |> String.downcase |> String.trim

    # preferred
    some_string |> String.downcase() |> String.trim()

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).