# Faker.Address.It

Functions for generating addresses in Italian

## building_number()

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

## city()

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

## city_prefix()

Return city prefix.

## Examples

    iex> Faker.Address.It.city_prefix()
    "Quarto"
    iex> Faker.Address.It.city_prefix()
    "Castello"
    iex> Faker.Address.It.city_prefix()
    "Quarto"
    iex> Faker.Address.It.city_prefix()
    "Santa"

## city_suffix()

Return city suffix.

## Examples

    iex> Faker.Address.It.city_suffix()
    "di sotto"
    iex> Faker.Address.It.city_suffix()
    "di sopra"
    iex> Faker.Address.It.city_suffix()
    "Marittima"

## country()

Return country.
List from http://publications.europa.eu/code/it/it-5000500.htm

## Examples

    iex> Faker.Address.It.country()
    "Etiopia"
    iex> Faker.Address.It.country()
    "Cipro"
    iex> Faker.Address.It.country()
    "Timor Leste"
    iex> Faker.Address.It.country()
    "Nicaragua"

## country_code()

Return country code.
List from http://publications.europa.eu/code/it/it-5000500.htm

## Examples

    iex> Faker.Address.It.country_code()
    "CO"
    iex> Faker.Address.It.country_code()
    "LV"

## province()

Return province name.
Data from https://dait.interno.gov.it/servizi-demografici/documentazione/anagaire-tabelle-comuni-province-consolati-statiterritori
If you call region(), province() or province_abbr() separately you'll end up with
inconsistent data. For example: "Lombardia", "Roma", "GE".
If you want consisten data call region_province_abbr() instead, which will return
something like ["Lombardia", "Milano", "MI"].

    ## Examples

    iex> Faker.Address.It.province()
    "Barletta-Andria-Trani"
    iex> Faker.Address.It.province()
    "Trento"
    iex> Faker.Address.It.province()
    "Pavia"
    iex> Faker.Address.It.province()
    "Caserta"

## province_abbr()

Return province code.
Data from https://dait.interno.gov.it/servizi-demografici/documentazione/anagaire-tabelle-comuni-province-consolati-statiterritori
If you call region(), province() or province_abbr() separately you'll end up with
inconsistent data. For example: "Lombardia", "Roma", "GE".
If you want consisten data call region_province_abbr() instead, which will return
something like ["Lombardia", "Milano", "MI"].

  ## Examples

    iex> Faker.Address.It.province_abbr()
    "BA"
    iex> Faker.Address.It.province_abbr()
    "TR"
    iex> Faker.Address.It.province_abbr()
    "PG"
    iex> Faker.Address.It.province_abbr()
    "CE"

## region()

Return region.
If you call region(), province() or province_abbr() separately you'll end up with
inconsistent data. For example: "Lombardia", "Roma", "GE".
If you want consisten data call region_province_abbr() instead, which will return
something like ["Lombardia", "Milano", "MI"].

    ## Examples

    iex> Faker.Address.It.region()
    "Molise"
    iex> Faker.Address.It.region()
    "Basilicata"
    iex> Faker.Address.It.region()
    "Toscana"
    iex> Faker.Address.It.region()
    "Emilia-Romagna"

## region_province_abbr()

Return a consistent list containing the region and province names with the province code.
Data from https://dait.interno.gov.it/servizi-demografici/documentazione/anagaire-tabelle-comuni-province-consolati-statiterritori

## Examples

    iex> Faker.Address.It.region_province_abbr()
    ["Calabria", "Reggio di Calabria", "RC"]
    iex> Faker.Address.It.region_province_abbr()
    ["Trentino-Alto Adige/Südtirol", "Bolzano/Bozen", "BZ"]
    iex> Faker.Address.It.region_province_abbr()
    ["Puglia", "Bari", "BA"]
    iex> Faker.Address.It.region_province_abbr()
    ["Emilia-Romagna", "Piacenza", "PC"]

## secondary_address()

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

## state()

Return state. But Italy doesn't have states so this calls Faker.Address.It.region() instead

## state_abbr()

There are no state/region abbreviations in Italy.

## street_address()

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

## street_address(arg1)

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

## street_name()

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

## street_prefix()

Return street prefix.

  ## Examples

    iex> Faker.Address.It.street_prefix()
    "Vicolo"
    iex> Faker.Address.It.street_prefix()
    "Corso"
    iex> Faker.Address.It.street_prefix()
    "Piazzale"
    iex> Faker.Address.It.street_prefix()
    "Piazza"

## time_zone()

Return time zone.

  ## Examples

    iex> Faker.Address.It.time_zone()
    "Australia/Sydney"
    iex> Faker.Address.It.time_zone()
    "America/Guyana"
    iex> Faker.Address.It.time_zone()
    "Asia/Kathmandu"
    iex> Faker.Address.It.time_zone()
    "Europa/Vienna"

## zip_code()

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