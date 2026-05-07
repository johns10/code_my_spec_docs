# Recase.SnakeCase

Module to convert strings to `snake_case`.

This module should not be used directly.

## Examples

    iex> Recase.to_snake "foo_barBaz-λambdaΛambda-привет-Мир"
    "foo_bar_baz_λambda_λambda_привет_мир"
    iex> Recase.underscore "foo_barBaz-λambdaΛambda-привет-Мир"
    "foo_bar_baz_λambda_λambda_привет_мир"

Read about `snake_case` here:
https://en.wikipedia.org/wiki/Snake_case