# Faker.Util

Collection of useful functions for your fake data. Functions aware of locale.

## pick/2

Pick a random element from an enumerable. Can also be provided a blacklist enumerable as a second argument.

## Examples

    iex> Faker.Util.pick(10..100)
    79
    iex> Faker.Util.pick([1, 3, 5, 7])
    3
    iex> Faker.Util.pick([true, false, nil])
    true
    iex> Faker.Util.pick(["a", "b", "c"], ["b"])
    "a"
    iex> Faker.Util.pick([1, "2", 3.0], 1..10)
    "2"

## sample_uniq/3

Generate N unique elements

## Examples

    iex> Faker.Util.sample_uniq(2, &Faker.Internet.email/0)
    ["conor2058@schiller.com", "elizabeth2056@rolfson.net"]

    iex> Faker.Util.sample_uniq(10, fn -> Faker.String.base64(4) end)
    ["1tmL", "29Te", "Byiy", "Kfp7", "Z7xb", "lk8z", "pI0P", "yGb0", "ye3Q", "yfOB"]

    iex> Faker.Util.sample_uniq(1, &Faker.Phone.EnUs.area_code/0)
    ["825"]

    iex> Faker.Util.sample_uniq(0, &Faker.Internet.email/0)
    ** (FunctionClauseError) no function clause matching in Faker.Util.sample_uniq/3

## list/2

Execute fun n times with the index as first param and return the results as a list

## Examples

    iex> Faker.Util.list(3, &(&1))
    [0, 1, 2]
    iex> Faker.Util.list(3, &(&1 + 1))
    [1, 2, 3]
    iex> Faker.Util.list(5, &(&1 * &1))
    [0, 1, 4, 9, 16]
    iex> Faker.Util.list(3, &(to_string(&1)))
    ["0", "1", "2"]

## join/3

Execute fun n times with the index as first param and join the results with joiner

## Examples

    iex> Faker.Util.join(3, ", ", &Faker.Code.isbn13/0)
    "9781542646109, 9783297052358, 9790203032090"
    iex> Faker.Util.join(4, "-", fn -> Faker.format("####") end)
    "7337-6033-7459-8109"
    iex> Faker.Util.join(2, " vs ", &Faker.Superhero.name/0)
    "Falcon vs Green Blink Claw"
    iex> Faker.Util.join(2, " or ", &Faker.Color.name/0)
    "Purple or White"

## to_sentence/1

Converts a list to a string, with "and" before the last item. Uses an Oxford comma.

## Examples

    iex> Faker.Util.to_sentence(["Black", "White"])
    "Black and White"
    iex> Faker.Util.to_sentence(["Jon Snow"])
    "Jon Snow"
    iex> Faker.Util.to_sentence(["Oceane", "Angeline", "Nicholas"])
    "Angeline, Nicholas, and Oceane"
    iex> Faker.Util.to_sentence(["One", "Two", "Three", "Four"])
    "Two, Three, Four, and One"

## cycle_start/1

Start a cycle. See cycle/1

## cycle/1

Cycle randomly through the given list with guarantee every element of the list is used once before
elements are being picked again. This is done by keeping a list of remaining elements that have
not been picked yet. The list of remaining element is returned, as well as the randomly picked
element.

## format/2

Format a string with randomly generated data. Format specifiers are replaced by random values. A
format specifier follows this prototype:

    %[length]specifier

The following specifier rules are present by default:

  - **d**: digits 0-9
  - **a**: lowercase letter a-z
  - **A**: uppercase letter A-Z
  - **b**: anycase letter a-z, A-Z

The specifier rules can be overridden using the second argument.

## Examples

    iex> Faker.Util.format("%2d-%3d %a%A %2d%%")
    "01-542 aS 61%"
    iex> Faker.Util.format("%8nBATMAN", n: fn() -> "nana " end)
    "nana nana nana nana nana nana nana nana BATMAN"