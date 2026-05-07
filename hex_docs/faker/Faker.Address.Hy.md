# Faker.Address.Hy

Functions for generating addresses in Armenian

## building_number()

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

## city()

Returns city name.

## Examples

    iex> Faker.Address.Hy.city()
    "Ստեփանավան"
    iex> Faker.Address.Hy.city()
    "Մարալիկ"
    iex> Faker.Address.Hy.city()
    "Ճամբարակ"
    iex> Faker.Address.Hy.city()
    "Մեղրի"

## city_prefix()

Returns city prefix.

## Examples

    iex> Faker.Address.Hy.city_prefix()
    "ք."

## country()

Returns country.

## Examples

    iex> Faker.Address.Hy.country()
    "Ֆրանսիա"
    iex> Faker.Address.Hy.country()
    "Նիդերլանդներ"
    iex> Faker.Address.Hy.country()
    "Ղազախստան"
    iex> Faker.Address.Hy.country()
    "Թուրքմենստան"

## secondary_address()

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

## state()

Returns state.

## Examples

    iex> Faker.Address.Hy.state()
    "Արագածոտն"
    iex> Faker.Address.Hy.state()
    "Արարատ"
    iex> Faker.Address.Hy.state()
    "Կոտայք"
    iex> Faker.Address.Hy.state()
    "Լոռի"

## state_abbr()

Returns state abbr.

## Examples

    iex> Faker.Address.Hy.state_abbr()
    "ԱԳ"
    iex> Faker.Address.Hy.state_abbr()
    "ԱՐ"
    iex> Faker.Address.Hy.state_abbr()
    "ԿՏ"
    iex> Faker.Address.Hy.state_abbr()
    "ԼՌ"

## street_address()

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

## street_address(arg1)

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

## street_name()

Returns street name.

## Examples

    iex> Faker.Address.Hy.street_name()
    "Սուրբ Հովհաննեսի"
    iex> Faker.Address.Hy.street_name()
    "Մոսկովյան"
    iex> Faker.Address.Hy.street_name()
    "Սերգեյ Փարաջանովի"
    iex> Faker.Address.Hy.street_name()
    "Պրահայի"

## street_suffix()

Returns street suffix.

## Examples

    iex> Faker.Address.Hy.street_suffix()
    "նրբանցք"
    iex> Faker.Address.Hy.street_suffix()
    "պողոտա"
    iex> Faker.Address.Hy.street_suffix()
    "փակուղի"
    iex> Faker.Address.Hy.street_suffix()
    "փողոց"

## zip_code()

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