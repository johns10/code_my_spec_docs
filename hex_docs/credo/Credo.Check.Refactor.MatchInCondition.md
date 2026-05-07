# Credo.Check.Refactor.MatchInCondition

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Pattern matching should only ever be used for simple assignments
inside `if` and `unless` clauses.

While this fine:

    # okay, simple wildcard assignment:

    if contents = File.read!("foo.txt") do
      do_something(contents)
    end

the following should be avoided, since it mixes a pattern match with a
condition and do/else blocks.

    # considered too "complex":

    if {:ok, contents} = File.read("foo.txt") do
      do_something(contents)
    end

    # also considered "complex":

    if allowed? && ( contents = File.read!("foo.txt") ) do
      do_something(contents)
    end

If you want to match for something and execute another block otherwise,
consider using a `case` statement:

    case File.read("foo.txt") do
      {:ok, contents} ->
        do_something()
      _ ->
        do_something_else()
    end



## Check-Specific Parameters

Use the following parameters to configure this check:

### `:allow_tagged_tuples`

  Allow tagged tuples in conditions, e.g. `if {:ok, contents} = File.read( "foo.txt") do`

*This parameter defaults to* `false`.

### `:allow_operators`

  Allow operators in conditions, e.g. `if contents = File.read(input <> ".txt") do`

*This parameter defaults to* `false`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).