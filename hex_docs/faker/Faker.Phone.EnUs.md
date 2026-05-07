# Faker.Phone.EnUs

This follows the rules outlined in the North American Numbering Plan
at https://en.wikipedia.org/wiki/North_American_Numbering_Plan.

The NANP number format may be summarized in the notation NPA-NXX-xxxx:

The allowed ranges for NPA (area code) are: [2–9] for the first digit, and
[0-9] for the second and third digits. The NANP is not assigning area codes
with 9 as the second digit.

The allowed ranges for NXX (central office/exchange) are: [2–9] for the first
digit, and [0–9] for both the second and third digits (however, in geographic
area codes the third digit of the exchange cannot be 1 if the second digit is
also 1).

The allowed ranges for xxxx (subscriber number) are [0–9] for each of the four
digits.

## area_code()

Returns a random area code

## Examples

    iex> Faker.Phone.EnUs.area_code()
    "825"
    iex> Faker.Phone.EnUs.area_code()
    "246"
    iex> Faker.Phone.EnUs.area_code()
    "681"
    iex> Faker.Phone.EnUs.area_code()
    "683"

## exchange_code()

Returns a random exchange code

## Examples

    iex> Faker.Phone.EnUs.exchange_code()
    "503"
    iex> Faker.Phone.EnUs.exchange_code()
    "845"
    iex> Faker.Phone.EnUs.exchange_code()
    "549"
    iex> Faker.Phone.EnUs.exchange_code()
    "509"

## extension(n)

Returns a random extension `n` digits long

## Examples

    iex> Faker.Phone.EnUs.extension()
    "0154"
    iex> Faker.Phone.EnUs.extension()
    "2646"
    iex> Faker.Phone.EnUs.extension(3)
    "108"
    iex> Faker.Phone.EnUs.extension(5)
    "32970"

## phone()

Returns a random US phone number

Possible returned formats:

  (123) 456-7890
  123/456-7890
  123-456-7890
  123.456.7890
  1234567890

## Examples

    iex> Faker.Phone.EnUs.phone()
    "5528621083"
    iex> Faker.Phone.EnUs.phone()
    "(730) 552-5702"
    iex> Faker.Phone.EnUs.phone()
    "652-505-3376"
    iex> Faker.Phone.EnUs.phone()
    "(377) 347-8109"

## subscriber_number(n)

Returns a random subscriber number `n` digits long

## Examples

    iex> Faker.Phone.EnUs.subscriber_number()
    "0154"
    iex> Faker.Phone.EnUs.subscriber_number()
    "2646"
    iex> Faker.Phone.EnUs.subscriber_number(2)
    "10"
    iex> Faker.Phone.EnUs.subscriber_number(5)
    "83297"