# Credo.Check.Refactor.PipeChainStart

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Pipes (`|>`) can become more readable by starting with a "raw" value.

So while this is easily comprehendable:

    list
    |> Enum.take(5)
    |> Enum.shuffle
    |> pick_winner()

This might be harder to read:

    Enum.take(list, 5)
    |> Enum.shuffle
    |> pick_winner()

As always: This is just a suggestion. Check the configuration options for
tweaking or disabling this check.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:excluded_functions`

  All functions listed will be ignored.

*This parameter defaults to* `[]`.

### `:excluded_argument_types`

  All pipes with argument types listed will be ignored.

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).