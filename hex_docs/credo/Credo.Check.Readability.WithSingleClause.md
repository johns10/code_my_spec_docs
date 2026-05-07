# Credo.Check.Readability.WithSingleClause

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

`with` statements are useful when you need to chain a sequence
of pattern matches, stopping at the first one that fails.

If the `with` has a single pattern matching clause and no `else`
branch, it means that if the clause doesn't match than the whole
`with` will return the value of that clause.

However, if that `with` has also an `else` clause, then you're using `with` exactly
like a `case` and a `case` should be used instead.

Take this code:

    with {:ok, user} <- User.create(make_ref()) do
      user
    else
      {:error, :db_down} ->
        raise "DB is down!"

      {:error, reason} ->
        raise "error: #{inspect(reason)}"
    end

It can be rewritten with a clearer use of `case`:

    case User.create(make_ref()) do
      {:ok, user} ->
        user

      {:error, :db_down} ->
        raise "DB is down!"

      {:error, reason} ->
        raise "error: #{inspect(reason)}"
    end

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).