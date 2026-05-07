# Faker.Internet

Functions for generating internet related data

## domain_name()

Returns a complete random domain name

## Examples

    iex> Faker.Internet.domain_name()
    "blick.org"
    iex> Faker.Internet.domain_name()
    "schumm.info"
    iex> Faker.Internet.domain_name()
    "sipes.com"
    iex> Faker.Internet.domain_name()
    "hane.info"

## domain_suffix()

Returns a random domain suffix

## Examples

    iex> Faker.Internet.domain_suffix()
    "com"
    iex> Faker.Internet.domain_suffix()
    "org"
    iex> Faker.Internet.domain_suffix()
    "name"
    iex> Faker.Internet.domain_suffix()
    "info"

## domain_word()

Returns a random domain word

## Examples

    iex> Faker.Internet.domain_word()
    "blick"
    iex> Faker.Internet.domain_word()
    "hayes"
    iex> Faker.Internet.domain_word()
    "schumm"
    iex> Faker.Internet.domain_word()
    "rolfson"

## email()

Returns a complete email based on a domain name

## Examples

    iex> Faker.Internet.email()
    "elizabeth2056@rolfson.net"
    iex> Faker.Internet.email()
    "conor2058@schiller.com"
    iex> Faker.Internet.email()
    "frederique2063@metz.name"
    iex> Faker.Internet.email()
    "jana2042@price.biz"

## free_email()

Returns a complete free email based on a free email service [gmail, yahoo, hotmail]

## Examples

    iex> Faker.Internet.free_email()
    "elizabeth2056@hotmail.com"
    iex> Faker.Internet.free_email()
    "trycia1982@hotmail.com"
    iex> Faker.Internet.free_email()
    "delphine_hartmann@yahoo.com"
    iex> Faker.Internet.free_email()
    "mitchel_rutherford@yahoo.com"

## free_email_service()

Returns a free email service

## Examples

    iex> Faker.Internet.free_email_service()
    "gmail.com"
    iex> Faker.Internet.free_email_service()
    "hotmail.com"
    iex> Faker.Internet.free_email_service()
    "gmail.com"
    iex> Faker.Internet.free_email_service()
    "hotmail.com"

## image_url()

Returns a random image url from placekitten.com | placehold.it | dummyimage.com

## Examples

    iex> Faker.Internet.image_url()
    "https://placekitten.com/131/131"
    iex> Faker.Internet.image_url()
    "https://placekitten.com/554/554"
    iex> Faker.Internet.image_url()
    "https://picsum.photos/936"
    iex> Faker.Internet.image_url()
    "https://picsum.photos/541"

## ip_v4_address()

Generates an ipv4 address

## Examples

    iex> Faker.Internet.ip_v4_address()
    "214.217.139.136"
    iex> Faker.Internet.ip_v4_address()
    "200.102.244.150"
    iex> Faker.Internet.ip_v4_address()
    "219.212.222.123"
    iex> Faker.Internet.ip_v4_address()
    "164.141.15.82"

## ip_v6_address()

Generates an ipv6 address

## Examples

    iex> Faker.Internet.ip_v6_address()
    "A2D6:F5D9:BD8B:C588:0DC8:9566:43F4:B196"
    iex> Faker.Internet.ip_v6_address()
    "05DB:FAD4:88DE:397B:75A4:A98D:DF0F:1F52"
    iex> Faker.Internet.ip_v6_address()
    "6229:4EFA:2F7B:FEF9:EB07:0128:85B2:DC72"
    iex> Faker.Internet.ip_v6_address()
    "E867:34BC:715B:FB7C:7E96:AF4F:C733:A82D"

## mac_address()

Generates a mac address

## Examples

    iex> Faker.Internet.mac_address()
    "d6:d9:8b:88:c8:66"
    iex> Faker.Internet.mac_address()
    "f4:96:db:d4:de:7b"
    iex> Faker.Internet.mac_address()
    "a4:8d:0f:52:29:fa"
    iex> Faker.Internet.mac_address()
    "7b:f9:07:28:b2:72"

## safe_email()

Returns a safe email

## Examples

    iex> Faker.Internet.safe_email()
    "elizabeth2056@example.net"
    iex> Faker.Internet.safe_email()
    "trycia1982@example.net"
    iex> Faker.Internet.safe_email()
    "delphine_hartmann@example.com"
    iex> Faker.Internet.safe_email()
    "mitchel_rutherford@example.com"

## slug()

Generates a slug
If no words are provided it will generate 2 to 5 random words
If no glue is provided it will use one of -, _ or .

## Examples

    iex> Faker.Internet.slug()
    "sint-deleniti-consequatur-ut"
    iex> Faker.Internet.slug()
    "sit_et"
    iex> Faker.Internet.slug(["foo", "bar"])
    "foo-bar"
    iex> Faker.Internet.slug(["foo", "bar"], ["."])
    "foo.bar"

## url()

Returns a random url

## Examples

    iex> Faker.Internet.url()
    "http://hayes.name"
    iex> Faker.Internet.url()
    "http://sipes.com"
    iex> Faker.Internet.url()
    "http://padberg.name"
    iex> Faker.Internet.url()
    "http://hartmann.biz"

## user_name()

Returns a random username

## Examples

    iex> Faker.Internet.user_name()
    "elizabeth2056"
    iex> Faker.Internet.user_name()
    "reese1921"
    iex> Faker.Internet.user_name()
    "aniya1972"
    iex> Faker.Internet.user_name()
    "bianka2054"