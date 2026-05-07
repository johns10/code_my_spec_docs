# Faker.Person

Functions for generating names for a person.

## first_name()

Returns a random first name

## Examples

    iex> Faker.Person.first_name()
    "Joany"
    iex> Faker.Person.first_name()
    "Elizabeth"
    iex> Faker.Person.first_name()
    "Abe"
    iex> Faker.Person.first_name()
    "Ozella"

## last_name()

Returns a random last name

## Examples

    iex> Faker.Person.last_name()
    "Blick"
    iex> Faker.Person.last_name()
    "Hayes"
    iex> Faker.Person.last_name()
    "Schumm"
    iex> Faker.Person.last_name()
    "Rolfson"

## name()

Returns a random complete name

## Examples

    iex> Faker.Person.name()
    "Mrs. Abe Rolfson MD"
    iex> Faker.Person.name()
    "Conor Padberg"
    iex> Faker.Person.name()
    "Mr. Bianka Ryan"
    iex> Faker.Person.name()
    "Ally Rau MD"

## prefix()

Returns a random name related prefix

## Examples

    iex> Faker.Person.prefix()
    "Mr."
    iex> Faker.Person.prefix()
    "Mrs."
    iex> Faker.Person.prefix()
    "Mr."
    iex> Faker.Person.prefix()
    "Dr."

## suffix()

Returns a random name related suffix

## Examples

    iex> Faker.Person.suffix()
    "II"
    iex> Faker.Person.suffix()
    "V"
    iex> Faker.Person.suffix()
    "V"
    iex> Faker.Person.suffix()
    "V"

## title()

Returns a random name related title

## Examples

    iex> Faker.Person.title()
    "Dynamic Identity Administrator"
    iex> Faker.Person.title()
    "Product Communications Technician"
    iex> Faker.Person.title()
    "Legacy Accountability Architect"
    iex> Faker.Person.title()
    "Customer Data Representative"