# Credo.Check.Readability.AliasAs

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Aliases can be "renamed" using the `:as` option, but that sometimes
makes the code more difficult to read.

    # preferred

    def MyModule do
      alias MyApp.Module1

      def my_function(foo) do
        Module1.run(foo)
      end
    end

    # NOT preferred

    def MyModule do
      alias MyApp.Module1, as: M1

      def my_function(foo) do
        # what the heck is `M1`?
        M1.run(foo)
      end
    end

Please note that you might want to deactivate this check for cases in which you have an alias that
is used tons throughout your codebase.

If, for example, you are using a third-party module named `FlupsyTopsyDataRetentionServiceServer`
in half your modules, it is of course reasonable to alias it to `Server`.

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:ignore`

  List of modules to ignore and allow to `alias Module, as: ...`

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).