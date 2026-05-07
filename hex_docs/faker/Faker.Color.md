# Faker.Color

Functions for generating different color representations.

## fancy_name()

Return a random fancy color name

## Examples

    iex> Faker.Color.fancy_name()
    "Tawny"
    iex> Faker.Color.fancy_name()
    "Citrine"
    iex> Faker.Color.fancy_name()
    "Greige"
    iex> Faker.Color.fancy_name()
    "Cesious"

## name()

Return a random color name

## Examples

    iex> Faker.Color.name()
    "Red"
    iex> Faker.Color.name()
    "Green"
    iex> Faker.Color.name()
    "Brown"
    iex> Faker.Color.name()
    "Pink"

## rgb_decimal()

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

## rgb_hex()

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