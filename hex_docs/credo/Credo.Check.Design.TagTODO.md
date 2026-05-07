# Credo.Check.Design.TagTODO

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `0` and works with any version of Elixir.

## Explanation

TODO comments are used to remind yourself of source code related things.

Example:

    # TODO: move this to a Helper module
    defp fun do
      # ...
    end

The premise here is that TODO should be dealt with in the near future and
are therefore reported by Credo.

Like all `Software Design` issues, this is just advice and might not be
applicable to your project/situation.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:include_doc`

  Set to `true` to also include tags from @doc attributes.

*This parameter defaults to* `true`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).