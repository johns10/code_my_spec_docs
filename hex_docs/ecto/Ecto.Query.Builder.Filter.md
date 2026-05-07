# Ecto.Query.Builder.Filter



## apply(query, kind, expr)

The callback applied by `build/4` to build the query.

## build(kind, op, query, binding, expr, env)

Builds a quoted expression.

The quoted expression should evaluate to a query at runtime.
If possible, it does all calculations at compile time to avoid
runtime work.

## escape(kind, expr, binding, vars, env)

Escapes a where or having clause.

It allows query expressions that evaluate to a boolean
or a keyword list of field names and values. In a keyword
list multiple key value pairs will be joined with "and".

Returned is `{expression, {params, %{subqueries: subqueries}}}` which is
a valid escaped expression, see `Macro.escape/2`. Both `params`
and `subqueries` are reversed.

## filter!(kind, query, dynamic, binding, file, line)

Builds a filter based on the given arguments.

This is shared by having, where and join's on expressions.

## filter!(kind, op, query, dynamic, binding, file, line)

Builds the filter and applies it to the given query as boolean operator.