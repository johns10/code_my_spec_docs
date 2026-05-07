# Credo.Check.Warning.LazyLogging

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and requires Elixir `< 1.7.0`.

## Explanation

Ensures laziness of Logger calls.

You will want to wrap expensive logger calls into a zero argument
function (`fn -> "string that gets logged" end`).

Example:

    # preferred

    Logger.debug fn ->
      "This happened: #{expensive_calculation(arg1, arg2)}"
    end

    # NOT preferred
    # the interpolation is executed whether or not the info is logged

    Logger.debug "This happened: #{expensive_calculation(arg1, arg2)}"


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:ignore`

  Do not raise an issue for these Logger calls.

*This parameter defaults to* `[:error, :warn, :info]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).