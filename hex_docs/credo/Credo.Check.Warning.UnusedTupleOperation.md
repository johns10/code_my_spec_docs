# Credo.Check.Warning.UnusedTupleOperation

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

The result of a call to the Tuple module's functions has to be used.

While this is correct ...

    def remove_magic_item!(tuple) do
      tuple = Tuple.delete_at(tuple, 0)

      if Enum.length(tuple) == 0, do: raise "OMG!!!1"

      tuple
    end

... we forgot to save the result in this example:

    def remove_magic_item!(tuple) do
      Tuple.delete_at(tuple, 0)

      if Enum.length(tuple) == 0, do: raise "OMG!!!1"

      tuple
    end

Tuple operations never work on the variable you pass in, but return a new
variable which has to be used somehow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).