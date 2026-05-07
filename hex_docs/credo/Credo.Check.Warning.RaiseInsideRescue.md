# Credo.Check.Warning.RaiseInsideRescue

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Using `Kernel.raise` inside of a `rescue` block creates a new stacktrace.

Most of the time, this is not what you want to do since it obscures the cause of the original error.

Example:

    # preferred

    try do
      raise "oops"
    rescue
      error ->
        Logger.warn("An exception has occurred")

        reraise error, System.stacktrace
    end

    # NOT preferred

    try do
      raise "oops"
    rescue
      error ->
        Logger.warn("An exception has occurred")

        raise error
    end


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).