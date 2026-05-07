# Credo.Check.Refactor.UtcNowTruncate

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

`DateTime.utc_now/1` is more efficient than `DateTime.utc_now/0 |> DateTime.truncate/1`.

For example, the code here ...

    DateTime.utc_now() |> DateTime.truncate(:second)
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

... can be refactored to look like this:

    DateTime.utc_now(:second)
    NaiveDateTime.utc_now(:second)

The reason for this is not just performance, because no separate function
call is required, but also brevity of the resulting code.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).