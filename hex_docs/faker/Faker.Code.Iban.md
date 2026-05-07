# Faker.Code.Iban

Functions for generating IBANs (International Bank Account Numbers).

The generated IBANs should pass validators that check the checksum, country code, format and
length of the IBAN.

When more precision is required, you can pass predefined components that will be included in the
generated IBAN. The components will not be validated, but are used when calculating the checksum.

## Examples

    iex> Faker.Code.Iban.iban
    "GI88LRCE6SQ3CQJGP3UHAJD"
    iex> Faker.Code.Iban.iban("NL")
    "NL26VYOC3032097337"
    iex> Faker.Code.Iban.iban(["NL", "BE"])
    "NL74YRFX4598109960"
    iex> Faker.Code.Iban.iban(["NL", "BE"])
    "BE31198979502980"

## iban()

Returns a random IBAN from a random country

## Examples

    iex> Faker.Code.Iban.iban
    "GI88LRCE6SQ3CQJGP3UHAJD"
    iex> Faker.Code.Iban.iban
    "BR0302030320973376033745981CB"
    iex> Faker.Code.Iban.iban
    "BE98607198979502"
    iex> Faker.Code.Iban.iban
    "PT72807856869061130164499"

## iban(country_code_or_codes)

Returns a random IBAN for a specific country code, or a random country code from a given list of
country codes.

## Examples

    iex> Faker.Code.Iban.iban("FR")
    "FR650154264610QJGP3UHAJDJ02"
    iex> Faker.Code.Iban.iban("BE")
    "BE95030320973376"
    iex> Faker.Code.Iban.iban(["NL", "BE"])
    "NL31RFXY5981099607"
    iex> Faker.Code.Iban.iban(["BE", "DE"])
    "DE57989795029807856869"

## iban(country_code, prefix_components)

Returns a random IBAN starting with the given components. The given components are not validated
but are included in the checksum.

## Examples

    iex> Faker.Code.Iban.iban("NL", ["ABNA"])
    "NL16ABNA0154264610"
    iex> Faker.Code.Iban.iban("MC", ["FOO", "BAR"])
    "MC98FOOBAR83"
    iex> Faker.Code.Iban.iban("SM", ["A"])
    "SM86A2970523570AY38NWIVZ5XT"
    iex> Faker.Code.Iban.iban("MC", ["FOO", "BAR"])
    "MC40FOOBAR60"