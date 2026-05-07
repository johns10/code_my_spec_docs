# Credo.Check.Readability.LargeNumbers

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:formatter` {: .info}
>
> This means you can disable this check when also using Elixir's formatter.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Numbers can contain underscores for readability purposes.
These do not affect the value of the number, but can help read large numbers
more easily.

    141592654 # how large is this number?

    141_592_654 # ah, it's in the hundreds of millions!

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:only_greater_than`

  The check only reports numbers greater than this.

*This parameter defaults to* `9999`.

### `:trailing_digits`

  The check allows for the given number of trailing digits (can be a number, range or list)

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).