# Req.Fields



## merge/2

Merges `fields1` and `fields2`.

## Examples

    iex> Req.Fields.merge(%{"a" => ["1"]}, %{"a" => ["2"], "b" => ["2"]})
    %{"a" => ["2"], "b" => ["2"]}

## get_values/2

Returns field values.

## map/2

Maps field values using `fun`, preserving field names.

## Examples

    iex> Req.Fields.map(%{"a" => ["1", "2"]}, fn _name, value -> value <> "0" end)
    %{"a" => ["10", "20"]}

## prepend/2

Prepends `new_fields` before `fields`, keeping any existing values.

## Examples

    iex> Req.Fields.prepend(%{"a" => ["1"]}, [{"a", "2"}, {"b", "3"}])
    %{"a" => ["2", "1"], "b" => ["3"]}

## put/3

Adds a new field `name` with the given `value` if not present,
otherwise replaces previous value with `value`.

## put_new/3

Adds a field `name` unless already present.

## delete/2

Deletes the field given by `name`.

## get_list/1

Returns fields as list.