# Ecto.Query.Builder.Windows



## apply(query, definitions)

The callback applied by `build/4` to build the query.

## build(query, binding, windows, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## escape(kw, params_acc, vars, env)

Escapes a window params.

## Examples

    iex> escape(quote do [order_by: [desc: 13]] end, {[], %{}}, [x: 0], __ENV__)
    {[order_by: [desc: 13]], [], {[], %{}}}

## runtime!(query, runtime, file, line)

Invoked for runtime windows.