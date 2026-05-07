# Credo.Check.Readability.StringSigils

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

If you used quoted strings that contain quotes, you might want to consider
switching to the use of sigils instead.

    # okay

    "<a href=\"http://elixirweekly.net\">#\{text}</a>"

    # not okay, lots of escaped quotes

    "<a href=\"http://elixirweekly.net\" target=\"_blank\">#\{text}</a>"

    # refactor to

    ~S(<a href="http://elixirweekly.net" target="_blank">#\{text}</a>)

This allows us to remove the noise which results from the need to escape
quotes within quotes.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:maximum_allowed_quotes`

  The maximum amount of escaped quotes you want to tolerate.

*This parameter defaults to* `3`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).