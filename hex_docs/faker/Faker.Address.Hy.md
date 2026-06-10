# Faker.Address.Hy

Functions for generating addresses in Armenian

## building_number/0

Returns a random building number.

## Examples

    iex> Faker.Address.Hy.building_number()
    "1"
    iex> Faker.Address.Hy.building_number()
    "4"
    iex> Faker.Address.Hy.building_number()
    "64"
    iex> Faker.Address.Hy.building_number()
    "108"

## secondary_address/0

Returns a random secondary address.

## Examples

    iex> Faker.Address.Hy.secondary_address()
    "բն. 1"
    iex> Faker.Address.Hy.secondary_address()
    "բն. 4"
    iex> Faker.Address.Hy.secondary_address()
    "բն. 64"
    iex> Faker.Address.Hy.secondary_address()
    "բն. 110"

## street_address/0

Returns street address.

## Examples

    iex> Faker.Address.Hy.street_address()
    "Սուրբ Հովհաննեսի 542"
    iex> Faker.Address.Hy.street_address()
    "Բուռնազյան 61"
    iex> Faker.Address.Hy.street_address()
    "Լամբրոնի 329"
    iex> Faker.Address.Hy.street_address()
    "Հանրապետության 5"

## street_address/1

Returns `street_address/0` or if argument is `true` adds `secondary_address/0`.

## Examples

    iex> Faker.Address.Hy.street_address(true)
    "Սուրբ Հովհաննեսի 542 բն. 4"
    iex> Faker.Address.Hy.street_address(false)
    "Գյուլբենկյան 0"
    iex> Faker.Address.Hy.street_address(true)
    "Պուշկինի 29 բն. 0"
    iex> Faker.Address.Hy.street_address(false)
    "Տիգրան Մեծի 35"

## zip_code/0

Returns a random postcode.

## Examples

    iex> Faker.Address.Hy.zip_code()
    "0154"
    iex> Faker.Address.Hy.zip_code()
    "2646"
    iex> Faker.Address.Hy.zip_code()
    "1083"
    iex> Faker.Address.Hy.zip_code()
    "2970"