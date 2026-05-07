# Faker.NaiveDateTime



## backward(days)

Returns a random date in the past up to N days, today not included

## Examples

    iex> Faker.NaiveDateTime.backward(4)
    #=> ~N[2016-12-20 06:02:17.922180]

## between(from, to)

Returns a random `NaiveDateTime.t` between two `NaiveDateTime.t`'s

## Examples

    iex> Faker.NaiveDateTime.between(~N[2016-12-20 00:00:00], ~N[2016-12-25 00:00:00])
    #=> ~N[2016-12-23 06:02:17.922180]

## forward(days)

Returns a random date in the future up to N days, today not included

## Examples

    iex> Faker.NaiveDateTime.forward(4)
    #=> ~N[2016-12-25 06:02:17.922180]