# Ecto.Adapter.Migration

Specifies the adapter migrations API.

## execute_ddl/3

Executes migration commands.

## lock_for_migrations/3

Locks the migrations table and emits the locked versions for callback execution.

It returns the result of calling the given function with a list of versions.

## supports_ddl_transaction?/0

Checks if the adapter supports ddl transaction.

## command/0

All migration commands

## table_subcommand/0

All commands allowed within the block passed to `table/2`

## ddl_object/0

A struct that represents a table or index in a database schema.

These database objects can be modified through the use of a Data
Definition Language, hence the name DDL object.