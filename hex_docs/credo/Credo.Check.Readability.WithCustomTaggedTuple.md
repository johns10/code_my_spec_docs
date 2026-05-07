# Credo.Check.Readability.WithCustomTaggedTuple

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Avoid using custom tags for error reporting from `with` macros.

This code injects tuple_tag tags such as `:resource` and `:authz` for the purpose of error
reporting.

    with {:resource, {:ok, resource}} <- {:resource, Resource.fetch(user)},
         {:authz, :ok} <- {:authz, Resource.authorize(resource, user)} do
      do_something_with(resource)
    else
      {:resource, _} -> {:error, :not_found}
      {:authz, _} -> {:error, :unauthorized}
    end

Instead, extract each validation into a separate helper function which returns error
information immediately:

    defp find_resource(user) do
      with :error <- Resource.fetch(user), do: {:error, :not_found}
    end

    defp authorize(resource, user) do
      with :error <- Resource.authorize(resource, user), do: {:error, :unauthorized}
    end

At this point, the validation chain in `with` becomes clearer and easier to understand:

    with {:ok, resource} <- find_resource(user),
         :ok <- authorize(resource, user),
         do: do_something(user)

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).