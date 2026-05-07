# Credo.Check.Consistency.UnusedVariableNames

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Elixir allows us to use `_` as a name for variables that are not meant to be
used. But it’s a common practice to give these variables meaningful names
anyway (`_user` instead of `_`), but some people prefer to name them all anonymously (`_`).

A single style should be present in the same codebase.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:force`

  Force a choice, values can be `:meaningful` or `:anonymous`.

*This parameter defaults to* `nil`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).