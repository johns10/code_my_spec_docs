# Ecto.Query.Builder.Distinct



## apply(query, expr)

The callback applied by `build/4` to build the query.

## build(query, binding, expr, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## distinct!(query, distinct, file, line)

Called at runtime to verify distinct.

## escape(expr, params_acc, vars, env)

Escapes a list of quoted expressions.

    iex> escape(quote do true end, {[], %{}}, [], __ENV__)
    {true, {[], %{}}}

    iex> escape(quote do [x.x, 13] end, {[], %{}}, [x: 0], __ENV__)
    {[asc: {:{}, [], [{:{}, [], [:., [], [{:{}, [], [:&, [], [0]]}, :x]]}, [], []]},
      asc: 13],
     {[], %{}}}