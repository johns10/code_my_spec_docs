# Faker.Commerce.PtBr

Functions for generating commerce related data in Brazilian Portuguese.

## color/0

Returns a random color.

## Examples

    iex> Faker.Commerce.PtBr.color()
    "Vermelho(a)"
    iex> Faker.Commerce.PtBr.color()
    "Verde"
    iex> Faker.Commerce.PtBr.color()
    "Marrom"
    iex> Faker.Commerce.PtBr.color()
    "Rosa"

## product_name/0

Returns a complete product name, based on product adjectives, product
materials, product names

## Examples

    iex> Faker.Commerce.PtBr.product_name()
    "Cadeira Gigante de Algodão"
    iex> Faker.Commerce.PtBr.product_name()
    "Computador de Granito"
    iex> Faker.Commerce.PtBr.product_name()
    "Bolsa Médio(a)"
    iex> Faker.Commerce.PtBr.product_name()
    "Escrivaninha Grande"