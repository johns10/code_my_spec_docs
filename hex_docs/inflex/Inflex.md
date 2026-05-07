# Inflex



## camelize(word)

Camelizes or pascalizes strings and atoms to upper-case CamelCase.

## Examples

    iex> Inflex.camelize(:upper_camel_case)
    "UpperCamelCase"

## camelize(word, option)

Camelizes or pascalizes strings and atoms.

## Options

* `:lower` - Lower-cases the first letter.

## Examples

    iex> Inflex.camelize("pascal-case", :lower)
    "pascalCase"

## inflect(word, count)

Inflect on the plurality of a word given some count.

## Examples

    iex> Inflex.inflect("child", 1)
    "child"

    iex> Inflex.inflect("child", 2)
    "children"

## ordinalize(number)

Converts an integer to a ordinal value.

## Examples

    iex> Inflex.ordinalize(1)
    "1st"

    iex> Inflex.ordinalize(11)
    "11th"

## parameterize(word)

Parameterize a string using a hyphen (`-`) separator. If you want to return
as only ascii characters, use `parameterize_to_ascii/2`

## Examples

    iex> Inflex.parameterize("String for parameter")
    "string-for-parameter"

## parameterize(word, option)

Parameterize a string given some separator. If you want to return
as only ascii characters, use `parameterize_to_ascii/2`

The `option` argument is a string representing the character that
will be used as the separator.

## Examples

    iex> Inflex.parameterize("String with underscore", "_")
    "string_with_underscore"

## parameterize_to_ascii(word)

Parameterize a string using a hyphen (`-`) separator, returning
only ascii characters.

## Examples

    iex> Inflex.parameterize_to_ascii("String for parameter 😎")
    "string-for-parameter-"

## parameterize_to_ascii(word, option)

Parameterize a string given some separator, returning only ascii
characters.

The `option` argument is a string representing the character that
will be used as the separator.

## Examples

    iex> Inflex.parameterize_to_ascii("String with underscore 😎", "_")
    "string_with_underscore_"

## pluralize(word)

Pluralize a word.

## Examples

    iex> Inflex.pluralize("dog")
    "dogs"

    iex> Inflex.pluralize("person")
    "people"

## singularize(word)

Singularize a word.

## Examples

    iex> Inflex.singularize("dogs")
    "dog"

    iex> Inflex.singularize("people")
    "person"

## underscore(word)

Underscore and lowercase a string.

## Examples

    iex> Inflex.underscore("UpperCamelCase")
    "upper_camel_case"

    iex> Inflex.underscore(:pascalCase)
    "pascal_case"