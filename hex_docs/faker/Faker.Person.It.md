# Faker.Person.It

Functions for name data in Italian

## first_name()

Returns a random first name

## Examples

    iex> Faker.Person.It.first_name()
    "Azalea"
    iex> Faker.Person.It.first_name()
    "Dionigi"
    iex> Faker.Person.It.first_name()
    "Agave"

## last_name()

Returns a random last name

## Examples

    iex> Faker.Person.It.last_name()
    "Bruno"
    iex> Faker.Person.It.last_name()
    "Russo"
    iex> Faker.Person.It.last_name()
    "Serra"
    iex> Faker.Person.It.last_name()
    "Bianchi"

## name()

Returns a complete name (may include a suffix/prefix or both)

## Examples

    iex> Faker.Person.It.name()
    "Sig.ra Agave Bianchi"
    iex> Faker.Person.It.name()
    "Gennaro Mazza"

## prefix()

Returns a random prefix

## Examples

    iex> Faker.Person.It.prefix()
    "Sig."
    iex> Faker.Person.It.prefix()
    "Sig.ra"
    iex> Faker.Person.It.prefix()
    "Sig."
    iex> Faker.Person.It.prefix()
    "Avv."