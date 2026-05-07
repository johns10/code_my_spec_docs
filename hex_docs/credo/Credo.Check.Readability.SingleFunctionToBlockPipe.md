# Credo.Check.Readability.SingleFunctionToBlockPipe

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `0` and works with any version of Elixir.

## Explanation

A single pipe (`|>`) should not be used to pipe into blocks.

The code in this example ...

    list
    |> length()
    |> case do
      0 -> :none
      1 -> :one
      _ -> :many
    end

... should be refactored to look like this:

    case length(list) do
      0 -> :none
      1 -> :one
      _ -> :many
    end

If you want to disallow piping into blocks altogether, use
`Credo.Check.Readability.BlockPipe`.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).