# Credo.Check.Refactor.AppendSingleItem

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `low` and works with any version of Elixir.

## Explanation

When building up large lists, it is faster to prepend than
append. Therefore: It is sometimes best to prepend to the list
during iteration and call Enum.reverse/1 at the end, as it is quite
fast.

Example:

    list = list_so_far ++ [new_item]

    # refactoring it like this can make the code faster:

    list = [new_item] ++ list_so_far
    # ...
    Enum.reverse(list)



## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).