# Credo.Check.Refactor.RedundantWithClauseResult

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

`with` statements are useful when you need to chain a sequence
of pattern matches, stopping at the first one that fails.

If the match of the last clause in a `with` statement is identical to the expression in the
in its body, the code should be refactored to remove the redundant expression.

This should be refactored:

    with {:ok, map} <- check(input),
         {:ok, result} <- something(map) do
      {:ok, result}
    end

to look like this:

    with {:ok, map} <- check(input) do
      something(map)
    end


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).