# PaperTrail.VersionQueries



## get_current_model(version)

Gets the current model record/struct of a version

## get_version(record)

Gets the last version of a record.

A list of options is optional, so you can set for example the :prefix of the query,
wich allows you to change between different tenants.

# Usage examples:

  iex(1)> PaperTrail.VersionQueries.get_version(record, id)
  iex(1)> PaperTrail.VersionQueries.get_version(record, [prefix: "tenant_id"])
  iex(1)> PaperTrail.VersionQueries.get_version(ModelName, id)
  iex(1)> PaperTrail.VersionQueries.get_version(ModelName, id, [prefix: "tenant_id"])

## get_versions(record)

Gets all the versions of a record.

A list of options is optional, so you can set for example the :prefix of the query,
wich allows you to change between different tenants.

# Usage examples:

  iex(1)> PaperTrail.VersionQueries.get_versions(record)
  iex(1)> PaperTrail.VersionQueries.get_versions(record, [prefix: "tenant_id"])
  iex(1)> PaperTrail.VersionQueries.get_versions(ModelName, id)
  iex(1)> PaperTrail.VersionQueries.get_versions(ModelName, id, [prefix: "tenant_id"])

## get_versions(model, id)

Gets all the versions of a record given a module and its id