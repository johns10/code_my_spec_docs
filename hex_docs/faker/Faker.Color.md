# Faker.Color

Functions for generating different color representations.

## rgb_hex/0

Return random RGB hex value.

## Examples

    iex> Faker.Color.rgb_hex()
    "D6D98B"
    iex> Faker.Color.rgb_hex()
    "88C866"
    iex> Faker.Color.rgb_hex()
    "F496DB"
    iex> Faker.Color.rgb_hex()
    "D4DE7B"

## rgb_decimal/0

Return random RGB decimal value.

## Examples

    iex> Faker.Color.rgb_decimal()
    {214, 217, 139}
    iex> Faker.Color.rgb_decimal()
    {136, 200, 102}
    iex> Faker.Color.rgb_decimal()
    {244, 150, 219}
    iex> Faker.Color.rgb_decimal()
    {212, 222, 123}