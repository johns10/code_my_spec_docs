# Recase.ConstantCase

Module to convert strings to `CONSTANT_CASE`.

This module should not be used directly.

## Examples

    iex> Recase.to_constant "foo_barBaz-λambdaΛambda-привет-Мир"
    "FOO_BAR_BAZ_ΛAMBDA_ΛAMBDA_ПРИВЕТ_МИР"

Constant case is the same as `snake_case`,
but uppercased.