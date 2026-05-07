# Credo.Check.Warning.UnusedFileOperation

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

The result of a call to the File module's functions has to be used.

While this is correct ...

    def read_from_cwd(filename) do
      # TODO: use Path.join/2
      filename = File.cwd!() <> "/" <> filename

      File.read(filename)
    end

... we forgot to save the result in this example:

    def read_from_cwd(filename) do
      File.cwd!() <> "/" <> filename

      File.read(filename)
    end

Since Elixir variables are immutable, many File operations don't work on the
variable you pass in, but return a new variable which has to be used somehow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).