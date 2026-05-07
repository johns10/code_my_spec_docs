# Credo.Check.Refactor.ABCSize

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `0` and works with any version of Elixir.

## Explanation

The ABC size describes a metric based on assignments, branches and conditions.

A high ABC size is a hint that a function might be doing "more" than it
should.

As always: Take any metric with a grain of salt. Since this one was originally
introduced for C, C++ and Java, we still have to see whether or not this can
be a useful metric in a declarative language like Elixir.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:max_size`

  The maximum ABC size a function should have.

*This parameter defaults to* `30`.

### `:excluded_functions`

  All functions listed will be ignored.

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).

## abc_size_for(arg, excluded_functions)

Returns the ABC size for the block inside the given AST, which is expected
to represent a function or macro definition.

    iex> {:def, [line: 1],
    ...>   [
    ...>     {:first_fun, [line: 1], nil},
    ...>     [do: {:=, [line: 2], [{:x, [line: 2], nil}, 1]}]
    ...>   ]
    ...> } |> Credo.Check.Refactor.ABCSize.abc_size
    1.0