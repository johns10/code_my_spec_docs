# Ecto.Query.Builder.Lock



## apply(query, value)

The callback applied by `build/4` to build the query.

## build(query, binding, expr, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## escape(lock, vars, env)

Escapes the lock code.

    iex> escape(quote(do: "FOO"), [], __ENV__)
    "FOO"