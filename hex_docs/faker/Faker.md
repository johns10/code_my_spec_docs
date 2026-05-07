# Faker

Main module to start application with some helper functions.

## country()

Returns application country.

## format(str)

Internal function to format string.

It replaces `"#"` to random number and `"?"` to random Latin letter.

## locale()

Returns application locale.

## locale(lang)

Sets application locale.

## mlocale()

Returns application locale ready for module construct.

## random_between(left, right)

Returns a (pseudo) random number as an integer between the range intervals.

## Examples

    iex> random_between(3, 7) in [3, 4, 5, 6, 7]
    true

## random_bytes(total)

Returns a random bytes.

## random_uniform()

Returns a random float in the value range 0.0 =< x < 1.0.

## Examples

    iex> is_float(random_uniform())
    true

## start()

Starts Faker with default locale.

## start(lang)

Starts Faker with `lang` locale.