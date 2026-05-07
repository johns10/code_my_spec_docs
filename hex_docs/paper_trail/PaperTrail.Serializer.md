# PaperTrail.Serializer

Serialization functions to create a version struct

## add_prefix(schema, prefix)

Adds a prefix to the Ecto schema

## get_item_type(arg1)

Returns the model type, which is the last module name

## get_model_id(model)

Returns the model primary id

## get_sequence_id(table_name)

Returns the last primary key value of a table

## make_version_struct(map, model, options)

Creates a version struct for a model and a specific changeset action

## serialize(model)

Shows DB representation of an Ecto model, filters relationships and virtual attributes from an Ecto.Changeset or %ModelStruct{}

## serialize_changes(changeset)

Dumps changes using Ecto fields