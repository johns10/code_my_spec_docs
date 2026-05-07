# Faker.Finance.Stock

Functions for stock data

## ticker()

Returns a ticker.

## Examples

    iex> Faker.Finance.Stock.ticker()
    "7401.N225"
    iex> Faker.Finance.Stock.ticker()
    "4786.HK"
    iex> Faker.Finance.Stock.ticker()
    "6766.N225"
    iex> Faker.Finance.Stock.ticker()
    "5166.N225"

## ticker(atom1, atom2)

The first argument is the ticker format.
The second argument is the name of the exchange.

## Examples

    iex> Faker.Finance.Stock.ticker(:reuters, :nikkei225)
    "2110.N225"
    iex> Faker.Finance.Stock.ticker(:reuters, :nikkei225)
    "7401.N225"
    iex> Faker.Finance.Stock.ticker(:reuters, :nikkei225)
    "9835.N225"
    iex> Faker.Finance.Stock.ticker(:reuters, :nikkei225)
    "8304.N225"
    iex> Faker.Finance.Stock.ticker(:reuters, :sehk)
    "7564.HK"
    iex> Faker.Finance.Stock.ticker(:reuters, :sehk)
    "3609.HK"
    iex> Faker.Finance.Stock.ticker(:reuters, :sehk)
    "1085.HK"
    iex> Faker.Finance.Stock.ticker(:reuters, :sehk)
    "5849.HK"