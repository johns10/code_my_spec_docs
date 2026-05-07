# Credo.Check.Readability.AliasOrder

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Alphabetically ordered lists are more easily scannable by the reader.

    # preferred

    alias ModuleA
    alias ModuleB
    alias ModuleC

    # NOT preferred

    alias ModuleA
    alias ModuleC
    alias ModuleB

Alias should be alphabetically ordered among their group:

    # preferred

    alias ModuleC
    alias ModuleD

    alias ModuleA
    alias ModuleB

    # NOT preferred

    alias ModuleC
    alias ModuleD

    alias ModuleB
    alias ModuleA

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:sort_method`

  The ordering method to use.
  
  Options
  - `:alpha` - Alphabetical case-insensitive sorting.
  - `:ascii` - Case-sensitive sorting where upper case characters are ordered
                before their lower case equivalent.
  

*This parameter defaults to* `:alpha`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).