# Credo.Check.Refactor.MapJoin

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

`Enum.map_join/3` is more efficient than `Enum.map/2 |> Enum.join/2`.

This should be refactored:

    ["a", "b", "c"]
    |> Enum.map(&String.upcase/1)
    |> Enum.join(", ")

to look like this:

    Enum.map_join(["a", "b", "c"], ", ", &String.upcase/1)

The reason for this is performance, because the two separate calls
to `Enum.map/2` and `Enum.join/2` require two iterations whereas
`Enum.map_join/3` performs the same work in one pass.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).