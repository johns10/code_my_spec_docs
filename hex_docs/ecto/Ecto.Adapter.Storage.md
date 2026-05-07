# Ecto.Adapter.Storage

Specifies the adapter storage API.

## storage_down/1

Drops the storage given by options.

Returns `:ok` if it was dropped successfully.

Returns `{:error, :already_down}` if the storage has already been dropped or
`{:error, term}` in case anything else goes wrong.

## Examples

    storage_down(username: "postgres",
                 database: "ecto_test",
                 hostname: "localhost")

## storage_status/1

Returns the status of a storage given by options.

Can return `:up`, `:down` or `{:error, term}` in case anything goes wrong.

## Examples

    storage_status(username: "postgres",
                   database: "ecto_test",
                   hostname: "localhost")

## storage_up/1

Creates the storage given by options.

Returns `:ok` if it was created successfully.

Returns `{:error, :already_up}` if the storage has already been created or
`{:error, term}` in case anything else goes wrong.

## Examples

    storage_up(username: "postgres",
               database: "ecto_test",
               hostname: "localhost")