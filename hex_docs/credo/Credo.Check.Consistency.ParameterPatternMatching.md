# Credo.Check.Consistency.ParameterPatternMatching

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

When capturing a parameter using pattern matching you can either put the parameter name before or after the value
i.e.

    def parse({:ok, values} = pair)

or

    def parse(pair = {:ok, values})

Neither of these is better than the other, but it seems a good idea not to mix the two patterns in the same codebase.

While this is not necessarily a concern for the correctness of your code,
you should use a consistent style throughout your codebase.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:force`

  Force a choice, values can be `:after` or `:before`.

*This parameter defaults to* `nil`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).