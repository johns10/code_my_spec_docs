# Credo.Check.Refactor.UnlessWithElse

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

An `unless` block should not contain an else block.

So while this is fine:

    unless allowed? do
      raise "Not allowed!"
    end

This should be refactored:

    unless allowed? do
      raise "Not allowed!"
    else
      proceed_as_planned()
    end

to look like this:

    if allowed? do
      proceed_as_planned()
    else
      raise "Not allowed!"
    end

The reason for this is not a technical but a human one. The `else` in this
case will be executed when the condition is met, which is the opposite of
what the wording seems to imply.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).