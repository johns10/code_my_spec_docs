# Ecto.Query.Builder



## add_select_alias(aliases, name)

Called by the select escaper at compile time and dynamic builder at runtime to track select aliases

## apply_query(query, module, args, env)

Applies a query at compilation time or at runtime.

This function is responsible for checking if a given query is an
`Ecto.Query` struct at compile time. If it is not it will act
accordingly.

If a query is available, it invokes the `apply` function in the
given `module`, otherwise, it delegates the call to runtime.

It is important to keep in mind the complexities introduced
by this function. In particular, a %Query{} is a mixture of escaped
and unescaped expressions which makes it impossible for this
function to properly escape or unescape it at compile/runtime.
For this reason, the apply function should be ready to handle
arguments in both escaped and unescaped form.

For example, take into account the `Builder.OrderBy`:

    select = %Ecto.Query.QueryExpr{expr: expr, file: env.file, line: env.line}
    Builder.apply_query(query, __MODULE__, [order_by], env)

`expr` is already an escaped expression and we must not escape
it again. However, it is wrapped in an Ecto.Query.QueryExpr,
which must be escaped! Furthermore, the `apply/2` function
in `Builder.OrderBy` very likely will inject the QueryExpr inside
Query, which again, is a mixture of escaped and unescaped expressions.

That said, you need to obey the following rules:

1. In order to call this function, the arguments must be escapable
   values supported by the `escape/1` function below;

2. The apply function may not manipulate the given arguments,
   with exception to the query.

In particular, when invoked at compilation time, all arguments
(except the query) will be escaped, so they can be injected into
the query properly, but they will be in their runtime form
when invoked at runtime.

## atom!(atom, used_ref)

Called by escaper at runtime to verify that value is an atom.

## atom_or_string!(atom, used_ref)

Called by escaper at runtime to verify that value is an atom or string.

## bump_interpolations(expr, params)

Bump interpolations by the length of parameters.

## bump_subqueries(expr, subqueries)

Bump subqueries by the count of pre-existing subqueries.

## constant!(constant)

Called by escaper at runtime to verify constant in fragments.

## count_alias!(query, name)

Count the alias for the given query.

## count_binds(query)

Counts the bindings in a query expression.

## Examples

    iex> count_binds(%Ecto.Query{joins: [1,2,3]})
    4

## error!(message)

Raises a query building error.

## escape(expr, type, params_acc, vars, env)

Smart escapes a query expression and extracts interpolated values in
a map.

Everything that is a query expression will be escaped, interpolated
expressions (`^foo`) will be moved to a map unescaped and replaced
with `^index` in the query where index is a number indexing into the
map.

## escape_binding(query, binding, env)

Escapes a list of bindings as a list of atoms.

Only variables or `{:atom, value}` tuples are allowed in the `bindings` list,
otherwise an `Ecto.Query.CompileError` is raised.

## Examples

    iex> escape_binding(%Ecto.Query{}, quote(do: [x, y, z]), __ENV__)
    {%Ecto.Query{}, [x: 0, y: 1, z: 2]}

    iex> escape_binding(%Ecto.Query{}, quote(do: [{x, 0}, {z, 2}]), __ENV__)
    {%Ecto.Query{}, [x: 0, z: 2]}

    iex> escape_binding(%Ecto.Query{}, quote(do: [x, y, x]), __ENV__)
    ** (Ecto.Query.CompileError) variable `x` is bound twice

    iex> escape_binding(%Ecto.Query{}, quote(do: [a, b, :foo]), __ENV__)
    ** (Ecto.Query.CompileError) binding list should contain only variables or `{as, var}` tuples, got: :foo

## escape_params(list)

Escape the params entries list.

## escape_select_aliases(aliases)

Escape the select alias map

## escape_var!(var, vars)

Escapes a variable according to the given binds.

A escaped variable is represented internally as
`&0`, `&1` and so on.

## find_var!(var, vars)

Finds the index value for the given var in vars or raises.

## fragment!(kw)

Called by escaper at runtime to verify fragment keywords.

## fragment_pieces(frag, args)

Returns fragment pieces, given a fragment string and arguments.

## identifier!(identifier)

Called by escaper at runtime to verify identifier in fragments.

## interval!(interval)

Called by escaper at runtime to verify that value is a valid interval.

## json_path!(path)

Called by escaper at runtime to verify that path is a list

## json_path_element!(binary)

Called by escaper at runtime to verify that value is a string or an integer.

## late_binding!(kind, value)

Checks if the value of a late binding is an interpolation or
a quoted atom.

## negate!(decimal)

Negates the given number.

## not_nil!(not_nil, compare_str)

Called by escaper at runtime to verify that a value is not nil.

## quoted_atom!(atom, used_ref)

Checks if the field is an atom at compilation time or
delegates the check to runtime for interpolation.

## quoted_atom_or_string!(atom, used_ref)

Checks if the field is an atom or string at compilation time or
delegate the check to runtime for interpolation.

## quoted_interval!(other)

Checks if the field is a valid interval at compilation time or
delegate the check to runtime for interpolation.

## quoted_type(list, vars)

Returns the type of an expression at build time.

## splice!(value)

Called by escaper at runtime to verify splice in fragments.

## validate_type!(type, vars, env)

Validates the type with the given vars.

## quoted_type/0

Quoted types store primitive types and types in the format
{source, quoted}. The latter are handled directly in the planner,
never forwarded to Ecto.Type.

The Ecto.Type module concerns itself only with runtime types,
which include all primitive types and custom user types. Also
note custom user types do not show up during compilation time.

## acc/0

The accumulator during escape.

If the subqueries field is available, subquery escaping must take place.