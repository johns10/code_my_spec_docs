# Ecto.Query.Builder.Dynamic



## build(binding, expr, env)

Builds a dynamic expression.

## fully_expand(query, dynamic)

Expands a dynamic expression for insertion into the given query.

## partially_expand(query, dynamic, params, subqueries, aliases, count)

Expands a dynamic expression as part of an existing expression.

Any dynamic expression parameter is prepended and the parameters
list is not reversed. This is useful when the dynamic expression
is given in the middle of an expression.