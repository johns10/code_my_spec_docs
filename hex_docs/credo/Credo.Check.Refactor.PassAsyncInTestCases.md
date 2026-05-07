# Credo.Check.Refactor.PassAsyncInTestCases

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `normal` and works with any version of Elixir.

## Explanation

Test modules marked `async: true` are run concurrently, speeding up the
test suite and improving productivity. This should always be done when
possible.

Leaving off the `async:` option silently defaults to `false`, which may make
a test suite slower for no real reason.

Test modules which cannot be run concurrently should be explicitly marked
`async: false`, ideally with a comment explaining why.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).