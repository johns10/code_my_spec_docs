# Credo.Check.Refactor.ModuleDependencies

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `normal` and works with any version of Elixir.

## Explanation

This module might be doing too much. Consider limiting the number of
module dependencies.

As always: This is just a suggestion. Check the configuration options for
tweaking or disabling this check.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:max_deps`

  Maximum number of module dependencies.

*This parameter defaults to* `10`.

### `:dependency_namespaces`

  List of dependency namespaces to include in this check

*This parameter defaults to* `[]`.

### `:excluded_namespaces`

  List of namespaces to exclude from this check

*This parameter defaults to* `[]`.

### `:excluded_paths`

  List of paths or regex to exclude from this check

*This parameter defaults to* `[~r/\/test\//, "test"]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).