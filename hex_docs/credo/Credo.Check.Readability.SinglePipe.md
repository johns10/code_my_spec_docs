# Credo.Check.Readability.SinglePipe

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Pipes (`|>`) should only be used when piping data through multiple calls.

So while this is fine:

    list
    |> Enum.take(5)
    |> Enum.shuffle
    |> evaluate()

The code in this example ...

    list
    |> evaluate()

... should be refactored to look like this:

    evaluate(list)

Using a single |> to invoke functions makes the code harder to read. Instead,
write a function call when a pipeline is only one function long.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:allow_0_arity_functions`

  Allow 0-arity functions

*This parameter defaults to* `false`.

### `:allow_blocks`

  Allow block functions/macro like `for`, `if` or `case`

*This parameter defaults to* `true`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).