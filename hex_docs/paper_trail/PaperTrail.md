# PaperTrail



## initialise/2

Explicitly inserts a non-versioned already existing record into the Versions table

## insert/2

Inserts a record to the database with a related version insertion in one transaction

## insert!/2

Same as insert/2 but returns only the model struct or raises if the changeset is invalid.

## insert_or_update/2

Upserts a record to the database with a related version insertion in one transaction.

## insert_or_update!/2

Same as insert_or_update/2 but returns only the model struct or raises if the changeset is invalid.

## update/2

Updates a record from the database with a related version insertion in one transaction

## update!/2

Same as update/2 but returns only the model struct or raises if the changeset is invalid.

## delete/2

Deletes a record from the database with a related version insertion in one transaction

## delete!/2

Same as delete/2 but returns only the model struct or raises if the changeset is invalid.