# Credo.Check.Consistency.LineEndings

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:formatter` {: .info}
>
> This means you can disable this check when also using Elixir's formatter.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Windows and Linux/macOS systems use different line-endings in files.

It seems like a good idea not to mix these in the same codebase.

While this is not necessarily a concern for the correctness of your code,
you should use a consistent style throughout your codebase.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:force`

  Force a choice, values can be `:unix` or `:windows`.

*This parameter defaults to* `nil`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).