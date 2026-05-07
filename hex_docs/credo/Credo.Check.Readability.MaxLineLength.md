# Credo.Check.Readability.MaxLineLength

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:formatter` {: .info}
>
> This means you can disable this check when also using Elixir's formatter.

This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Checks for the length of lines.

Ignores function definitions and (multi-)line strings by default.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:max_length`

  The maximum number of characters a line may consist of.

*This parameter defaults to* `120`.

### `:ignore_definitions`

  Set to `true` to ignore lines including function definitions.

*This parameter defaults to* `true`.

### `:ignore_specs`

  Set to `true` to ignore lines including `@spec`s.

*This parameter defaults to* `false`.

### `:ignore_sigils`

  Set to `true` to ignore lines that are sigils, e.g. regular expressions.

*This parameter defaults to* `true`.

### `:ignore_strings`

  Set to `true` to ignore lines that are strings or in heredocs.

*This parameter defaults to* `true`.

### `:ignore_urls`

  Set to `true` to ignore lines that contain urls.

*This parameter defaults to* `true`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).