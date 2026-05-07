# Ecto.Query.Builder.LimitOffset



## apply(query, kind, expr)

The callback applied by `build/4` to build the query.

## apply_limit(limit, with_ties)

Applies the `with_ties` value to the `limit` struct.

## build(type, query, binding, expr, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## with_ties!(with_ties)

Validates `with_ties` at runtime.