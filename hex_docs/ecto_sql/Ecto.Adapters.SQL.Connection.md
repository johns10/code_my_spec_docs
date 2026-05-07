# Ecto.Adapters.SQL.Connection

Specifies the behaviour to be implemented by all SQL connections.

## all/1

Receives a query and must return a SELECT query.

## child_spec/1

Receives options and returns `DBConnection` supervisor child
specification.

## ddl_logs/1

Receives a query result and returns a list of logs.

## delete/4

Returns a DELETE for the `filters` returning the given `returning`.

## delete_all/1

Receives a query and must return a DELETE query.

## execute/4

Executes a cached query.

## execute_ddl/1

Receives a DDL command and returns a query that executes it.

## explain_query/4

Executes an EXPLAIN query or similar depending on the adapter to obtains statistics of the given query.

Receives the `connection`, `query`, `params` for the query,
and all `opts` including those related to the EXPLAIN statement and shared opts.

Must execute the explain query and return the result.

## insert/7

Returns an INSERT for the given `rows` in `table` returning
the given `returning`.

## prepare_execute/5

Prepares and executes the given query with `DBConnection`.

## query/4

Runs the given statement as a query.

## query_many/4

Runs the given statement as a multi-result query.

## stream/4

Returns a stream that prepares and executes the given query with
`DBConnection`.

## table_exists_query/1

Returns a queryable to check if the given `table` exists.

## to_constraints/2

Receives the exception returned by `c:query/4`.

The constraints are in the keyword list and must return the
constraint type, like `:unique`, and the constraint name as
a string, for example:

    [unique: "posts_title_index"]

Must return an empty list if the error does not come
from any constraint.

## update/5

Returns an UPDATE for the given `fields` in `table` filtered by
`filters` returning the given `returning`.

## update_all/1

Receives a query and values to update and must return an UPDATE query.

## name/0

The query name

## statement/0

The SQL statement

## cached/0

The cached query which is a DBConnection Query