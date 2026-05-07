# Credo.Check.Readability.PipeIntoAnonymousFunctions

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Avoid piping into anonymous functions.

The code in this example ...

    def my_fun(foo) do
      foo
      |> (fn i -> i * 2 end).()
      |> my_other_fun()
    end

... should be refactored to define a private function:

    def my_fun(foo) do
      foo
      |> times_2()
      |> my_other_fun()
    end

    defp times_2(i), do: i * 2

... or use `then/1`:

    def my_fun(foo) do
      foo
      |> then(fn i -> i * 2 end)
      |> my_other_fun()
    end

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).