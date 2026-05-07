# Decimal

Decimal arithmetic on arbitrary precision floating-point numbers.

A number is represented by a signed coefficient and exponent such that: `sign
* coefficient * 10 ^ exponent`. All numbers are represented and calculated
exactly, but the result of an operation may be rounded depending on the
context the operation is performed with, see: `Decimal.Context`. Trailing
zeros in the coefficient are never truncated to preserve the number of
significant digits unless explicitly done so.

There are also special values such as NaN (not a number) and ±Infinity.
-0 and +0 are two distinct values.
Some operation results are not defined and will return NaN.
This kind of NaN is quiet, any operation returning a number will return
NaN when given a quiet NaN (the NaN value will flow through all operations).

Exceptional conditions are grouped into signals, each signal has a flag and a
trap enabler in the context. Whenever a signal is triggered it's flag is set
in the context and will be set until explicitly cleared. If the signal is trap
enabled `Decimal.Error` will be raised.

## Specifications

  * [IBM's General Decimal Arithmetic Specification](http://speleotrove.com/decimal/decarith.html)
  * [IEEE standard 854-1987](http://web.archive.org/web/20150908012941/http://754r.ucbtest.org/standards/854.pdf)

This library follows the above specifications for reference of arithmetic
operation implementations, but the public APIs may differ to provide a
more idiomatic Elixir interface.

The specification models the sign of the number as 1, for a negative number,
and 0 for a positive number. Internally this implementation models the sign as
1 or -1 such that the complete number will be `sign * coefficient *
10 ^ exponent` and will refer to the sign in documentation as either *positive*
or *negative*.

There is currently no maximum or minimum values for the exponent. Because of
that all numbers are "normal". This means that when an operation should,
according to the specification, return a number that "underflows" 0 is returned
instead of Etiny. This may happen when dividing a number with infinity.
Additionally, overflow, underflow and clamped may never be signalled.

## abs(num)

The absolute value of given number. Sets the number's sign to positive.

## Examples

    iex> Decimal.abs(Decimal.new("1"))
    Decimal.new("1")

    iex> Decimal.abs(Decimal.new("-1"))
    Decimal.new("1")

    iex> Decimal.abs(Decimal.new("NaN"))
    Decimal.new("NaN")

## add(num1, num2)

Adds two numbers together.

## Exceptional conditions

  * If one number is -Infinity and the other +Infinity, `:invalid_operation` will
    be signalled.

## Examples

    iex> Decimal.add(1, "1.1")
    Decimal.new("2.1")

    iex> Decimal.add(1, "Inf")
    Decimal.new("Infinity")

## apply_context(num)

Applies the context to the given number rounding it to specified precision.

## cast(integer)

Creates a new decimal number from an integer, string, float, or existing decimal number.

Because conversion from a floating point number is not exact, it's recommended
to instead use `new/1` or `from_float/1` when the argument's type is certain.
See `from_float/1`.

## Examples

    iex> {:ok, decimal} = Decimal.cast(3)
    iex> decimal
    Decimal.new("3")

    iex> Decimal.cast("bad")
    :error

## compare(num1, num2)

Compares two numbers numerically. If the first number is greater than the second
`:gt` is returned, if less than `:lt` is returned, if both numbers are equal
`:eq` is returned.

Neither number can be a NaN.

## Examples

    iex> Decimal.compare("1.0", 1)
    :eq

    iex> Decimal.compare("Inf", -1)
    :gt

## compare(n1, n2, threshold)

Compares two numbers numerically using a threshold. If the first number added
to the threshold is greater than the second number, and the first number
subtracted by the threshold is smaller than the second number, then the two
numbers are considered equal.

## Examples

    iex> Decimal.compare("1.1", 1, "0.2")
    :eq

    iex> Decimal.compare("1.2", 1, "0.1")
    :gt

    iex> Decimal.compare("1.0", "1.2", "0.1")
    :lt

## div(num1, num2)

Divides two numbers.

## Exceptional conditions

  * If both numbers are ±Infinity `:invalid_operation` is signalled.
  * If both numbers are ±0 `:invalid_operation` is signalled.
  * If second number (denominator) is ±0 `:division_by_zero` is signalled.

## Examples

    iex> Decimal.div(3, 4)
    Decimal.new("0.75")

    iex> Decimal.div("Inf", -1)
    Decimal.new("-Infinity")

## div_int(num1, num2)

Divides two numbers and returns the integer part.

## Exceptional conditions

  * If both numbers are ±Infinity `:invalid_operation` is signalled.
  * If both numbers are ±0 `:invalid_operation` is signalled.
  * If second number (denominator) is ±0 `:division_by_zero` is signalled.

## Examples

    iex> Decimal.div_int(5, 2)
    Decimal.new("2")

    iex> Decimal.div_int("Inf", -1)
    Decimal.new("-Infinity")

## div_rem(num1, num2)

Integer division of two numbers and the remainder. Should be used when both
`div_int/2` and `rem/2` is needed. Equivalent to: `{Decimal.div_int(x, y),
Decimal.rem(x, y)}`.

## Exceptional conditions

  * If both numbers are ±Infinity `:invalid_operation` is signalled.
  * If both numbers are ±0 `:invalid_operation` is signalled.
  * If second number (denominator) is ±0 `:division_by_zero` is signalled.

## Examples

    iex> Decimal.div_rem(5, 2)
    {Decimal.new(2), Decimal.new(1)}

## eq?(num1, num2)

Compares two numbers numerically and returns `true` if they are equal,
otherwise `false`. If one of the operands is a quiet NaN this operation
will always return `false`.

## Examples

    iex> Decimal.eq?("1.0", 1)
    true

    iex> Decimal.eq?(1, -1)
    false

## eq?(num1, num2, thresrold)

It compares the equality of two numbers. If the second number is within
the range of first - threshold and first + threshold, it returns true;
otherwise, it returns false.

## Examples

    iex> Decimal.eq?("1.0", 1, "0")
    true

    iex> Decimal.eq?("1.2", 1, "0.1")
    false

    iex> Decimal.eq?("1.2", 1, "0.2")
    true

    iex> Decimal.eq?(1, -1, "0.0")
    false

## equal?(num1, num2)

Compares two numbers numerically and returns `true` if they are equal,
otherwise `false`. If one of the operands is a quiet NaN this operation
will always return `false`.

## Examples

    iex> Decimal.equal?("1.0", 1)
    true

    iex> Decimal.equal?(1, -1)
    false

## from_float(float)

Creates a new decimal number from a floating point number.

Floating point numbers use a fixed number of binary digits to represent
a decimal number which has inherent inaccuracy as some decimal numbers cannot
be represented exactly in limited precision binary.

Floating point numbers will be converted to decimal numbers with
`:io_lib_format.fwrite_g/1`. Since this conversion is not exact and
because of inherent inaccuracy mentioned above, we may run into counter-intuitive results:

    iex> Enum.reduce([0.1, 0.1, 0.1], &+/2)
    0.30000000000000004

    iex> Enum.reduce([Decimal.new("0.1"), Decimal.new("0.1"), Decimal.new("0.1")], &Decimal.add/2)
    Decimal.new("0.3")

For this reason, it's recommended to build decimals with `new/1`, which is always precise, instead.

## Examples

    iex> Decimal.from_float(3.14)
    Decimal.new("3.14")

## gt?(num1, num2)

Compares two numbers numerically and returns `true` if the first argument
is greater than the second, otherwise `false`. If one the operands is a
quiet NaN this operation will always return `false`.

## Examples

    iex> Decimal.gt?("1.3", "1.2")
    true

    iex> Decimal.gt?("1.2", "1.3")
    false

## gte?(num1, num2)

Compares two numbers numerically and returns `true` if
the first argument is greater than or equal the second,
otherwise `false`.

If one the operands is a quiet NaN this operation
will always return `false`.

## Examples

    iex> Decimal.gte?("1.3", "1.3")
    true

    iex> Decimal.gte?("1.3", "1.2")
    true

    iex> Decimal.gte?("1.2", "1.3")
    false

## inf?(decimal)

Returns `true` if number is ±Infinity, otherwise `false`.

## Examples

    iex> Decimal.inf?(Decimal.new("+Infinity"))
    true

    iex> Decimal.inf?(Decimal.new("-Infinity"))
    true

    iex> Decimal.inf?(Decimal.new("1.5"))
    false

## integer?(num)

Returns `true` when the given `decimal` has no significant digits after the decimal point.

## Examples

    iex> Decimal.integer?("1.00")
    true

    iex> Decimal.integer?("1.10")
    false

## lt?(num1, num2)

Compares two numbers numerically and returns `true` if the first number is
less than the second number, otherwise `false`. If one of the operands is a
quiet NaN this operation will always return `false`.

## Examples

    iex> Decimal.lt?("1.1", "1.2")
    true

    iex> Decimal.lt?("1.4", "1.2")
    false

## lte?(num1, num2)

Compares two numbers numerically and returns `true` if
the first number is less than or equal the second number,
otherwise `false`.

If one of the operands is a quiet NaN this operation
will always return `false`.

## Examples

    iex> Decimal.lte?("1.1", "1.1")
    true

    iex> Decimal.lte?("1.1", "1.2")
    true

    iex> Decimal.lte?("1.4", "1.2")
    false

## max(num1, num2)

Compares two values numerically and returns the maximum. Unlike most other
functions in `Decimal` if a number is NaN the result will be the other number.
Only if both numbers are NaN will NaN be returned.

## Examples

    iex> Decimal.max(1, "2.0")
    Decimal.new("2.0")

    iex> Decimal.max(1, "NaN")
    Decimal.new("1")

    iex> Decimal.max("NaN", "NaN")
    Decimal.new("NaN")

## min(num1, num2)

Compares two values numerically and returns the minimum. Unlike most other
functions in `Decimal` if a number is NaN the result will be the other number.
Only if both numbers are NaN will NaN be returned.

## Examples

    iex> Decimal.min(1, "2.0")
    Decimal.new("1")

    iex> Decimal.min(1, "NaN")
    Decimal.new("1")

    iex> Decimal.min("NaN", "NaN")
    Decimal.new("NaN")

## mult(num1, num2)

Multiplies two numbers.

## Exceptional conditions

  * If one number is ±0 and the other is ±Infinity `:invalid_operation` is
    signalled.

## Examples

    iex> Decimal.mult("0.5", 3)
    Decimal.new("1.5")

    iex> Decimal.mult("Inf", -1)
    Decimal.new("-Infinity")

## nan?(decimal)

Returns `true` if number is NaN, otherwise `false`.

## Examples

    iex> Decimal.nan?(Decimal.new("NaN"))
    true

    iex> Decimal.nan?(Decimal.new(42))
    false

## negate(num)

Negates the given number.

## Examples

    iex> Decimal.negate(1)
    Decimal.new("-1")

    iex> Decimal.negate("-Inf")
    Decimal.new("Infinity")

## negative?(decimal)

Returns `true` if given number is negative, otherwise `false`.

## Examples

    iex> Decimal.negative?(Decimal.new("-42"))
    true

    iex> Decimal.negative?(Decimal.new("42"))
    false

    iex> Decimal.negative?(Decimal.new("0"))
    false

    iex> Decimal.negative?(Decimal.new("NaN"))
    false

## new(num)

Creates a new decimal number from an integer or a string representation.

A decimal number will always be created exactly as specified with all digits
kept - it will not be rounded with the context.

## Backus–Naur form

    sign           ::=  "+" | "-"
    digit          ::=  "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
    indicator      ::=  "e" | "E"
    digits         ::=  digit [digit]...
    decimal-part   ::=  digits "." [digits] | ["."] digits
    exponent-part  ::=  indicator [sign] digits
    infinity       ::=  "Infinity" | "Inf"
    nan            ::=  "NaN" [digits]
    numeric-value  ::=  decimal-part [exponent-part] | infinity
    numeric-string ::=  [sign] numeric-value | [sign] nan

## Floats

See also `from_float/1`.

## Examples

    iex> Decimal.new(1)
    Decimal.new("1")

    iex> Decimal.new("3.14")
    Decimal.new("3.14")

## new(sign, coef, exp)

Creates a new decimal number from the sign, coefficient and exponent such that
the number will be: `sign * coefficient * 10 ^ exponent`.

A decimal number will always be created exactly as specified with all digits
kept - it will not be rounded with the context.

## Examples

    iex> Decimal.new(1, 42, 0)
    Decimal.new("42")

## normalize(num)

Normalizes the given decimal: removes trailing zeros from coefficient while
keeping the number numerically equivalent by increasing the exponent.

## Examples

    iex> Decimal.normalize(Decimal.new("1.00"))
    Decimal.new("1")

    iex> Decimal.normalize(Decimal.new("1.01"))
    Decimal.new("1.01")

## parse(binary)

Parses a binary into a decimal.

If successful, returns a tuple in the form of `{decimal, remainder_of_binary}`,
otherwise `:error`.

## Examples

    iex> Decimal.parse("3.14")
    {%Decimal{coef: 314, exp: -2, sign: 1}, ""}

    iex> Decimal.parse("3.14.15")
    {%Decimal{coef: 314, exp: -2, sign: 1}, ".15"}

    iex> Decimal.parse("-1.1e3")
    {%Decimal{coef: 11, exp: 2, sign: -1}, ""}

    iex> Decimal.parse("bad")
    :error

## positive?(decimal)

Returns `true` if given number is positive, otherwise `false`.

## Examples

    iex> Decimal.positive?(Decimal.new("42"))
    true

    iex> Decimal.positive?(Decimal.new("-42"))
    false

    iex> Decimal.positive?(Decimal.new("0"))
    false

    iex> Decimal.positive?(Decimal.new("NaN"))
    false

## rem(num1, num2)

Remainder of integer division of two numbers. The result will have the sign of
the first number.

## Exceptional conditions

  * If both numbers are ±Infinity `:invalid_operation` is signalled.
  * If both numbers are ±0 `:invalid_operation` is signalled.
  * If second number (denominator) is ±0 `:division_by_zero` is signalled.

## Examples

    iex> Decimal.rem(5, 2)
    Decimal.new("1")

## round(num, places \\ 0, mode \\ :half_up)

Rounds the given number to specified decimal places with the given strategy
(default is to round to nearest one). If places is negative, at least that
many digits to the left of the decimal point will be zero.

See `Decimal.Context` for more information about rounding algorithms.

## Examples

    iex> Decimal.round("1.234")
    Decimal.new("1")

    iex> Decimal.round("1.234", 1)
    Decimal.new("1.2")

## scale(decimal)

Returns the scale of the decimal.

A decimal's scale is the number of digits after the decimal point. This
includes trailing zeros; see `normalize/1` to remove them.

## Examples

    iex> Decimal.scale(Decimal.new("42"))
    0

    iex> Decimal.scale(Decimal.new(1, 2, 26))
    0

    iex> Decimal.scale(Decimal.new("99.12345"))
    5

    iex> Decimal.scale(Decimal.new("1.50"))
    2

## sqrt(num)

Finds the square root.

## Examples

    iex> Decimal.sqrt("100")
    Decimal.new("10")

## sub(num1, num2)

Subtracts second number from the first. Equivalent to `Decimal.add/2` when the
second number's sign is negated.

## Exceptional conditions

  * If one number is -Infinity and the other +Infinity `:invalid_operation` will
    be signalled.

## Examples

    iex> Decimal.sub(1, "0.1")
    Decimal.new("0.9")

    iex> Decimal.sub(1, "Inf")
    Decimal.new("-Infinity")

## to_float(decimal)

Returns the decimal converted to a float.

The returned float may have lower precision than the decimal. Fails if
the decimal cannot be converted to a float.

## Examples

    iex> Decimal.to_float(Decimal.new("1.5"))
    1.5

## to_integer(decimal)

Returns the decimal represented as an integer.

Fails when loss of precision will occur.

## Examples

    iex> Decimal.to_integer(Decimal.new("42"))
    42

    iex> Decimal.to_integer(Decimal.new("1.00"))
    1

    iex> Decimal.to_integer(Decimal.new("1.10"))
    ** (ArgumentError) cannot convert Decimal.new("1.1") without losing precision. Use Decimal.round/3 first.

## to_string(num, type \\ :scientific)

Converts given number to its string representation.

## Options

  * `:scientific` - number converted to scientific notation.
  * `:normal` - number converted without a exponent.
  * `:xsd` - number converted to the [canonical XSD representation](https://www.w3.org/TR/xmlschema-2/#decimal).
  * `:raw` - number converted to its raw, internal format.

## Examples

    iex> Decimal.to_string(Decimal.new("1.00"))
    "1.00"

    iex> Decimal.to_string(Decimal.new("123e1"), :scientific)
    "1.23E+3"

    iex> Decimal.to_string(Decimal.new("42.42"), :normal)
    "42.42"

    iex> Decimal.to_string(Decimal.new("1.00"), :xsd)
    "1.0"

    iex> Decimal.to_string(Decimal.new("4321.768"), :raw)
    "4321768E-3"

## is_decimal(term)

Returns `true` if argument is a decimal number, otherwise `false`.

## Examples

    iex> Decimal.is_decimal(Decimal.new(42))
    true

    iex> Decimal.is_decimal(42)
    false

Allowed in guard tests on OTP 21+.

## coefficient/0

The coefficient of the power of `10`. Non-negative because the sign is stored separately in `sign`.

  * `non_neg_integer` - when the `t` represents a number, instead of one of the special values below.
  * `:NaN` - Not a Number.
  * `:inf` - Infinity.

## exponent/0

The exponent to which `10` is raised.

## sign/0

* `1` for positive
  * `-1` for negative

## rounding/0

Rounding algorithm.

See `Decimal.Context` for more information.

## t/0

This implementation models the `sign` as `1` or `-1` such that the complete number will be: `sign * coef * 10 ^ exp`.

  * `coef` - the coefficient of the power of `10`.
  * `exp` - the exponent of the power of `10`.
  * `sign` - `1` for positive, `-1` for negative.