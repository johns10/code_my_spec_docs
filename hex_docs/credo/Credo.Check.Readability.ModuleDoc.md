# Credo.Check.Readability.ModuleDoc

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Every module should contain comprehensive documentation.

    # preferred

    defmodule MyApp.Web.Search do
      @moduledoc """
      This module provides a public API for all search queries originating
      in the web layer.
      """
    end

    # also okay: explicitly say there is no documentation

    defmodule MyApp.Web.Search do
      @moduledoc false
    end

Many times a sentence or two in plain english, explaining why the module
exists, will suffice. Documenting your train of thought this way will help
both your co-workers and your future-self.

Other times you will want to elaborate even further and show some
examples of how the module's functions can and should be used.

In some cases however, you might not want to document things about a module,
e.g. it is part of a private API inside your project. Since Elixir prefers
explicitness over implicit behaviour, you should "tag" these modules with

    @moduledoc false

to make it clear that there is no intention in documenting it.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:ignore_names`

  All modules matching this regex (or list of regexes) will be ignored.

*This parameter defaults to* `[~r/(\.\w+Controller|\.Endpoint|\.\w+Live(\.\w+)?|\.Repo|\.Router|\.\w+Socket|\.\w+View|\.\w+HTML|\.\w+JSON|\.Telemetry|\.Layouts|\.Mailer)$/]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).