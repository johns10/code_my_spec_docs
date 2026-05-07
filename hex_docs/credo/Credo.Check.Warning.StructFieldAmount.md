# Credo.Check.Warning.StructFieldAmount

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `normal` and works with any version of Elixir.

## Explanation

Avoid structs with 32 or more fields.

Structs in Elixir are implemented as compile-time maps, which have a
predefined amount of fields.

When structs have 32 or more fields, their internal representation in
the Erlang Virtual Machines changes, potentially leading to bloating
and higher memory usage.

https://hexdocs.pm/elixir/1.19.0/code-anti-patterns.html#structs-with-32-fields-or-more


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:max_fields`

  The maximum number of field a struct should be allowed to have.

*This parameter defaults to* `31`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).