# Faker.Blockchain.Bitcoin

Functions for generate random bitcoin addresses.

## address(format \\ :main)

Return bitcoin address. If pass `:testnet` it'll generate testnet address.

## Examples

    iex> Faker.Blockchain.Bitcoin.address()
    "1Lb2DM8vNXubePBWV7xmRnqJp5YT3BatcQ"
    iex> Faker.Blockchain.Bitcoin.address()
    "1erV2PhPaR4ndbEvLWDD9KX8btdNJZXt5"
    iex> Faker.Blockchain.Bitcoin.address(:main)
    "1Pn5NbAbT5hZocVWKSBtmqygdVbeVoheWk"
    iex> Faker.Blockchain.Bitcoin.address(:testnet)
    "mj1Vh7G8JZxg8gBtcQic2opTxtKUCQBBc5"