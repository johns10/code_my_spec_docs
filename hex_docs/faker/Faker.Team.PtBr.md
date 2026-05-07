# Faker.Team.PtBr

Functions for generating team related data in Brazilian Portuguese

## creature()

Returns a random creature name

## Examples

    iex> Faker.Team.PtBr.creature()
    "corujas"
    iex> Faker.Team.PtBr.creature()
    "ovelha"
    iex> Faker.Team.PtBr.creature()
    "vampiros"
    iex> Faker.Team.PtBr.creature()
    "macacos"

## name()

Returns a string of the form [state] [creature]

## Examples

    iex> Faker.Team.PtBr.name()
    "corujas de Alaska"
    iex> Faker.Team.PtBr.name()
    "vampiros de California"
    iex> Faker.Team.PtBr.name()
    "pássaros de Kentucky"
    iex> Faker.Team.PtBr.name()
    "vixens de Kentucky"