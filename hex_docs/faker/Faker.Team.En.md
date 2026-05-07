# Faker.Team.En

Functions for generating team related data in English

## creature()

Returns a random creature name

## Examples

    iex> Faker.Team.En.creature()
    "prophets"
    iex> Faker.Team.En.creature()
    "cats"
    iex> Faker.Team.En.creature()
    "enchanters"
    iex> Faker.Team.En.creature()
    "banshees"

## name()

Returns a string of the form [state] [creature]

## Examples

    iex> Faker.Team.En.name()
    "Hawaii cats"
    iex> Faker.Team.En.name()
    "Oklahoma banshees"
    iex> Faker.Team.En.name()
    "Texas elves"
    iex> Faker.Team.En.name()
    "Iowa fishes"