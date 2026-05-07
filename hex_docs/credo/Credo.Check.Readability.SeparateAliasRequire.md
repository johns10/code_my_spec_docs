# Credo.Check.Readability.SeparateAliasRequire

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

All instances of `alias` should be consecutive within a file.
Likewise, all instances of `require` should be consecutive within a file.

For example:

    defmodule Foo do
      require Logger
      alias Foo.Bar

      alias Foo.Baz
      require Integer

      # ...
    end

should be changed to:

    defmodule Foo do
      require Integer
      require Logger

      alias Foo.Bar
      alias Foo.Baz

      # ...
    end

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).