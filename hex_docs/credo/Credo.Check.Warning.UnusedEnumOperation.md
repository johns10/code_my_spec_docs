# Credo.Check.Warning.UnusedEnumOperation

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

With the exception of `Enum.each/2`, the result of a call to the
Enum module's functions has to be used.

While this is correct ...

    def prepend_my_username(my_username, usernames) do
      usernames = Enum.reject(usernames, &is_nil/1)

      [my_username] ++ usernames
    end

... we forgot to save the downcased username in this example:

    # This is bad because it does not modify the usernames variable!

    def prepend_my_username(my_username, usernames) do
      Enum.reject(usernames, &is_nil/1)

      [my_username] ++ usernames
    end

Since Elixir variables are immutable, Enum operations never work on the
variable you pass in, but return a new variable which has to be used somehow
(the exception being `Enum.each/2` which iterates a list and returns `:ok`).


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).