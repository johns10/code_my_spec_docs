# Credo.Check.Readability.TrailingWhiteSpace

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:formatter` {: .info}
>
> This means you can disable this check when also using Elixir's formatter.

This check has a base priority of `low` and works with any version of Elixir.

## Explanation

There should be no white-space (i.e. tabs, spaces) at the end of a line.

Most text editors provide a way to remove them automatically.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:ignore_strings`

  Set to `false` to check lines that are strings or in heredocs

*This parameter defaults to* `true`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).