# PaperTrail.Serializer

Serialization functions to create a version struct

## make_version_struct/3

Creates a version struct for a model and a specific changeset action

## get_sequence_id/1

Returns the last primary key value of a table

## serialize/1

Shows DB representation of an Ecto model, filters relationships and virtual attributes from an Ecto.Changeset or %ModelStruct{}

## serialize_changes/1

Dumps changes using Ecto fields

## add_prefix/2

Adds a prefix to the Ecto schema

## get_item_type/1

Returns the model type, which is the last module name

## get_model_id/1

Returns the model primary id