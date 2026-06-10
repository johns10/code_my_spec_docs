# Faker.Address.It

Functions for generating addresses in Italian

## building_number/0

Return random building number.

## Examples

    iex> Faker.Address.It.building_number()
    "154"
    iex> Faker.Address.It.building_number()
    "64"
    iex> Faker.Address.It.building_number()
    "1"
    iex> Faker.Address.It.building_number()
    "832"

## city/0

Return city name.

## Examples

    iex> Faker.Address.It.city()
    "Dionigi Marittima"
    iex> Faker.Address.It.city()
    "Quarto Gennaro"
    iex> Faker.Address.It.city()
    "Sesto Maurizia"
    iex> Faker.Address.It.city()
    "Case di Taffy"

## secondary_address/0

Return random secondary address.

  ## Examples

    iex> Faker.Address.It.secondary_address()
    "/A"
    iex> Faker.Address.It.secondary_address()
    "/B"
    iex> Faker.Address.It.secondary_address()
    "/A"
    iex> Faker.Address.It.secondary_address()
    "Edificio 26"

## state/0

Return state. But Italy doesn't have states so this calls Faker.Address.It.region() instead

## state_abbr/0

There are no state/region abbreviations in Italy.

## street_address/0

Return street address.

  ## Examples

    iex> Faker.Address.It.street_address()
    "Corso Agave, 2"
    iex> Faker.Address.It.street_address()
    "Viale Keith, 083"
    iex> Faker.Address.It.street_address()
    "Strada per Liguria, 523"
    iex> Faker.Address.It.street_address()
    "Viale De Rosa, 03"

## street_address/1

Return `street_address/0` or if argument is `true` adds `secondary_address/0`.

  ## Examples

    iex> Faker.Address.It.street_address(true)
    "Corso Agave, 2/B"
    iex> Faker.Address.It.street_address(false)
    "Via per Piemonte, 832"
    iex> Faker.Address.It.street_address(false)
    "Vicolo Longo, 2"
    iex> Faker.Address.It.street_address(false)
    "Via Privata Galli, 2"

## street_name/0

Return street name.

  ## Examples

    iex> Faker.Address.It.street_name()
    "Corso Agave"
    iex> Faker.Address.It.street_name()
    "Via Privata Gennaro Mazza"
    iex> Faker.Address.It.street_name()
    "Vicolo Shaula Lombardi"
    iex> Faker.Address.It.street_name()
    "Strada per Giuliani"

## zip_code/0

Return random postcode.

  ## Examples

    iex> Faker.Address.It.zip_code()
    "01542"
    iex> Faker.Address.It.zip_code()
    "64610"
    iex> Faker.Address.It.zip_code()
    "83297"
    iex> Faker.Address.It.zip_code()
    "05235"