# Ecto.Query.Builder.Combination



## apply(query, value)

The callback applied by `build/4` to build the query.

## build(kind, query, other, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.