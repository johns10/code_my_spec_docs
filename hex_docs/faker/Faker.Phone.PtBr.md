# Faker.Phone.PtBr

Function to generate Brazilian phone numbers.

## generate_region_code()

Pick a random region code from list

## Examples
    iex> Faker.Phone.PtBr.generate_region_code()
    "92"
    iex> Faker.Phone.PtBr.generate_region_code()
    "31"
    iex> Faker.Phone.PtBr.generate_region_code()
    "71"
    iex> Faker.Phone.PtBr.generate_region_code()
    "71"

## number_with_region(number)

Replace 'xx' for a random region number picked.

## Examples
    iex> Faker.Phone.PtBr.number_with_region("(xx) 9 1542-6461")
    "(92) 9 1542-6461"
    iex> Faker.Phone.PtBr.number_with_region("(xx) 4329-7052")
    "(31) 4329-7052"
    iex> Faker.Phone.PtBr.number_with_region("(xx) 9 7020-3032")
    "(71) 9 7020-3032"
    iex> Faker.Phone.PtBr.number_with_region("(xx) 5733-7603")
    "(71) 5733-7603"

## phone()

Returns a random phone number.

## Examples

    iex> Faker.Phone.PtBr.phone()
    "(75) 9 1542-6461"
    iex> Faker.Phone.PtBr.phone()
    "(75) 4329-7052"
    iex> Faker.Phone.PtBr.phone()
    "(69) 9 7020-3032"
    iex> Faker.Phone.PtBr.phone()
    "(75) 5733-7603"