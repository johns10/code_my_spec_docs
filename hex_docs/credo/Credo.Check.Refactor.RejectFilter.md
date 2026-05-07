# Credo.Check.Refactor.RejectFilter

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `0` and works with any version of Elixir.

## Explanation

One `Enum.filter/2` is more efficient than `Enum.reject/2 |> Enum.filter/2`.

This should be refactored:

    ["a", "b", "c"]
    |> Enum.reject(&String.contains?(&1, "x"))
    |> Enum.filter(&String.contains?(&1, "a"))

to look like this:

    Enum.filter(["a", "b", "c"], fn letter ->
      !String.contains?(letter, "x") && String.contains?(letter, "a")
    end)

The reason for this is performance, because the two calls to
`Enum.reject/2` and `Enum.filter/2` require two iterations whereas
doing the functions in the single `Enum.filter/2` only requires one.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).