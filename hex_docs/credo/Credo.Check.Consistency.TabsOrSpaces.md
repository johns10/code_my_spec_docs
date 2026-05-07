# Credo.Check.Consistency.TabsOrSpaces

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:formatter` {: .info}
>
> This means you can disable this check when also using Elixir's formatter.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Tabs should be used consistently.

NOTE: This check does not verify the indentation depth, but checks whether
or not soft/hard tabs are used consistently across all source files.

It is very common to use 2 spaces wide soft-tabs, but that is not a strict
requirement and you can use hard-tabs if you like that better.

While this is not necessarily a concern for the correctness of your code,
you should use a consistent style throughout your codebase.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:force`

  Force a choice, values can be `:spaces` or `:tabs`.

*This parameter defaults to* `nil`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).