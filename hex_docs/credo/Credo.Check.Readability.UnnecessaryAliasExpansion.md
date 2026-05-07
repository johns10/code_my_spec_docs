# Credo.Check.Readability.UnnecessaryAliasExpansion

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Alias expansion is useful but when aliasing a single module,
it can be harder to read with unnecessary braces.

    # preferred

    alias ModuleA.Foo
    alias ModuleA.{Foo, Bar}

    # NOT preferred

    alias ModuleA.{Foo}

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).