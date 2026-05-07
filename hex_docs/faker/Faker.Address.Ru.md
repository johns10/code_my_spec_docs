# Faker.Address.Ru

Functions for generating addresses in Russian

## country()

Return country.
https://ru.wikipedia.org/wiki/Список_государств

## Examples

    iex> Faker.Address.Ru.country()
    "Белоруссия"
    iex> Faker.Address.Ru.country()
    "Австрия"
    iex> Faker.Address.Ru.country()
    "Ирландия"
    iex> Faker.Address.Ru.country()
    "Тринидад и Тобаго"

## state()

Return state.
https://ru.wikipedia.org/wiki/Субъекты_Российской_Федерации

## Examples

    iex> Faker.Address.Ru.state()
    "Самарская область"
    iex> Faker.Address.Ru.state()
    "Орловская область"
    iex> Faker.Address.Ru.state()
    "Рязанская область"
    iex> Faker.Address.Ru.state()
    "Волгоградская область"