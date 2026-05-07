# Faker.Address.PtBr

Functions for generating addresses in Portuguese

## building_number()

Return random building number.

## Examples

    iex> Faker.Address.PtBr.building_number()
    "s/n"
    iex> Faker.Address.PtBr.building_number()
    "5426"
    iex> Faker.Address.PtBr.building_number()
    "6"
    iex> Faker.Address.PtBr.building_number()
    "0832"

## city()

Return city name.

## Examples

    iex> Faker.Address.PtBr.city()
    "Senador Kaique Paulista"
    iex> Faker.Address.PtBr.city()
    "São Roberta dos Dourados"
    iex> Faker.Address.PtBr.city()
    "Salto das Flores"
    iex> Faker.Address.PtBr.city()
    "Kléber"

## city_prefix()

Return city suffixes.

## Examples

    iex> Faker.Address.PtBr.city_prefix()
    "Santo"
    iex> Faker.Address.PtBr.city_prefix()
    "Senador"
    iex> Faker.Address.PtBr.city_prefix()
    "Senador"
    iex> Faker.Address.PtBr.city_prefix()
    "Alta"

## city_suffixes()

Return city suffixes.

## Examples

    iex> Faker.Address.PtBr.city_suffixes()
    "da Serra"
    iex> Faker.Address.PtBr.city_suffixes()
    "dos Dourados"
    iex> Faker.Address.PtBr.city_suffixes()
    "da Serra"
    iex> Faker.Address.PtBr.city_suffixes()
    "Paulista"

## country()

Return country.

## Examples

    iex> Faker.Address.PtBr.country()
    "Ilhas Virgens Britânicas"
    iex> Faker.Address.PtBr.country()
    "Coreia do Sul"
    iex> Faker.Address.PtBr.country()
    "Bolívia"
    iex> Faker.Address.PtBr.country()
    "Mongólia"

## country_code()

Return country code.

## Examples

    iex> Faker.Address.PtBr.country_code()
    "BR"

## neighborhood()

Return neighborhood.

## Examples

    iex> Faker.Address.PtBr.neighborhood()
    "Granja De Freitas"
    iex> Faker.Address.PtBr.neighborhood()
    "Novo Ouro Preto"
    iex> Faker.Address.PtBr.neighborhood()
    "Padre Eustáquio"
    iex> Faker.Address.PtBr.neighborhood()
    "Nossa Senhora Aparecida"

## secondary_address()

Return random secondary address.

## Examples

    iex> Faker.Address.PtBr.secondary_address()
    "Sala 154"
    iex> Faker.Address.PtBr.secondary_address()
    "Sala 646"
    iex> Faker.Address.PtBr.secondary_address()
    "AP 083"
    iex> Faker.Address.PtBr.secondary_address()
    "Sala 970"

## state()

Return state.

## Examples

    iex> Faker.Address.PtBr.state()
    "Rondônia"
    iex> Faker.Address.PtBr.state()
    "Rio Grande do Sul"
    iex> Faker.Address.PtBr.state()
    "Distrito Federal"
    iex> Faker.Address.PtBr.state()
    "Ceará"

## state_abbr()

Return state abbr.

## Examples

    iex> Faker.Address.PtBr.state_abbr()
    "RO"
    iex> Faker.Address.PtBr.state_abbr()
    "RS"
    iex> Faker.Address.PtBr.state_abbr()
    "DF"
    iex> Faker.Address.PtBr.state_abbr()
    "CE"

## street_address()

Return street address.

## Examples

    iex> Faker.Address.PtBr.street_address()
    "Estação Kaique, 2"
    iex> Faker.Address.PtBr.street_address()
    "Lagoa Matheus, 0832"
    iex> Faker.Address.PtBr.street_address()
    "Estrada Diegues, s/n"
    iex> Faker.Address.PtBr.street_address()
    "Praia Limeira, 020"

## street_address(arg1)

Return `street_address/0` or if argument is `true` adds `secondary_address/0`.

## Examples

    iex> Faker.Address.PtBr.street_address(true)
    "Estação Kaique, 2 Sala 461"
    iex> Faker.Address.PtBr.street_address(false)
    "Conjunto Rodrigo, 970"
    iex> Faker.Address.PtBr.street_address(false)
    "Trecho Davi Luiz Limeira, 020"
    iex> Faker.Address.PtBr.street_address(false)
    "Sítio Maria Eduarda, 097"

## street_name()

Return street name.

## Examples

    iex> Faker.Address.PtBr.street_name()
    "Estação Kaique"
    iex> Faker.Address.PtBr.street_name()
    "Morro Louise Macieira"
    iex> Faker.Address.PtBr.street_name()
    "Loteamento Maria Alice Junqueira"
    iex> Faker.Address.PtBr.street_name()
    "Condomínio da Maia"

## street_prefix()

Return street prefix.

## Examples

    iex> Faker.Address.PtBr.street_prefix()
    "Recanto"
    iex> Faker.Address.PtBr.street_prefix()
    "Estação"
    iex> Faker.Address.PtBr.street_prefix()
    "Feira"
    iex> Faker.Address.PtBr.street_prefix()
    "Fazenda"

## time_zone()

Return time zone.

## Examples

    iex> Faker.Address.PtBr.time_zone()
    "Australia/Sydney"
    iex> Faker.Address.PtBr.time_zone()
    "America/Guyana"
    iex> Faker.Address.PtBr.time_zone()
    "Asia/Kathmandu"
    iex> Faker.Address.PtBr.time_zone()
    "Europa/Vienna"

## zip_code()

Return random postcode.

## Examples

    iex> Faker.Address.PtBr.zip_code()
    "15426461"
    iex> Faker.Address.PtBr.zip_code()
    "83297052"
    iex> Faker.Address.PtBr.zip_code()
    "57.020-303"
    iex> Faker.Address.PtBr.zip_code()
    "09733-760"