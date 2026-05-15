# Anubis.Client.JSONSchemaConverter



## to_peri(json_schema)

Converts a JSON Schema (Draft 7) into a Peri schema.

## validator(json_schema)

Creates a validator function from a JSON Schema.

Returns a function that takes a value and returns either
`{:ok, value}` or `{:error, errors}`.