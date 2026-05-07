# Expo.PluralForms

Functions to parse and evaluate plural forms as defined in the GNU Gettext documentation.

The documentation is available at
<https://www.gnu.org/software/gettext/manual/html_node/Plural-forms.html>.

## Usage

Some functions in this module are considered "low level", and are meant to be
used by other libraries. For example, `parse/1` returns an expression
that is not really meant to be inspected, but rather used internally by this library.

## index(plural_form, n)

Gets the plural form for the given number based on the given `plural_forms` struct.

### Examples

    iex> {:ok, plural_form} = Expo.PluralForms.parse("nplurals=2; plural=n != 1;")
    iex> Expo.PluralForms.index(plural_form, 4)
    1
    iex> Expo.PluralForms.index(plural_form, 1)
    0

## known_locales()

Get known locales where plural form information is available.

### Examples

    iex> "de" in Expo.PluralForms.known_locales()
    true

    iex> "invalid" in Expo.PluralForms.known_locales()
    false

## parse(content)

Parses a plural forms string into a `t:t/0` struct.

Returns `{:ok, struct}` if the string is valid, or `{:error, error}`
if it isn't.

### Examples

    iex> Expo.PluralForms.parse("nplurals=2; plural=n != 1;")
    {:ok, Expo.PluralForms.parse!("nplurals=2; plural=n != 1;")}

## parse!(content)

Parses a plural forms string into a `t:t/0` struct, raising if there are errors.

Same as `parse/1`, but returns the plural forms struct directly if the
parsing is successful, or raises an error otherwise.

The `Inspect` implementation for the `Expo.PluralForms` struct uses this function
to display the plural forms expression, which is why the example below might
look a bit weird.

## Examples

    iex> Expo.PluralForms.parse!("nplurals=2; plural=n != 1;")
    Expo.PluralForms.parse!("nplurals=2; plural=n != 1;")

## plural_form(iso_language_tag)

Gets the plural form for the given language based on built-in information.

### Examples

    iex> Expo.PluralForms.plural_form("de")
    {:ok, Expo.PluralForms.parse!("nplurals=2; plural=(n != 1);")}

    iex> Expo.PluralForms.plural_form("invalid")
    :error

## to_string(plural_forms)

Converts a plural forms struct into its string representation.

## Examples

    iex> plural_forms = Expo.PluralForms.parse!("nplurals=2; plural=n != 1;")
    iex> Expo.PluralForms.to_string(plural_forms)
    "nplurals=2; plural=n != 1;"

## t/0

A struct representing a plural forms expression.

## plural_ast/0

The AST of a plural forms expression.

This is evaluated internally to determine the plural form for a given number
using `index/2`, and is not meant to be inspected directly.