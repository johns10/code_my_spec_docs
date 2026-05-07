# Dotenvy.Transformer

This module provides functionality for converting string values to specific Elixir data types.

These conversions were designed to operate on system environment variables, which
_always_ store string binaries.

## to!(str, callback)

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

## conversion_type/0

The conversion type specifies the target data type to which a string will be converted.
For example, `:integer` would indicate a transformation of `"12"` to `12`.

The following types are supported:

- `:atom` - converts to an atom. An empty string will be the atom `:""` (!).
- `:atom?` - converts to an atom. An empty string will be considered `nil`
- `:atom!` - converts to an atom. An empty string will raise.

- `:boolean` - "false", "0", or an empty string "" will be considered boolean `false`. Any other non-empty value is considered `true`.
- `:boolean?` - as above, except an empty string will be considered `nil`
- `:boolean!` - as above, except an empty string will raise.

- `:charlist` - converts string to charlist.
- `:charlist?` - converts string to charlist. Empty string will be considered `nil`.
- `:charlist!` - as above, but an empty string will raise.

- `:integer` - converts a string to an integer. An empty string will be considered `0`.
- `:integer?` - as above, but an empty string will be considered `nil`.
- `:integer!` - as above, but an empty string will raise.

- `:float` - converts a string to an float. An empty string will be considered `0`.
- `:float?` - as above, but an empty string will be considered `nil`.
- `:float!` - as above, but an empty string will raise.

- `:existing_atom` - converts into an existing atom. Raises error if the atom does not exist.
- `:existing_atom?` - as above, but an empty string will be considered `nil`.
- `:existing_atom!` - as above, but an empty string will raise.

- `:module` - converts a string into an Elixir module name. Raises on error.
- `:module?` - as above, but an empty string will be considered `nil`.
- `:module!` - as above, but an empty string will raise.

- `:string` - no conversion (default)
- `:string?` - empty strings will be considered `nil`.
- `:string!` - as above, but an empty string will raise.
- custom function - see below.

## Custom Callback function

When you require more control over the transformation of your value than is possible
with the types provided, you can provide an arity 1 function in place of the type.