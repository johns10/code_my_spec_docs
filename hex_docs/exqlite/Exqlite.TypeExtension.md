# Exqlite.TypeExtension

A behaviour that defines the API for extensions providing custom data loaders and dumpers
for Ecto schemas.

## convert/1

Takes a value and convers it to data suitable for storage in the database.

Returns a tagged :ok/:error tuple. If the value is not convertable by this
extension, returns nil.