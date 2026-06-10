# Faker.Phone.EnGb

This follows the rules of
[Telephone numbers in the United Kingdom](https://en.wikipedia.org/wiki/Telephone_numbers_in_the_United_Kingdom).

## number/0

Returns a random UK phone number

## Examples

    iex> Faker.Phone.EnGb.number()
    "+44054264610"
    iex> Faker.Phone.EnGb.number()
    "+44562970523"
    iex> Faker.Phone.EnGb.number()
    "+447502 030320"
    iex> Faker.Phone.EnGb.number()
    "+447933 760337"

## landline_number/0

Returns a random UK landline phone number

## Examples

    iex> Faker.Phone.EnGb.landline_number()
    "+44331542646"
    iex> Faker.Phone.EnGb.landline_number()
    "+44560832970"
    iex> Faker.Phone.EnGb.landline_number()
    "+44023570203"
    iex> Faker.Phone.EnGb.landline_number()
    "+44703209733"

## cell_number/0

Returns a random UK mobile phone number

## Examples

    iex> Faker.Phone.EnGb.cell_number()
    "+447415 426461"
    iex> Faker.Phone.EnGb.cell_number()
    "07483 297052"
    iex> Faker.Phone.EnGb.cell_number()
    "+447557 020303"
    iex> Faker.Phone.EnGb.cell_number()
    "+447609 733760"