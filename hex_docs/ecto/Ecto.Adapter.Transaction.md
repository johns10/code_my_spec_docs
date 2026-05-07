# Ecto.Adapter.Transaction

Specifies the adapter transactions API.

## in_transaction?/1

Returns true if the given process is inside a transaction.

## rollback/2

Rolls back the current transaction.

The transaction will return the value given as `{:error, value}`.

See `c:Ecto.Repo.rollback/1`.

## transaction/3

Runs the given function inside a transaction.

Returns `{:ok, value}` if the transaction was successful where `value`
is the value returned by the function or `{:error, value}` if the transaction
was rolled back where `value` is the value given to `rollback/1`.