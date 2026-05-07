# Credo.Check.Readability.BlockPipe

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Pipes (`|>`) should not be used with blocks.

The code in this example ...

    list
    |> Enum.take(5)
    |> Enum.sort()
    |> case do
      [[_h | _t] | _] -> true
      _ -> false
    end

... should be refactored to look like this:

    maybe_nested_lists =
      list
      |> Enum.take(5)
      |> Enum.sort()

    case maybe_nested_lists do
      [[_h | _t] | _] -> true
      _ -> false
    end

... or create a new function:

    list
    |> Enum.take(5)
    |> Enum.sort()
    |> contains_nested_list?()

Piping to blocks may be harder to read because it can be said that it obscures intentions
and increases cognitive load on the reader. Instead, prefer introducing variables to your code or
new functions when it may be a sign that your function is getting too complicated and/or has too many concerns.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:exclude`

  Do not raise an issue for these macros and functions.

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).