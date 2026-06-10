# Dotenvy.Transformer

This module provides functionality for converting string values to specific Elixir data types.

These conversions were designed to operate on system environment variables, which
_always_ store string binaries.

## to!/2

Converts strings into Elixir data types with support for nil-able values. Raises on error.

Each type determines how to interpret the incoming string, e.g. when the `type`
is `:integer`, an empty string is considered a `0`; when `:integer?` is the `type`,
and empty string is converted to `nil`.

Remember:

- The type should use a `?` suffix when an empty string should be considered `nil` (a.k.a. a "nullable" value).
- The type should a `!` suffix when an empty string is not allowed. Use this when values are required.

## Types

See the `t:Dotenvy.Transformer.conversion_type/0` for a description of valid
conversion types.

## Examples

    iex> to!("debug", :atom)
    :debug
    iex> to!("", :boolean)
    false
    iex> to!("", :boolean?)
    nil
    iex> to!("5432", :integer)
    5432
    iex> to!("DateTime", :module)
    DateTime
    iex> to!("foo", fn val -> val <> "bar" end)
    "foobar"
    iex> Dotenvy.Transformer.to!("Oops", :float)
      ** (Dotenvy.Error) Unparsable as float
      (dotenvy 1.0.0) lib/dotenvy/transformer.ex:165: Dotenvy.Transformer.to!/2