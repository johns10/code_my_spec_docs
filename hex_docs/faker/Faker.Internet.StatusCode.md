# Faker.Internet.StatusCode

Functions for generating HTTP status codes

## client_error()

Returns a client error status code

## Examples

    iex> Faker.Internet.StatusCode.client_error()
    428
    iex> Faker.Internet.StatusCode.client_error()
    405
    iex> Faker.Internet.StatusCode.client_error()
    424
    iex> Faker.Internet.StatusCode.client_error()
    424

## information()

Returns an information status code

## Examples

    iex> Faker.Internet.StatusCode.information()
    102
    iex> Faker.Internet.StatusCode.information()
    101
    iex> Faker.Internet.StatusCode.information()
    103
    iex> Faker.Internet.StatusCode.information()
    100

## redirect()

Returns a redirect status code

## Examples

    iex> Faker.Internet.StatusCode.redirect()
    303
    iex> Faker.Internet.StatusCode.redirect()
    302
    iex> Faker.Internet.StatusCode.redirect()
    306
    iex> Faker.Internet.StatusCode.redirect()
    305

## server_error()

Returns a server error status code

## Examples

    iex> Faker.Internet.StatusCode.server_error()
    503
    iex> Faker.Internet.StatusCode.server_error()
    506
    iex> Faker.Internet.StatusCode.server_error()
    506
    iex> Faker.Internet.StatusCode.server_error()
    506

## success()

Returns a success status code

## Examples

    iex> Faker.Internet.StatusCode.success()
    200
    iex> Faker.Internet.StatusCode.success()
    201
    iex> Faker.Internet.StatusCode.success()
    205
    iex> Faker.Internet.StatusCode.success()
    204