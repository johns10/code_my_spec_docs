# Credo.Check.Warning.UnusedKeywordOperation

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

The result of a call to the Keyword module's functions has to be used.

While this is correct ...

    def clean_and_verify_options!(keywords) do
      keywords = Keyword.delete(keywords, :debug)

      if Enum.length(keywords) == 0, do: raise "OMG!!!1"

      keywords
    end

... we forgot to save the result in this example:

    def clean_and_verify_options!(keywords) do
      Keyword.delete(keywords, :debug)

      if Enum.length(keywords) == 0, do: raise "OMG!!!1"

      keywords
    end

Keyword operations never work on the variable you pass in, but return a new
variable which has to be used somehow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).