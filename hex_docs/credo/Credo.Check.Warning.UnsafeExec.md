# Credo.Check.Warning.UnsafeExec

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Spawning external commands can lead to command injection vulnerabilities.

Use a safe API where arguments are passed as an explicit list, rather
than unsafe APIs that run a shell to parse the arguments from a single
string.

Safe APIs include:

  * `System.cmd/2,3`
  * `:erlang.open_port/2`, passing `{:spawn_executable, file_name}` as the
    first parameter, and any arguments using the `:args` option

Unsafe APIs include:

  * `:os.cmd/1,2`
  * `:erlang.open_port/2`, passing `{:spawn, command}` as the first
    parameter



## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).