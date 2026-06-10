# Faker.Address.Es

Functions for generating addresses in Spanish

## building_number/0

Return random building number.

## Examples

    iex> Faker.Address.Es.building_number()
    "s/n."
    iex> Faker.Address.Es.building_number()
    "5"
    iex> Faker.Address.Es.building_number()
    "26"
    iex> Faker.Address.Es.building_number()
    "61"

## city/0

Return city name.

## Examples

    iex> Faker.Address.Es.city()
    "Guillermina"
    iex> Faker.Address.Es.city()
    "Agosto"
    iex> Faker.Address.Es.city()
    "Burgos Alfonso"
    iex> Faker.Address.Es.city()
    "María José"

## secondary_address/0

Return random secondary address.

## Examples

    iex> Faker.Address.Es.secondary_address()
    "Esc. 154"
    iex> Faker.Address.Es.secondary_address()
    "Esc. 646"
    iex> Faker.Address.Es.secondary_address()
    "Puerta 083"
    iex> Faker.Address.Es.secondary_address()
    "Esc. 970"

## state/0

Return state. But Spain doesn't have states so this calls Faker.Address.Es.region() instead.

## street_address/0

Return street address.

## Examples

    iex> Faker.Address.Es.street_address()
    "Arrabal Daniela 26"
    iex> Faker.Address.Es.street_address()
    "Mercado Navarro s/n."
    iex> Faker.Address.Es.street_address()
    "Parque Débora Huerta 05"
    iex> Faker.Address.Es.street_address()
    "Rambla Gutiérrez 02"

## street_address/1

Return `street_address/0` or if argument is `true` adds `secondary_address/0`.

## Examples

    iex> Faker.Address.Es.street_address(true)
    "Arrabal Daniela 26 Esc. 610"
    iex> Faker.Address.Es.street_address(false)
    "Parque Débora Huerta 05"
    iex> Faker.Address.Es.street_address(false)
    "Rambla Gutiérrez 02"
    iex> Faker.Address.Es.street_address(false)
    "Calle Murillo 2"

## street_name/0

Return street name.

## Examples

    iex> Faker.Address.Es.street_name()
    "Arrabal Daniela"
    iex> Faker.Address.Es.street_name()
    "Polígono Javier Acosta"
    iex> Faker.Address.Es.street_name()
    "Urbanización Gerardo Garza"
    iex> Faker.Address.Es.street_name()
    "Ferrocarril Huerta"

## zip_code/0

Return random postcode.

## Examples

    iex> Faker.Address.Es.zip_code()
    "01542"
    iex> Faker.Address.Es.zip_code()
    "64610"
    iex> Faker.Address.Es.zip_code()
    "83297"
    iex> Faker.Address.Es.zip_code()
    "05235"