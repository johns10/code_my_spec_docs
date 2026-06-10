# Faker.Address

Functions for generating addresses.

## geohash/0

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

## latitude/0

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

## longitude/0

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

## street_address/0

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

## street_address/1

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

## street_name/0

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