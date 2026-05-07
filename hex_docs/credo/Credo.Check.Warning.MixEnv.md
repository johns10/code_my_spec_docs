# Credo.Check.Warning.MixEnv

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Mix is a build tool and, as such, it is not expected to be available in production.
Therefore, it is recommended to access Mix.env only in configuration files and inside
mix.exs, never in your application code (lib).

(from the Elixir docs)


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:excluded_paths`

  List of paths or regex to exclude from this check

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).