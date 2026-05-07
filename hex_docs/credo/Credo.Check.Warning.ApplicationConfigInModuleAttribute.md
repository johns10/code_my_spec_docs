# Credo.Check.Warning.ApplicationConfigInModuleAttribute

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Module attributes are evaluated at compile time and not at run time. As
a result, certain configuration read calls made in your module attributes
may work as expected during local development, but may break once in a
deployed context.

This check analyzes all of the module attributes present within a module,
and validates that there are no unsafe calls.

These unsafe calls include:

- `Application.fetch_env/2`
- `Application.fetch_env!/2`
- `Application.get_all_env/1`
- `Application.get_env/3`
- `Application.get_env/2`

As of Elixir 1.10 you can leverage `Application.compile_env/3` and
`Application.compile_env!/2` if you wish to set configuration at
compile time using module attributes.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).