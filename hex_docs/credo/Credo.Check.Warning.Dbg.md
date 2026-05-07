# Credo.Check.Warning.Dbg

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and requires Elixir `>= 1.14.0-dev`.

## Explanation

Calls to dbg/0 and dbg/2 should mostly be used during debugging sessions.

This check warns about those calls, because they probably have been committed
in error.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).