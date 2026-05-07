# Credo.Check.Refactor.CyclomaticComplexity

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

Cyclomatic complexity (CC) is a software complexity metric closely
correlated with coding errors.

If a function feels like it's gotten too complex, it more often than not also
has a high CC value. So, if anything, this is useful to convince team members
and bosses of a need to refactor parts of the code based on "objective"
metrics.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:max_complexity`

  The maximum cyclomatic complexity a function should have.

*This parameter defaults to* `9`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).

## complexity_for(ast)

Returns the Cyclomatic Complexity score for the block inside the given AST,
which is expected to represent a function or macro definition.

    iex> {:def, [line: 1],
    ...>   [
    ...>     {:first_fun, [line: 1], nil},
    ...>     [do: {:=, [line: 2], [{:x, [line: 2], nil}, 1]}]
    ...>   ]
    ...> } |> Credo.Check.Refactor.CyclomaticComplexity.complexity_for
    1.0