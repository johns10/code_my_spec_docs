# Recase.TitleCase

Module to convert strings to `Title Case`.

This module should not be used directly.

**NB!** at the moment has no stop words: titleizes everything

## Examples

    iex> Recase.to_title "foo_barBaz-λambdaΛambda-привет-Мир"
    "Foo Bar Baz Λambda Λambda Привет Мир"

Read about `Title Case` here:
https://en.wikipedia.org/wiki/Letter_case#Title_case