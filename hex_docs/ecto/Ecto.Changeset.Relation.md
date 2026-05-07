# Ecto.Changeset.Relation



## apply_changes(map, changeset)

Applies related changeset changes

## cast(relation, owner, params, current, on_cast)

Casts related according to the `on_cast` function.

## change(relation, value, current)

Wraps related structs in changesets.

## empty(map)

Returns empty container for relation.

## empty?(map, changes)

Checks if the container can be considered empty.

## filter_empty(changes)

Filter empty changes

## load!(struct, loaded)

Loads the relation with the given struct.

Loading will fail if the association is not loaded but the struct is.

## on_replace(arg1, changeset_or_struct)

Handles the changeset or struct when being replaced.

## build/2

Builds the related data.