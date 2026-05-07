# Credo.Check.Readability.SpaceAfterCommas

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:formatter` {: .info}
>
> This means you can disable this check when also using Elixir's formatter.

This check has a base priority of `0` and works with any version of Elixir.

## Explanation

You can use white-space after commas to make items of lists,
tuples and other enumerations easier to separate from one another.

    # preferred

    alias Project.{Alpha, Beta}

    def some_func(first, second, third) do
      list = [1, 2, 3, 4, 5]
      # ...
    end

    # NOT preferred - items are harder to separate

    alias Project.{Alpha,Beta}

    def some_func(first,second,third) do
      list = [1,2,3,4,5]
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