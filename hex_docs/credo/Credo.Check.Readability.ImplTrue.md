# Credo.Check.Readability.ImplTrue

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `normal` and works with any version of Elixir.

## Explanation

`@impl true` is a shortform so you don't have to write the actual behaviour that is being implemented.
This can make code harder to comprehend.

# preferred

    @impl MyBehaviour
    def my_funcion() do
      # ...
    end

# NOT preferred

    @impl true
    def my_funcion() do
      # ...
    end

When implementing behaviour callbacks, `@impl true` indicates that a function implements a callback, but
a more explicit way is to use the actual behaviour being implemented, for example `@impl MyBehaviour`.

This not only improves readability, but adds extra validation in cases where multiple behaviours are
implemented in a single module.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).