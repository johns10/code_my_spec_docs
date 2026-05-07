# Credo.Check.Consistency.ExceptionNames

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Exception names should end with a common suffix like "Error".

Try to name your exception modules consistently:

    defmodule BadCodeError do
      defexception [:message]
    end

    defmodule ParserError do
      defexception [:message]
    end

Inconsistent use should be avoided:

    defmodule BadHTTPResponse do
      defexception [:message]
    end

    defmodule HTTPHeaderException do
      defexception [:message]
    end

While this is not necessarily a concern for the correctness of your code,
you should use a consistent style throughout your codebase.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).