# Credo.Check.Readability.PredicateFunctionNames

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Predicate functions/macros should be named accordingly:

* For functions, they should end in a question mark.

      # preferred

      defp user?(cookie) do
      end

      defp has_attachment?(mail) do
      end

      # NOT preferred

      defp is_user?(cookie) do
      end

      defp is_user(cookie) do
      end

* For guard-safe macros they should have the prefix `is_` and not end in a question mark.

      # preferred

      defmacro is_user(cookie) do
      end

      # NOT preferred

      defmacro is_user?(cookie) do
      end

      defmacro user?(cookie) do
      end

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).