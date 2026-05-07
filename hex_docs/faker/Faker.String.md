# Faker.String

Function for generating Strings

## base64(length \\ 8)

Returns a random base64 String

## Examples

    iex> Faker.String.base64()
    "1tmLiMhm"
    iex> Faker.String.base64()
    "29Tee6SN"
    iex> Faker.String.base64(5)
    "Kfp7+"
    iex> Faker.String.base64(100)
    "KLJyZ7xbfJZPMy3J7dAsyfOB3vnZIqFGv4VQil8D/xh1C/Nj9K7xJk47zJtcKsy5mjpJk61Wt3jcJu3bfgwuScTmOOYt4ykzvDUl"

## naughty()

Returns a random string taken from the [Big List of Naughty Strings](https://github.com/minimaxir/big-list-of-naughty-strings).

## Examples

    iex> Faker.String.naughty()
    "̦H̬̤̗̤͝e͜ ̜̥̝̻͍̟́w̕h̖̯͓o̝͙̖͎̱̮ ҉̺̙̞̟͈W̷̼̭a̺̪͍į͈͕̭͙̯̜t̶̼̮s̘͙͖̕ ̠̫̠B̻͍͙͉̳ͅe̵h̵̬͇̫͙i̹͓̳̳̮͎̫̕n͟d̴̪̜̖ ̰͉̩͇͙̲͞ͅT͖̼͓̪͢h͏͓̮̻e̬̝̟ͅ ̤̹̝W͙̞̝͔͇͝ͅa͏͓͔̹̼̣l̴͔̰̤̟͔ḽ̫.͕"
    iex> Faker.String.naughty()
    "1#QNAN"
    iex> Faker.String.naughty()
    "Craig Cockburn, Software Specialist"
    iex> Faker.String.naughty()
    "\"\`\'><script>\\x09javascript:alert(1)</script>"
    iex> Faker.String.naughty()
    "𝚃𝚑𝚎 𝚚𝚞𝚒𝚌𝚔 𝚋𝚛𝚘𝚠𝚗 𝚏𝚘𝚡 𝚓𝚞𝚖𝚙𝚜 𝚘𝚟𝚎𝚛 𝚝𝚑𝚎 𝚕𝚊𝚣𝚢 𝚍𝚘𝚐"