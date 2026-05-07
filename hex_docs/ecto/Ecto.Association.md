# Ecto.Association



## apply_defaults(struct, defaults, owner)

Applies default values into the struct.

## association_from_schema!(schema, assoc)

Retrieves the association from the given schema.

## association_key(module, suffix)

Returns the association key for the given module with the given suffix.

## Examples

    iex> Ecto.Association.association_key(Hello.World, :id)
    :world_id

    iex> Ecto.Association.association_key(Hello.HTTP, :id)
    :http_id

    iex> Ecto.Association.association_key(Hello.HTTPServer, :id)
    :http_server_id

## combine_assoc_query(query, conditions)

Add the default assoc query where clauses a provided query.

## combine_joins_query(query, conditions, binding)

Add the default assoc query where clauses to a join.

This handles only `where` and converts it to a `join`,
as that is the only information propagate in join queries.

## filter_through_chain(owner, through, values)

Build an association query through the given associations from the specified owner table
and through the given associations. Finally filter by the provided values of the owner_key of
the first relationship in the chain. Used in Ecto.assoc/2.

## join_through_chain(owner, through, query)

Join the target table given a list of associations to go through starting from the owner table.

## joins_query(query, through, counter)

Build a join query with the given `through` associations starting at `counter`.

## merge_source(schema, query)

Merges source from query into to the given schema.

In case the query does not have a source, returns
the schema unchanged.

## on_repo_change(changeset, assocs, adapter, opts)

Performs the repository action in the related changeset,
returning `{:ok, data}` or `{:error, changes}`.

## related_from_query(atom, name)

Retrieves related module from queryable.

## Examples

    iex> Ecto.Association.related_from_query({"custom_source", Schema}, :comments_v1)
    Schema

    iex> Ecto.Association.related_from_query(Schema, :comments_v1)
    Schema

    iex> Ecto.Association.related_from_query("wrong", :comments_v1)
    ** (ArgumentError) association :comments_v1 queryable must be a schema or a {source, schema}. got: "wrong"

## update_parent_prefix(changeset, arg2)

Updates the prefix of a changeset based on the metadata.

## validate_defaults!(module, name, defaults)

Validates `defaults` for association named `name`.

## validate_preload_order!(name, preload_order)

Validates `preload_order` for association named `name`.

## after_verify_validation/1

Invoked after the schema is compiled to validate associations.

Useful for checking if associated modules exist without running
into deadlocks.

## assoc_query/3

Returns the association query on top of the given query.

If the query is `nil`, the association target must be used.

This callback receives the association struct and it must return
a query that retrieves all associated entries with the given
values for the owner key.

This callback is used by `Ecto.assoc/2` and when preloading.

## build/3

Builds a struct for the given association.

The struct to build from is given as argument in case default values
should be set in the struct.

Invoked by `Ecto.build_assoc/3`.

## joins_query/1

Returns an association join query.

This callback receives the association struct and it must return
a query that retrieves all associated entries using joins up to
the owner association.

For example, a `has_many :comments` inside a `Post` module would
return:

    from c in Comment, join: p in Post, on: c.post_id == p.id

Note all the logic must be expressed inside joins, as fields like
`where` and `order_by` won't be used by the caller.

This callback is invoked when `join: assoc(p, :comments)` is used
inside queries.

## on_repo_change/5

Performs the repository change on the association.

Receives the parent changeset, the current changesets
and the repository action options. Must return the
persisted struct (or nil) or the changeset error.

## preload_info/1

Returns information used by the preloader.

## struct/3

Builds the association struct.

The struct must be defined in the module that implements the
callback and it must contain at least the following keys:

  * `:cardinality` - tells if the association is one to one
    or one/many to many

  * `:field` - tells the field in the owner struct where the
    association should be stored

  * `:owner` - the owner module of the association

  * `:owner_key` - the key in the owner with the association value

  * `:relationship` - if the relationship to the specified schema is
    of a `:child` or a `:parent`