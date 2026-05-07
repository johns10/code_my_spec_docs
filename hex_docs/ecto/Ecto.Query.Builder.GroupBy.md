# Ecto.Query.Builder.GroupBy



## apply(query, expr)

The callback applied by `build/4` to build the query.

## build(query, binding, expr, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## escape(kind, expr, params_acc, vars, env)

Escapes a list of quoted expressions.

See `Ecto.Builder.escape/2`.

    iex> escape(:group_by, quote do [x.x, 13] end, {[], %{}}, [x: 0], __ENV__)
    {[{:{}, [], [{:{}, [], [:., [], [{:{}, [], [:&, [], [0]]}, :x]]}, [], []]},
      13],
     {[], %{}}}

## field!(kind, field)

Called at runtime to verify a field.

## group_by!(query, group_by, file, line)

Called at runtime to assemble group_by.

## group_or_partition_by!(kind, query, exprs, params)

Shared between group_by and partition_by.