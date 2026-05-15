# Jason.OrderedObject



## %Jason.OrderedObject{}

Struct implementing a JSON object retaining order of properties.

A wrapper around a keyword (that supports non-atom keys) allowing for
proper protocol implementations.

Implements the `Access` behaviour and `Enumerable` protocol with
complexity similar to keywords/lists.

## new(values)

Creates a new ordered object from a list of key-value pairs.

## Example

    iex> %{a: 1, c: 3, b: 2}
    ...> |> Enum.sort()
    ...> |> Jason.OrderedObject.new()
    ...> |> Jason.encode!()
    "{\"a\":1,\"b\":2,\"c\":3}"