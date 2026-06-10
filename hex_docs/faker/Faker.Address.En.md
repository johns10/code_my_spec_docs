# Faker.Address.En

Functions for generating addresses in English

## building_number/0

Return random building number.

## Examples

    iex> Faker.Address.En.building_number()
    "15426"
    iex> Faker.Address.En.building_number()
    "6"
    iex> Faker.Address.En.building_number()
    "0832"
    iex> Faker.Address.En.building_number()
    "7"

## city/0

Return city name.

## Examples

    iex> Faker.Address.En.city()
    "Elizabeth"
    iex> Faker.Address.En.city()
    "Rolfson"
    iex> Faker.Address.En.city()
    "West Conor"
    iex> Faker.Address.En.city()
    "Hardy"

## secondary_address/0

Return random secondary address.

## Examples

    iex> Faker.Address.En.secondary_address()
    "Apt. 154"
    iex> Faker.Address.En.secondary_address()
    "Apt. 646"
    iex> Faker.Address.En.secondary_address()
    "Suite 083"
    iex> Faker.Address.En.secondary_address()
    "Apt. 970"

## street_address/0

Return street address.

## Examples

    iex> Faker.Address.En.street_address()
    "15426 Padberg Mews"
    iex> Faker.Address.En.street_address()
    "83297 Jana Spring"
    iex> Faker.Address.En.street_address()
    "57 Legros Cletus Field"
    iex> Faker.Address.En.street_address()
    "32097 Brekke Ladarius Turnpike"

## street_address/1

Return `street_address/0` or if argument is `true` adds `secondary_address/0`.

## Examples

    iex> Faker.Address.En.street_address(true)
    "15426 Padberg Mews, Apt. 832"
    iex> Faker.Address.En.street_address(false)
    "7 Jana Spring"
    iex> Faker.Address.En.street_address(true)
    "57 Legros Cletus Field, Apt. 320"
    iex> Faker.Address.En.street_address(false)
    "7 Brekke Ladarius Turnpike"

## street_name/0

Return street name.

## Examples

    iex> Faker.Address.En.street_name()
    "Elizabeth Freeway"
    iex> Faker.Address.En.street_name()
    "Sipes Trycia Glen"
    iex> Faker.Address.En.street_name()
    "Schiller Delphine Points"
    iex> Faker.Address.En.street_name()
    "Murphy Shore"

## zip_code/0

Return random postcode.

## Examples

    iex> Faker.Address.En.zip_code()
    "01542"
    iex> Faker.Address.En.zip_code()
    "64610"
    iex> Faker.Address.En.zip_code()
    "83297"
    iex> Faker.Address.En.zip_code()
    "05235"