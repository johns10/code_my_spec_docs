# Ecto.Query.Builder.Select



## apply(query, expr)

The callback applied by `build/5` to build the query.

## build(kind, query, binding, expr, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## escape(atom, vars, env)

Escapes a select.

It allows tuples, lists and variables at the top level. Inside the
tuples and lists query expressions are allowed.

## Examples

    iex> escape({1, 2}, [], __ENV__)
    {{:{}, [], [:{}, [], [1, 2]]}, {[], %{take: %{}, subqueries: [], aliases: %{}}}}

    iex> escape([1, 2], [], __ENV__)
    {[1, 2], {[], %{take: %{}, subqueries: [], aliases: %{}}}}

    iex> escape(quote(do: x), [x: 0], __ENV__)
    {{:{}, [], [:&, [], [0]]}, {[], %{take: %{}, subqueries: [], aliases: %{}}}}

## fields!(tag, fields)

Called at runtime to verify a field.

## map_key!(key)

Called at runtime to verify a map key

## merge(query, new_select)

The callback applied by `build/5` when merging.

## select!(kind, query, fields, file, line)

Called at runtime for interpolated/dynamic selects.