# Poison



## encode/2

Encode a value to JSON.

    iex> Poison.encode([1, 2, 3])
    {:ok, "[1,2,3]"}

## encode!/2

Encode a value to JSON, raises an exception on error.

    iex> Poison.encode!([1, 2, 3])
    "[1,2,3]"

## decode/2

Decode JSON to a value.

    iex> Poison.decode("[1,2,3]")
    {:ok, [1, 2, 3]}

## decode!/1

Decode JSON to a value, raises an exception on error.

    iex> Poison.decode!("[1,2,3]")
    [1, 2, 3]