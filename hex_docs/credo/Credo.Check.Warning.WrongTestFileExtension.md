# Credo.Check.Warning.WrongTestFileExtension

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Invoking mix test from the command line will run the tests in each file
matching the pattern `*_test.exs` found in the test directory of your project.

(from the `ex_unit` docs)

This check ensures that test files are not ending with `_test.ex` (which would cause them to be skipped).


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).