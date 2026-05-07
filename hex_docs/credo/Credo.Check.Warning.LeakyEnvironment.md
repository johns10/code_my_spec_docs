# Credo.Check.Warning.LeakyEnvironment

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

OS child processes inherit the environment of their parent process. This
includes sensitive configuration parameters, such as credentials. To
minimize the risk of such values leaking, clear or overwrite them when
spawning executables.

The functions `System.cmd/2` and `System.cmd/3` allow environment variables be cleared by
setting their value to `nil`:

    System.cmd("env", [], env: %{"DB_PASSWORD" => nil})



## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).