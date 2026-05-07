# Credo.Check.Readability.TrailingBlankLine

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:formatter` {: .info}
>
> This means you can disable this check when also using Elixir's formatter.

This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Files should end in a trailing blank line.

This is mostly for historical reasons: every text file should end with a \n,
or newline since this acts as `eol` or the end of the line character.

See also: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_206

Most text editors ensure this "final newline" automatically.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).