# Credo.Check.Refactor.FunctionArity

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

A function can take as many parameters as needed, but even in a functional
language there can be too many parameters.

Can optionally ignore private functions (check configuration options).


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:max_arity`

  The maximum number of parameters which a function should take.

*This parameter defaults to* `8`.

### `:ignore_defp`

  Set to `true` to ignore private functions.

*This parameter defaults to* `false`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).