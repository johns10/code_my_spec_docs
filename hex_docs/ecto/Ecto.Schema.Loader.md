# Ecto.Schema.Loader



## load_struct(schema, prefix, source)

Loads a struct to be used as a template in further operations.

## safe_dump(struct, types, dumper)

Dumps the given data.

## unsafe_load(schema, data, loader)

Loads data coming from the user/embeds into schema.

Assumes data does not all belong to schema/struct
and that it may also require source-based renaming.

## unsafe_load(struct, types, map, loader)

Loads data coming from the user/embeds into struct and types.

Assumes data does not all belong to schema/struct
and that it may also require source-based renaming.