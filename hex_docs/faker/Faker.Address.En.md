# Faker.Address.En

Functions for generating addresses in English

## building_number()

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

## city()

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

## city_prefix()

Return city prefix.

## Examples

    iex> Faker.Address.En.city_prefix()
    "Port"
    iex> Faker.Address.En.city_prefix()
    "West"
    iex> Faker.Address.En.city_prefix()
    "North"
    iex> Faker.Address.En.city_prefix()
    "Lake"

## city_suffix()

Return city suffix.

## Examples

    iex> Faker.Address.En.city_suffix()
    "burgh"
    iex> Faker.Address.En.city_suffix()
    "mouth"
    iex> Faker.Address.En.city_suffix()
    "burgh"
    iex> Faker.Address.En.city_suffix()
    "view"

## country()

Return country.

## Examples

    iex> Faker.Address.En.country()
    "Guinea-Bissau"
    iex> Faker.Address.En.country()
    "Tuvalu"
    iex> Faker.Address.En.country()
    "Portugal"
    iex> Faker.Address.En.country()
    "United Arab Emirates"

## country_code()

Return country code.

## Examples

    iex> Faker.Address.En.country_code()
    "IT"
    iex> Faker.Address.En.country_code()
    "MR"
    iex> Faker.Address.En.country_code()
    "GM"
    iex> Faker.Address.En.country_code()
    "CX"

## secondary_address()

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

## state()

Return state.

## Examples

    iex> Faker.Address.En.state()
    "Hawaii"
    iex> Faker.Address.En.state()
    "Alaska"
    iex> Faker.Address.En.state()
    "Oklahoma"
    iex> Faker.Address.En.state()
    "California"

## state_abbr()

Return state abbr.

## Examples

    iex> Faker.Address.En.state_abbr()
    "HI"
    iex> Faker.Address.En.state_abbr()
    "AK"
    iex> Faker.Address.En.state_abbr()
    "OK"
    iex> Faker.Address.En.state_abbr()
    "CA"

## street_address()

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

## street_address(arg1)

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

## street_name()

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

## street_suffix()

Return street suffix.

## Examples

    iex> Faker.Address.En.street_suffix()
    "View"
    iex> Faker.Address.En.street_suffix()
    "Locks"
    iex> Faker.Address.En.street_suffix()
    "Freeway"
    iex> Faker.Address.En.street_suffix()
    "Lodge"

## time_zone()

Return time zone.

## Examples

    iex> Faker.Address.En.time_zone()
    "Europe/Istanbul"
    iex> Faker.Address.En.time_zone()
    "Europe/Copenhagen"
    iex> Faker.Address.En.time_zone()
    "America/Indiana/Indianapolis"
    iex> Faker.Address.En.time_zone()
    "America/Guyana"

## zip_code()

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