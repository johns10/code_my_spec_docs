# Credo.Check.Refactor.DoubleBooleanNegation

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Having double negations in your code can obscure the parameter's original value.

    # NOT preferred

    !!var

This will return `false` for `false` and `nil`, and `true` for anything else.

At first this seems like an extra clever shorthand to cast anything truthy to
`true` and anything non-truthy to `false`. But in most scenarios you want to
be explicit about your input parameters (because it is easier to reason about
edge-cases, code-paths and tests).
Also: `nil` and `false` do mean two different things.

A scenario where you want this kind of flexibility, however, is parsing
external data, e.g. a third party JSON-API where a value is sometimes `null`
and sometimes `false` and you want to normalize that before handing it down
in your program.

In these case, you would be better off making the cast explicit by introducing
a helper function:

    # preferred

    defp present?(nil), do: false
    defp present?(false), do: false
    defp present?(_), do: true

This makes your code more explicit than relying on the implications of `!!`.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).