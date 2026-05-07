# Faker.DateTime

Functions for working with `DateTime` values.

## backward(days)

Returns a random date in the past up to N days, today not included

## Examples

    iex> Faker.DateTime.backward(4)
    #=> %DateTime{calendar: Calendar.ISO, day: 20, hour: 6,
    #=>  microsecond: {922180, 6},  minute: 2, month: 12, second: 17,
    #=>  std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2016,
    #=>  zone_abbr: "UTC"}

## between(from, to)

Returns a random DateTime between two dates

## Examples

    iex> Faker.DateTime.between(~N[2016-12-20 00:00:00], ~N[2016-12-25 00:00:00])
    #=> %DateTime{calendar: Calendar.ISO, day: 22, hour: 7,
    #=>  microsecond: {753572, 6},  minute: 56, month: 12, second: 26,
    #=>  std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2016,
    #=>  zone_abbr: "UTC"}

## forward(days)

Returns a random date in the future up to N days, today not included

## Examples

    iex> Faker.DateTime.forward(4)
    #=> %DateTime{calendar: Calendar.ISO, day: 25, hour: 6,
    #=>  microsecond: {922180, 6},  minute: 2, month: 12, second: 17,
    #=>  std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2016,
    #=>  zone_abbr: "UTC"}