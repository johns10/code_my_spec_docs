# Ecto.Query.Builder.CTE



## apply(query, name, with_query, materialized, operation)

The callback applied by `build/4` to build the query.

## build(query, name, cte, materialized, operation, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## escape(name, env)

Escapes the CTE name.

    iex> escape(quote(do: "FOO"), __ENV__)
    "FOO"