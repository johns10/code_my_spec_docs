# Credo.Check.Warning.UnusedListOperation

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

The result of a call to the List module's functions has to be used.

While this is correct ...

    def sort_usernames(usernames) do
      usernames = List.flatten(usernames)

      List.sort(usernames)
    end

... we forgot to save the result in this example:

    def sort_usernames(usernames) do
      List.flatten(usernames)

      List.sort(usernames)
    end

List operations never work on the variable you pass in, but return a new
variable which has to be used somehow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).