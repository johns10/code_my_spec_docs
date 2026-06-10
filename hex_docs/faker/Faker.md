# Faker

Main module to start application with some helper functions.

## start/0

Starts Faker with default locale.

## start/1

Starts Faker with `lang` locale.

## format/1

Internal function to format string.

It replaces `"#"` to random number and `"?"` to random Latin letter.

## mlocale/0

Returns application locale ready for module construct.

## locale/0

Returns application locale.

## country/0

Returns application country.

## locale/1

Sets application locale.

## random_uniform/0

Returns a random float in the value range 0.0 =< x < 1.0.

## Examples

    iex> is_float(random_uniform())
    true

## random_between/2

Returns a (pseudo) random number as an integer between the range intervals.

## Examples

    iex> random_between(3, 7) in [3, 4, 5, 6, 7]
    true

## random_bytes/1

Returns a random bytes.