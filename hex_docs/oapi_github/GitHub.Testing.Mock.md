# GitHub.Testing.Mock

Internal representation of a mocked API call

## args/0

Specification of arguments

Each set of arguments can be given as a list of elements to match or a total arity. When given
as a list, each element can be any Erlang term or the special value `:_` to match any value.
Specifications given as a list will have higher precedence depending on the number of arguments
that match exactly.

## limit/0

Limit to the number of times a mock can be used

The special value `:infinity` can be used to place no limit.

## return/0

Return value from a mocked API call

Return values are tagged tuples with optional additional information. For example:

    {:ok, %GitHub.Repository{}}
    {:ok, %GitHub.Repository{}, code: 200}
    {:error, %GitHub.Error{}}
    {:error, %GitHub.Error{}, code: 404}

For more on the possible values, see `GitHub.Testing`.

## return_fun/0

Return value or generator of a mocked API call

This may be a constant (value) or a zero-arity function returning a constant (generator).

## t/0

Mocked API call