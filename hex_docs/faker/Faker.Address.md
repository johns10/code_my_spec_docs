# Faker.Address

Functions for generating addresses.

## building_number()

Return random building number.

## Examples

    iex> Faker.Address.building_number()
    "15426"
    iex> Faker.Address.building_number()
    "6"
    iex> Faker.Address.building_number()
    "0832"
    iex> Faker.Address.building_number()
    "7"

## city()

Return city name.

## Examples

    iex> Faker.Address.city()
    "Elizabeth"
    iex> Faker.Address.city()
    "Rolfson"
    iex> Faker.Address.city()
    "West Conor"
    iex> Faker.Address.city()
    "Hardy"

## city_prefix()

Return city prefix.

## Examples

    iex> Faker.Address.city_prefix()
    "Port"
    iex> Faker.Address.city_prefix()
    "West"
    iex> Faker.Address.city_prefix()
    "North"
    iex> Faker.Address.city_prefix()
    "Lake"

## city_suffix()

Return city suffix.

## Examples

    iex> Faker.Address.city_suffix()
    "burgh"
    iex> Faker.Address.city_suffix()
    "mouth"
    iex> Faker.Address.city_suffix()
    "burgh"
    iex> Faker.Address.city_suffix()
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

    iex> Faker.Address.country_code()
    "IT"
    iex> Faker.Address.country_code()
    "MR"
    iex> Faker.Address.country_code()
    "GM"
    iex> Faker.Address.country_code()
    "CX"

## geohash()

Returns a geohash.

## Examples

    iex> Faker.Address.geohash()
    "1kgw0"
    iex> Faker.Address.geohash()
    "575152tr612btt"
    iex> Faker.Address.geohash()
    "20kxxzd9k22m6jedp"
    iex> Faker.Address.geohash()
    "06kjmd2wtwjp2px"

## latitude()

Return random latitude.

## Examples

    iex> Faker.Address.latitude()
    -62.20459142744528
    iex> Faker.Address.latitude()
    -59.39243543011051
    iex> Faker.Address.latitude()
    15.346881460762518
    iex> Faker.Address.latitude()
    -72.94522080668256

## longitude()

Return random longitude.

## Examples

    iex> Faker.Address.longitude()
    -124.40918285489056
    iex> Faker.Address.longitude()
    -118.78487086022102
    iex> Faker.Address.longitude()
    30.693762921525035
    iex> Faker.Address.longitude()
    -145.8904416133651

## postcode()

Return random postcode.

## Examples

    iex> Faker.Address.postcode()
    "01542"
    iex> Faker.Address.postcode()
    "64610"
    iex> Faker.Address.postcode()
    "83297"
    iex> Faker.Address.postcode()
    "05235"

## secondary_address()

Return random secondary address.

## Examples

    iex> Faker.Address.secondary_address()
    "Apt. 154"
    iex> Faker.Address.secondary_address()
    "Apt. 646"
    iex> Faker.Address.secondary_address()
    "Suite 083"
    iex> Faker.Address.secondary_address()
    "Apt. 970"

## state()

Return state.

## Examples

    iex> Faker.Address.state()
    "Hawaii"
    iex> Faker.Address.state()
    "Alaska"
    iex> Faker.Address.state()
    "Oklahoma"
    iex> Faker.Address.state()
    "California"

## state_abbr()

Return state abbr.

## Examples

    iex> Faker.Address.state_abbr()
    "HI"
    iex> Faker.Address.state_abbr()
    "AK"
    iex> Faker.Address.state_abbr()
    "OK"
    iex> Faker.Address.state_abbr()
    "CA"

## street_address()

Return street address.

## Examples

    iex> Faker.Address.street_address()
    "15426 Aniya Mews"
    iex> Faker.Address.street_address()
    "83297 Jana Spring"
    iex> Faker.Address.street_address()
    "57 Helene Mission"
    iex> Faker.Address.street_address()
    "03 Izaiah Land"

## street_address(arg1)

Return `street_address/0` or if argument is `true` adds `secondary_address/0`.

## Examples

    iex> Faker.Address.street_address(true)
    "15426 Aniya Mews Apt. 832"
    iex> Faker.Address.street_address(true)
    "7 Jana Spring Suite 570"
    iex> Faker.Address.street_address(true)
    "030 Kozey Knoll Suite 733"
    iex> Faker.Address.street_address(true)
    "603 Homenick Shore Suite 981"

## street_name()

Return street name.

## Examples

    iex> Faker.Address.street_name()
    "Elizabeth Freeway"
    iex> Faker.Address.street_name()
    "Reese Plaza"
    iex> Faker.Address.street_name()
    "Aniya Mews"
    iex> Faker.Address.street_name()
    "Bianka Heights"

## street_suffix()

Return street suffix.

## Examples

    iex> Faker.Address.street_suffix()
    "View"
    iex> Faker.Address.street_suffix()
    "Locks"
    iex> Faker.Address.street_suffix()
    "Freeway"
    iex> Faker.Address.street_suffix()
    "Lodge"

## time_zone()

Return time zone.

## Examples

    iex> Faker.Address.time_zone()
    "Europe/Istanbul"
    iex> Faker.Address.time_zone()
    "Europe/Copenhagen"
    iex> Faker.Address.time_zone()
    "America/Indiana/Indianapolis"
    iex> Faker.Address.time_zone()
    "America/Guyana"

## zip()

Return random postcode.

## Examples

    iex> Faker.Address.zip()
    "01542"
    iex> Faker.Address.zip()
    "64610"
    iex> Faker.Address.zip()
    "83297"
    iex> Faker.Address.zip()
    "05235"

## zip_code()

Return random postcode.

## Examples

    iex> Faker.Address.zip_code()
    "01542"
    iex> Faker.Address.zip_code()
    "64610"
    iex> Faker.Address.zip_code()
    "83297"
    iex> Faker.Address.zip_code()
    "05235"