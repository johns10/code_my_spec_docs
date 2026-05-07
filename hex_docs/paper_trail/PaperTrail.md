# PaperTrail



## delete(model_or_changeset, options \\ [origin: nil, meta: nil, originator: nil, prefix: nil, model_key: :model, version_key: :version, ecto_options: []])

Deletes a record from the database with a related version insertion in one transaction

## delete!(model_or_changeset, options \\ [origin: nil, meta: nil, originator: nil, prefix: nil, model_key: :model, version_key: :version, ecto_options: []])

Same as delete/2 but returns only the model struct or raises if the changeset is invalid.

## initialise(model, options \\ [origin: nil, meta: nil, originator: nil, prefix: nil, version_key: :version])

Explicitly inserts a non-versioned already existing record into the Versions table

## insert(changeset, options \\ [origin: nil, meta: nil, originator: nil, prefix: nil, model_key: :model, version_key: :version, ecto_options: []])

Inserts a record to the database with a related version insertion in one transaction

## insert!(changeset, options \\ [origin: nil, meta: nil, originator: nil, prefix: nil, model_key: :model, version_key: :version, ecto_options: []])

Same as insert/2 but returns only the model struct or raises if the changeset is invalid.

## insert_or_update(changeset, options \\ [origin: nil, meta: nil, originator: nil, prefix: nil, model_key: :model, version_key: :version, ecto_options: []])

Upserts a record to the database with a related version insertion in one transaction.

## insert_or_update!(changeset, options \\ [origin: nil, meta: nil, originator: nil, prefix: nil, model_key: :model, version_key: :version, ecto_options: []])

Same as insert_or_update/2 but returns only the model struct or raises if the changeset is invalid.

## update(changeset, options \\ [origin: nil, meta: nil, originator: nil, prefix: nil, model_key: :model, version_key: :version, ecto_options: []])

Updates a record from the database with a related version insertion in one transaction

## update!(changeset, options \\ [origin: nil, meta: nil, originator: nil, prefix: nil, model_key: :model, version_key: :version, ecto_options: []])

Same as update/2 but returns only the model struct or raises if the changeset is invalid.