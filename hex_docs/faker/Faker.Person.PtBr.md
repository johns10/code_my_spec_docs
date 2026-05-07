# Faker.Person.PtBr

Functions for name data in Brazilian Portuguese

## first_name()

Returns a random first name

## Examples

    iex> Faker.Person.PtBr.first_name()
    "Augusto"
    iex> Faker.Person.PtBr.first_name()
    "Amanda"
    iex> Faker.Person.PtBr.first_name()
    "Kaique"
    iex> Faker.Person.PtBr.first_name()
    "Antonia"

## last_name()

Returns a random last name

## Examples

    iex> Faker.Person.PtBr.last_name()
    "Sá"
    iex> Faker.Person.PtBr.last_name()
    "das Neves"
    iex> Faker.Person.PtBr.last_name()
    "Castelo"
    iex> Faker.Person.PtBr.last_name()
    "Mendes"

## name()

Returns a complete name (may include a suffix/prefix or both)

## Examples

    iex> Faker.Person.PtBr.name()
    "Sra. Kaique Mendes Neto"
    iex> Faker.Person.PtBr.name()
    "Roberta Garcês"
    iex> Faker.Person.PtBr.name()
    "Sr. Vitor Albuquerque"
    iex> Faker.Person.PtBr.name()
    "Maria Laura da Penha Jr."

## prefix()

Returns a random prefix

## Examples

    iex> Faker.Person.PtBr.prefix()
    "Sr."
    iex> Faker.Person.PtBr.prefix()
    "Sra."
    iex> Faker.Person.PtBr.prefix()
    "Sr."
    iex> Faker.Person.PtBr.prefix()
    "Dra."

## suffix()

Returns a random suffix

## Examples

    iex> Faker.Person.PtBr.suffix()
    "Jr."
    iex> Faker.Person.PtBr.suffix()
    "Filho"
    iex> Faker.Person.PtBr.suffix()
    "Jr."
    iex> Faker.Person.PtBr.suffix()
    "Filho"