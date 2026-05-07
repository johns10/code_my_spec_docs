# Credo.Check.Consistency.SpaceAroundOperators

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:formatter` {: .info}
>
> This means you can disable this check when also using Elixir's formatter.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Use spaces around operators like `+`, `-`, `*` and `/`. This is the
**preferred** way, although other styles are possible, as long as it is
applied consistently.

    # preferred

    1 + 2 * 4

    # also okay

    1+2*4

While this is not necessarily a concern for the correctness of your code,
you should use a consistent style throughout your codebase.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:ignore`

  List of operators to be ignored for this check.

*This parameter defaults to* `[:|]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).