# Faker.Address.Es

Functions for generating addresses in Spanish

## building_number()

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

## city()

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

## city_prefix()

Return city prefix.

## Examples

    iex> Faker.Address.Es.city_prefix()
    "Vitoria"
    iex> Faker.Address.Es.city_prefix()
    "Oviedo"
    iex> Faker.Address.Es.city_prefix()
    "Talavera de la Reina"
    iex> Faker.Address.Es.city_prefix()
    "Cáceres"

## country()

Return country.

## Examples

    iex> Faker.Address.Es.country()
    "Cabo Verde"
    iex> Faker.Address.Es.country()
    "Malawi"
    iex> Faker.Address.Es.country()
    "Bielorusia"
    iex> Faker.Address.Es.country()
    "Mali"

## country_code()

Return country code.

## Examples

    iex> Faker.Address.Es.country_code()
    "ES"

## region()

Return region.[Source](https://www.ine.es/daco/daco42/codmun/cod_ccaa.htm)

## Examples

    iex> Faker.Address.Es.region()
    "Extremadura"
    iex> Faker.Address.Es.region()
    "Aragón"
    iex> Faker.Address.Es.region()
    "País Vasco"
    iex> Faker.Address.Es.region()
    "Canarias"

## secondary_address()

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

## state()

Return state. But Spain doesn't have states so this calls Faker.Address.Es.region() instead.

## state_abbr()

Return state abbr.

## Examples

    iex> Faker.Address.Es.state_abbr()
    "Ara"
    iex> Faker.Address.Es.state_abbr()
    "Cbr"
    iex> Faker.Address.Es.state_abbr()
    "Mad"
    iex> Faker.Address.Es.state_abbr()
    "Gal"

## street_address()

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

## street_address(arg1)

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

## street_name()

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

## street_prefix()

Return street prefix.

## Examples

    iex> Faker.Address.Es.street_prefix()
    "Carretera"
    iex> Faker.Address.Es.street_prefix()
    "Arrabal"
    iex> Faker.Address.Es.street_prefix()
    "Chalet"
    iex> Faker.Address.Es.street_prefix()
    "Colegio"

## street_suffix()

Return street suffix.

## Examples
    iex> Faker.Address.Es.street_suffix()
    "de arriba"
    iex> Faker.Address.Es.street_suffix()
    "Sur"
    iex> Faker.Address.Es.street_suffix()
    "de abajo"
    iex> Faker.Address.Es.street_suffix()
    "Norte"

## time_zone()

Return time zone.

## Examples

    iex> Faker.Address.Es.time_zone()
    "Australia/Sydney"
    iex> Faker.Address.Es.time_zone()
    "America/Guyana"
    iex> Faker.Address.Es.time_zone()
    "Asia/Kathmandu"
    iex> Faker.Address.Es.time_zone()
    "Europa/Vienna"

## zip_code()

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