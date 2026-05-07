# Credo.Check.Refactor.MapMap

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

One `Enum.map/2` is more efficient than `Enum.map/2 |> Enum.map/2`.

This should be refactored:

    [:a, :b, :c]
    |> Enum.map(&inspect/1)
    |> Enum.map(&String.upcase/1)

to look like this:

    Enum.map([:a, :b, :c], fn letter ->
      letter
      |> inspect()
      |> String.upcase()
    end)

The reason for this is performance, because the two separate calls
to `Enum.map/2` require two iterations whereas doing the functions
in the single `Enum.map/2` only requires one.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).