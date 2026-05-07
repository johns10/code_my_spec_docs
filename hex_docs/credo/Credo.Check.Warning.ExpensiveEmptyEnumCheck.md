# Credo.Check.Warning.ExpensiveEmptyEnumCheck

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Checking if the size of the enum is `0` (or not `0`) can be very expensive,
since you are determining the exact count of elements.

Checking if an enum is empty should be done by using

    Enum.empty?(enum)

or

    list == []


For `Enum.count/2`: Checking if an enum doesn't contain specific elements should
be done by using

    not Enum.any?(enum, condition)



## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).