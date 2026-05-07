# Credo.Check.Refactor.NegatedConditionsInUnless

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Unless blocks should avoid having a negated condition.

The code in this example ...

    unless !allowed? do
      proceed_as_planned()
    end

... should be refactored to look like this:

    if allowed? do
      proceed_as_planned()
    end

The reason for this is not a technical but a human one. It is pretty difficult
to wrap your head around a block of code that is executed if a negated
condition is NOT met. See what I mean?


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).