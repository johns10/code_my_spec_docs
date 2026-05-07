# Ecto.Migration.Runner



## child_spec(arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## end_command()

Queues and clears current command. Must call `start_command/1` first.

## execute(command)

Queues command tuples or strings for execution.

Ecto.MigrationError will be raised when the server
is in `:backward` direction and `command` is irreversible.

## flush()

Executes queue migration commands.

Reverses the order commands are executed when doing a rollback
on a change/0 function and resets commands queue.

## metadata(runner, opts)

Stores the runner metadata.

## migrator_direction()

Returns the migrator command (up or down).

  * forward + up: up
  * forward + down: down
  * forward + change: up
  * backward + change: down

## prefix()

Gets the prefix for this migration

## repo()

Gets the repo for this migration

## repo_config(key, default)

Accesses the given repository configuration.

## run(repo, config, version, module, direction, operation, migrator_direction, opts)

Runs the given migration.

## start_command(command)

Starts a command.

## start_link(arg)

Starts the runner for the specified repo.

## stop()

Stops the runner.

## subcommand(subcommand)

Adds a subcommand to the current command. Must call `start_command/1` first.