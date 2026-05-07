# Credo.Check.Readability.NestedFunctionCalls

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `0` and works with any version of Elixir.

## Explanation

A function call should not be nested inside another function call.

So while this is fine:

    Enum.shuffle([1,2,3])

The code in this example ...

    Enum.shuffle(Enum.uniq([1,2,3,3]))

... should be refactored to look like this:

    [1,2,3,3]
    |> Enum.uniq()
    |> Enum.shuffle()

Nested function calls make the code harder to read. Instead, break the
function calls out into a pipeline.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:min_pipeline_length`

  Set a minimum pipeline length

*This parameter defaults to* `2`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).