# Credo.Check.Refactor.MapInto

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and requires Elixir `< 1.8.0`.

## Explanation

`Enum.into/3` is more efficient than `Enum.map/2 |> Enum.into/2`.

This should be refactored:

    [:apple, :banana, :carrot]
    |> Enum.map(&({&1, to_string(&1)}))
    |> Enum.into(%{})

to look like this:

    Enum.into([:apple, :banana, :carrot], %{}, &({&1, to_string(&1)}))

The reason for this is performance, because the separate calls to
`Enum.map/2` and `Enum.into/2` require two iterations whereas
`Enum.into/3` only requires one.

**NOTE**: This check is only available in Elixir < 1.8 since performance
improvements have since made this check obsolete.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).