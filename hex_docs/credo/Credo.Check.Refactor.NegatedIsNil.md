# Credo.Check.Refactor.NegatedIsNil

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `low` and works with any version of Elixir.

## Explanation

We should avoid negating the `is_nil` predicate function.

For example, the code here ...

    def fun(%{external_id: external_id, id: id}) when not is_nil(external_id) do
       # ...
    end

... can be refactored to look like this:

    def fun(%{external_id: nil, id: id}) do
      # ...
    end

    def fun(%{external_id: external_id, id: id}) do
      # ...
    end

... or even better, can match on what you were expecting on the first place:

    def fun(%{external_id: external_id, id: id}) when is_binary(external_id) do
      # ...
    end

    def fun(%{external_id: nil, id: id}) do
      # ...
    end

    def fun(%{external_id: external_id, id: id}) do
      # ...
    end

Similar to negating `unless` blocks, the reason for this check is not
technical, but a human one. If we can use the positive, more direct and human
friendly case, we should.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).