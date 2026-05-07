# Credo.Check.Readability.ModuleNames

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Module names are always written in PascalCase in Elixir.

    # PascalCase

    defmodule MyApp.WebSearchController do
      # ...
    end

    # not PascalCase

    defmodule MyApp.Web_searchController do
      # ...
    end

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of other reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:ignore`

  List of ignored module names and patterns e.g. `[~r/Sample_Module/, "Credo.Sample_Module"]`

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).