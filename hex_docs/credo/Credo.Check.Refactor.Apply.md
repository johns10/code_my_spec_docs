# Credo.Check.Refactor.Apply

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Prefer calling functions directly if the number of arguments is known
at compile time instead of using `apply/2` and `apply/3`.

Example:

    # preferred

    fun.(arg_1, arg_2, ..., arg_n)

    module.function(arg_1, arg_2, ..., arg_n)

    # NOT preferred

    apply(fun, [arg_1, arg_2, ..., arg_n])

    apply(module, :function, [arg_1, arg_2, ..., arg_n])


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).