# Credo.Check.Design.SkipTestWithoutComment

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `normal` and works with any version of Elixir.

## Explanation

Skipped tests should have a comment documenting why the test is skipped.

Tests are often skipped using `@tag :skip` when some issue arises that renders
the test temporarily broken or unable to run. This temporary skip often becomes
a permanent one because the reason for the test being skipped is not documented.

A comment should exist on the line prior to the skip tag describing why the test is
skipped.

Example:

    # john: skipping this since our credentials expired, working on getting new ones
    @tag :skip
    test "vendor api returns data" do
      # ...
    end

While the pure existence of a comment does not change anything per se, a thoughtful
comment can improve the odds for future iteration on the issue.


## Check-Specific Parameters

*There are no specific parameters for this check.*

## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).