# Faker.Name

Deprecated. Faker.Name will be removed in 1.0.0. Please use Faker.Person instead.

## first_name()

Returns a random first name

## Examples

    iex> Faker.Name.first_name()
    "Joany"
    iex> Faker.Name.first_name()
    "Elizabeth"
    iex> Faker.Name.first_name()
    "Abe"
    iex> Faker.Name.first_name()
    "Ozella"

## last_name()

Returns a random last name

## Examples

    iex> Faker.Name.last_name()
    "Blick"
    iex> Faker.Name.last_name()
    "Hayes"
    iex> Faker.Name.last_name()
    "Schumm"
    iex> Faker.Name.last_name()
    "Rolfson"

## name()

Returns a random complete name

## Examples

    iex> Faker.Name.name()
    "Mrs. Abe Rolfson MD"
    iex> Faker.Name.name()
    "Conor Padberg"
    iex> Faker.Name.name()
    "Mr. Bianka Ryan"
    iex> Faker.Name.name()
    "Ally Rau MD"

## prefix()

Returns a random name related prefix

## Examples

    iex> Faker.Name.prefix()
    "Mr."
    iex> Faker.Name.prefix()
    "Mrs."
    iex> Faker.Name.prefix()
    "Mr."
    iex> Faker.Name.prefix()
    "Dr."

## suffix()

Returns a random name related suffix

## Examples

    iex> Faker.Name.suffix()
    "II"
    iex> Faker.Name.suffix()
    "V"
    iex> Faker.Name.suffix()
    "V"
    iex> Faker.Name.suffix()
    "V"

## title()

Returns a random name related title

## Examples

    iex> Faker.Name.title()
    "Dynamic Identity Administrator"
    iex> Faker.Name.title()
    "Product Communications Technician"
    iex> Faker.Name.title()
    "Legacy Accountability Architect"
    iex> Faker.Name.title()
    "Customer Data Representative"