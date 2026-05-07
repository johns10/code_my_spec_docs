# Recase.DotCase

Module to convert strings to `dot.case`.

This module should not be used directly.

## Examples

    iex> Recase.to_dot "foo_barBaz-λambdaΛambda-привет-Мир"
    "foo.bar.baz.λambda.λambda.привет.мир"

`DotCase` is the same as `KebabCase` and `SnakeCase`.
But uses `.` as a separator.