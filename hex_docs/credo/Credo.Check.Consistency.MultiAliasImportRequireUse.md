# Credo.Check.Consistency.MultiAliasImportRequireUse

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

When using alias, import, require or use for multiple names from the same
namespace, you have two options:

Use single instructions per name:

    alias Ecto.Query
    alias Ecto.Schema
    alias Ecto.Multi

or use one multi instruction per namespace:

    alias Ecto.{Query, Schema, Multi}

While this is not necessarily a concern for the correctness of your code,
you should use a consistent style throughout your codebase.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).