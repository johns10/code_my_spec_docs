# Faker.Nato

Functions for generating NATO alphabet data

## stop_code_word/0

Returns the NATO stop code

## Examples

    iex> Faker.Nato.stop_code_word()
    "STOP"

## callsign/0

Returns a random NATO call sign of the form [alpha]-[alpha]-[digit]

## Examples

    iex> Faker.Nato.callsign()
    "ECHO-LIMA-SIX"
    iex> Faker.Nato.callsign()
    "CHARLIE-ECHO-SEVEN"
    iex> Faker.Nato.callsign()
    "SIERRA-GOLF-TWO"
    iex> Faker.Nato.callsign()
    "INDIA-WHISKEY-FOUR"

## format/1

Formats a string using the NATO alphabet.

It replaces `"#"` to a random NATO digit, `"?"` to random NATO letter
and `"."` to the stop code.

## Examples

    iex> Faker.Nato.format("#-?-#-.")
    "ONE-LIMA-SIX-STOP"
    iex> Faker.Nato.format("#-?-#-.")
    "FIVE-ECHO-SEVEN-STOP"
    iex> Faker.Nato.format("#-?-#-.")
    "FIVE-GOLF-TWO-STOP"
    iex> Faker.Nato.format("#-?-#-.")
    "ONE-WHISKEY-FOUR-STOP"