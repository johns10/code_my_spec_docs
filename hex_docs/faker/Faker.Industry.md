# Faker.Industry

Functions for generating Industry related data
Reference https://en.wikipedia.org/wiki/Industry_Classification_Benchmark

## industry()

Returns a Industry name string

## Examples

    iex> Faker.Industry.industry
    "Oil & Gas"
    iex> Faker.Industry.industry
    "Basic Materials"
    iex> Faker.Industry.industry
    "Consumer Services"
    iex> Faker.Industry.industry
    "Health Care"

## sector()

Returns a Sector name string

## Examples

    iex> Faker.Industry.sector
    "Food & Drug Retailers"
    iex> Faker.Industry.sector
    "Banks"
    iex> Faker.Industry.sector
    "Software & Computer Services"
    iex> Faker.Industry.sector
    "Media"

## sub_sector()

Returns a Sub Sector name string

## Examples

    iex> Faker.Industry.sub_sector()
    "Electrical Components & Equipment"
    iex> Faker.Industry.sub_sector()
    "Publishing"
    iex> Faker.Industry.sub_sector()
    "Alternative Electricity"
    iex> Faker.Industry.sub_sector()
    "Forestry"

## super_sector()

Returns a Super Sector name string

## Examples

    iex> Faker.Industry.super_sector
    "Automobiles & Parts"
    iex> Faker.Industry.super_sector
    "Banks"
    iex> Faker.Industry.super_sector
    "Automobiles & Parts"
    iex> Faker.Industry.super_sector
    "Health Care"