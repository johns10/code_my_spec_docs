# Credo.Check.Readability.OnePipePerLine

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Don't use multiple pipes (|>) in the same line.
Each function in the pipe should be in it's own line.

    # preferred

    foo
    |> bar()
    |> baz()

    # NOT preferred

    foo |> bar() |> baz()

The code in this example ...

    1 |> Integer.to_string() |> String.to_integer()

... should be refactored to look like this:

    1
    |> Integer.to_string()
    |> String.to_integer()

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).