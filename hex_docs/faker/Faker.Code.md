# Faker.Code

Functions for generate common codes.

## iban()

Returns a random IBAN starting with the given components. The given components are not validated
but are included in the checksum.

## Examples

    iex> Faker.Code.iban("NL", ["ABNA"])
    "NL16ABNA0154264610"
    iex> Faker.Code.iban("MC", ["FOO", "BAR"])
    "MC98FOOBAR83"
    iex> Faker.Code.iban("SM", ["A"])
    "SM86A2970523570AY38NWIVZ5XT"
    iex> Faker.Code.iban("MC", ["FOO", "BAR"])
    "MC40FOOBAR60"

## isbn()

Returns a random isbn code

## Examples

    iex> Faker.Code.isbn
    "015426461X"
    iex> Faker.Code.isbn
    "0832970522"
    iex> Faker.Code.isbn
    "3570203034"
    iex> Faker.Code.isbn
    "2097337600"

## isbn10()

Returns a random isbn10 code

## Examples

    iex> Faker.Code.isbn10
    "015426461X"
    iex> Faker.Code.isbn10
    "0832970522"
    iex> Faker.Code.isbn10
    "3570203034"
    iex> Faker.Code.isbn10
    "2097337600"

## isbn13()

Returns a random isbn13 code

## Examples

    iex> Faker.Code.isbn13
    "9781542646109"
    iex> Faker.Code.isbn13
    "9783297052358"
    iex> Faker.Code.isbn13
    "9790203032090"
    iex> Faker.Code.isbn13
    "9793376033741"

## issn()

Returns a random issn code

## Examples

    iex> Faker.Code.issn
    "01542648"
    iex> Faker.Code.issn
    "61083291"
    iex> Faker.Code.issn
    "70523576"
    iex> Faker.Code.issn
    "02030322"