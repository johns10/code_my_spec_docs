# Credo.Check.Warning.MapGetUnsafePass

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `normal` and works with any version of Elixir.

## Explanation

`Map.get/2` can lead into runtime errors if the result is passed into a pipe
without a proper default value. This happens when the next function in the
pipe cannot handle `nil` values correctly.

Example:

    %{foo: [1, 2 ,3], bar: [4, 5, 6]}
    |> Map.get(:missing_key)
    |> Enum.each(&IO.puts/1)

This will cause a `Protocol.UndefinedError`, since `nil` isn't `Enumerable`.
Often times while iterating over enumerables zero iterations is preferable
to being forced to deal with an exception. Had there been a `[]` default
parameter this could have been averted.

If you are sure the value exists and can't be nil, please use `Map.fetch!/2`.
If you are not sure, `Map.get/3` can help you provide a safe default value.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).