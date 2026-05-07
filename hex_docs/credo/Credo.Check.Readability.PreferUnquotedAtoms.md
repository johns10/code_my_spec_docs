# Credo.Check.Readability.PreferUnquotedAtoms

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and requires Elixir `< 1.7.0-dev`.

## Explanation

Prefer unquoted atoms unless quotes are necessary.
This is helpful because a quoted atom can be easily mistaken for a string.

    # preferred

    :x
    [x: 1]
    %{x: 1}

    # NOT preferred

    :"x"
    ["x": 1]
    %{"x": 1}

The primary case where this can become an issue is when using atoms or
strings for keys in a Map or Keyword list.

For example, this:

    %{"x": 1}

Can easily be mistaken for this:

    %{"x" => 1}

Because a string key cannot be used to access a value with the equivalent
atom key, this can lead to subtle bugs which are hard to discover.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).