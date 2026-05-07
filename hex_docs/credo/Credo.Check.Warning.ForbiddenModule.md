# Credo.Check.Warning.ForbiddenModule

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Some modules that are included by a package may be hazardous
if used by your application. Use this check to allow these modules in
your dependencies but forbid them to be used in your application.

Examples:

The `:ecto_sql` package includes the `Ecto.Adapters.SQL` module,
but direct usage of the `Ecto.Adapters.SQL.query/4` function, and related functions, may
cause issues when using Ecto's dynamic repositories.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:modules`

  List of modules or `{Module, "Error message"}` tuples that must not be used.

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).