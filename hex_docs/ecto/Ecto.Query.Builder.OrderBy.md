# Ecto.Query.Builder.OrderBy



## apply(query, expr, op)

The callback applied by `build/4` to build the query.

## build(query, binding, expr, op, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## dir!(kind, dir)

Called at runtime to verify the direction.

## escape(kind, expr, params_acc, vars, env)

Escapes an order by query.

The query is escaped to a list of `{direction, expression}`
pairs at runtime. Escaping also validates direction is one of
`:asc`, `:asc_nulls_last`, `:asc_nulls_first`, `:desc`,
`:desc_nulls_last` or `:desc_nulls_first`.

## Examples

    iex> escape(:order_by, quote do [x.x, desc: 13] end, {[], %{}}, [x: 0], __ENV__)
    {[asc: {:{}, [], [{:{}, [], [:., [], [{:{}, [], [:&, [], [0]]}, :x]]}, [], []]},
      desc: 13],
     {[], %{}}}

## field!(kind, field)

Called at runtime to verify a field.

## order_by!(query, exprs, op, file, line)

Called at runtime to assemble order_by.

## order_by_or_distinct!(kind, query, exprs, params)

Shared between order_by and distinct.

## quoted_dir!(kind, dir)

Checks the variable is a quoted direction at compilation time or
delegate the check to runtime for interpolation.

## update_order_bys(orders, expr, mode)

Updates the `order_bys` value for a query.

## valid_direction?(term)

Returns `true` if term is a valid order_by direction; otherwise returns `false`.

## Examples

    iex> valid_direction?(:asc)
    true

    iex> valid_direction?(:desc)
    true

    iex> valid_direction?(:invalid)
    false