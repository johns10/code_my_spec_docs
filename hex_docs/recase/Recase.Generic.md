# Recase.Generic

Generic module to split and join strings back or convert strings to atoms.
This module should not be used directly.

## rejoin(input, opts \\ [])

Splits the input and **`rejoins`** it with a separator given. Optionally
converts parts to `downcase`, `upcase` or `titlecase`.
- `opts[:case] :: [:down | :up | :title | :none]`
- `opts[:separator] :: binary() | integer()`
Default separator is `?_`, default conversion is `:downcase` so that
it behaves the same way as `to_snake/1`.
## Examples
    iex> Recase.Generic.rejoin "foo_barBaz-λambdaΛambda-привет-Мир", separator: "__"
    "foo__bar__baz__λambda__λambda__привет__мир"

## safe_atom(string_value)

Atomizes a string value.
Uses an existing atom if possible.

## split(input)

Splits the input into **`list`**. Utility function.
## Examples
    iex> Recase.Generic.split "foo_barBaz-λambdaΛambda-привет-Мир"
    ["foo", "bar", "Baz", "λambda", "Λambda", "привет", "Мир"]