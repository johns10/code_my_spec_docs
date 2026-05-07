# Ecto.Query.Planner



## attach_prefix(query, opts)

Puts the prefix given via `opts` into the given query, if available.

## ensure_select(query, fields)

Used for customizing the query returning result.

## new_query_cache(atom_name)

Define the query cache table.

## normalize(query, operation, adapter, counter)

Normalizes and validates the query.

After the query was planned and there is no cache
entry, we need to update its interpolations and check
its fields and associations exist and are valid.

## plan(query, operation, adapter, cte_names \\ %{})

Prepares the query for cache.

This means all the parameters from query expressions are
merged into a single value and their entries are pruned
from the query.

This function is called by the backend before invoking
any cache mechanism.

## plan_assocs(query)

Prepare association fields found in the query.

## plan_cache(query, operation, adapter)

Prepare the parameters by merging and casting them according to sources.

## plan_sources(query, adapter, cte_names)

Prepare all sources, by traversing and expanding from, joins, subqueries.

## query(query, operation, cache, adapter, counter)

Plans the query for execution.

Planning happens in multiple steps:

  1. First the query is planned by retrieving
     its cache key, casting and merging parameters

  2. Then a cache lookup is done, if the query is
     cached, we are done

  3. If there is no cache, we need to actually
     normalize and validate the query, asking the
     adapter to prepare it

  4. The query is sent to the adapter to be generated

## Cache

All entries in the query, except the preload and sources
field, should be part of the cache key.

The cache value is the compiled query by the adapter
along-side the select expression.

## query_to_joins(qual, source, map, position)

Converts a query to a list of joins.

The from is moved as last join with the where conditions as its "on"
in order to keep proper binding order.

## rewrite_sources(part, mapping)

Rewrites the given query expression sources using the given mapping.