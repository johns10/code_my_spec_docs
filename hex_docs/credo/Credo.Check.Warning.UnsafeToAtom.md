# Credo.Check.Warning.UnsafeToAtom

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Creating atoms from unknown or external sources dynamically is a potentially
unsafe operation because atoms are not garbage-collected by the runtime.

Creating an atom from a string or charlist should be done by using

    String.to_existing_atom(string)

or

    List.to_existing_atom(charlist)

Module aliases should be constructed using

    Module.safe_concat(prefix, suffix)

or

    Module.safe_concat([prefix, infix, suffix])

Jason.decode/Jason.decode! should be called using `keys: :atoms!` (*not* `keys: :atoms`):

    Jason.decode(str, keys: :atoms!)

or `:keys` should be omitted (which defaults to `:strings`):

    Jason.decode(str)



## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).