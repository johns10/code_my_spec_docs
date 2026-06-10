# Faker.Date

Functions for generating dates

## date_of_birth/1

Returns a random date of birth for a person with an age specified by a number or range

## backward/1

Returns a random date in the past up to N days, today not included

## forward/1

Returns a random date in the future up to N days, today not included

## between/2

Returns a random date between two dates

## Examples

    iex> Faker.Date.between(~D[2010-12-10], ~D[2016-12-25])
    ~D[2013-06-07]
    iex> Faker.Date.between(~D[2000-12-20], ~D[2000-12-25])
    ~D[2000-12-20]
    iex> Faker.Date.between(~D[2000-02-02], ~D[2016-02-05])
    ~D[2014-10-23]
    iex> Faker.Date.between(~D[2010-12-20], ~D[2010-12-25])
    ~D[2010-12-21]