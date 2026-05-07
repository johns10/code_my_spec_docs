# Credo.Check.Refactor.Nesting

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Code should not be nested more than once inside a function.

    defmodule CredoSampleModule do
      def some_function(parameter1, parameter2) do
        Enum.reduce(var1, list, fn({_hash, nodes}, list) ->
          filenames = nodes |> Enum.map(&(&1.filename))

          Enum.reduce(list, [], fn(item, acc) ->
            if item.filename do
              item               # <-- this is nested 3 levels deep
            end
            acc ++ [item]
          end)
        end)
      end
    end

At this point it might be a good idea to refactor the code to separate the
different loops and conditions.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:max_nesting`

  The maximum number of levels code should be nested.

*This parameter defaults to* `2`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).