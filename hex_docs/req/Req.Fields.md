# Req.Fields



## delete(fields, name)

Deletes the field given by `name`.

## get_list(fields)

Returns fields as list.

## get_values(fields, name)

Returns field values.

## merge(fields1, fields2)

Merges `fields1` and `fields2`.

## Examples

    iex> Req.Fields.merge(%{"a" => ["1"]}, %{"a" => ["2"], "b" => ["2"]})
    %{"a" => ["2"], "b" => ["2"]}

## new(enumerable)

Returns fields from a given enumerable.

## Examples

    iex> Req.Fields.new(a: 1, b: [1, 2])
    %{"a" => ["1"], "b" => ["1", "2"]}

    iex> Req.Fields.new(%{"a" => ["1"], "b" => ["1", "2"]})
    %{"a" => ["1"], "b" => ["1", "2"]}

## put(fields, name, value)

Adds a new field `name` with the given `value` if not present,
otherwise replaces previous value with `value`.

## put_new(fields, name, value)

Adds a field `name` unless already present.