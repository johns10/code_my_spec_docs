# Ecto.Query.Builder.Update



## apply(query, expr)

The callback applied by `build/4` to build the query.

## build(query, binding, expr, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## escape(expr, vars, env)

Escapes a list of quoted expressions.

    iex> escape([], [], __ENV__)
    {[], [], []}

    iex> escape([set: []], [], __ENV__)
    {[], [], []}

    iex> escape(quote(do: ^[set: []]), [], __ENV__)
    {[], [set: []], []}

    iex> escape(quote(do: [set: ^[foo: 1]]), [], __ENV__)
    {[], [set: [foo: 1]], []}

    iex> escape(quote(do: [set: [foo: ^1]]), [], __ENV__)
    {[], [set: [foo: 1]], []}

## update!(query, runtime, file, line)

If there are interpolated updates at compile time,
we need to handle them at runtime. We do such in
this callback.