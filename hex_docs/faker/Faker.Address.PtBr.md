# Faker.Address.PtBr

Functions for generating addresses in Portuguese

## building_number/0

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

## city/0

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

## secondary_address/0

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

## street_address/0

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

## street_address/1

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

## street_name/0

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

## zip_code/0

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