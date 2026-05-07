# Credo.Check.Warning.SpecWithStruct

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `normal` and works with any version of Elixir.

## Explanation

Structs create compile-time dependencies between modules.  Using a struct in a spec
will cause the module to be recompiled whenever the struct's module changes.

It is preferable to define and use `MyModule.t()` instead of `%MyModule{}` in specs.

Example:

    # preferred
    @spec a_function(MyModule.t()) :: any

    # NOT preferred
    @spec a_function(%MyModule{}) :: any


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).