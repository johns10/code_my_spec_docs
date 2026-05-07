# Credo.Check.Readability.Specs

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Functions, callbacks and macros need typespecs.

Adding typespecs gives tools like Dialyzer more information when performing
checks for type errors in function calls and definitions.

    @spec add(integer, integer) :: integer
    def add(a, b), do: a + b

Functions with multiple arities need to have a spec defined for each arity:

    @spec foo(integer) :: boolean
    @spec foo(integer, integer) :: boolean
    def foo(a), do: a > 0
    def foo(a, b), do: a > b

The check only considers whether the specification is present, it doesn't
perform any actual type checking.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:include_defp`

  Include private functions.

*This parameter defaults to* `false`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).