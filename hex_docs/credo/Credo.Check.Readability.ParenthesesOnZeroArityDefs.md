# Credo.Check.Readability.ParenthesesOnZeroArityDefs

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Either use parentheses or not when defining a function with no arguments.

By default, this check enforces no parentheses, so zero-arity function
and macro definitions should look like this:

    def summer? do
      # ...
    end

If the `:parens` param is set to `true` for this check, then the check
enforces zero-arity function and macro definitions to have parens:

    def summer?() do
      # ...
    end

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).