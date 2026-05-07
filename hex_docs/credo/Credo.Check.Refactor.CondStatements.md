# Credo.Check.Refactor.CondStatements

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Each cond statement should have 3 or more statements including the
"always true" statement.

Consider an `if`/`else` construct if there is only one condition and the
"always true" statement, since it will more accessible to programmers
new to the codebase (and possibly new to Elixir).

Example:

    cond do
      x == y -> 0
      true -> 1
    end

    # should be written as

    if x == y do
      0
    else
      1
    end



## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).