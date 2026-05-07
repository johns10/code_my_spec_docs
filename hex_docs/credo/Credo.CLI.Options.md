# Credo.CLI.Options

The `Options` struct represents the options given on the command line.

The `Options` struct is stored as part of the `Execution` struct.

## parse(use_strict_parser?, argv, current_dir, command_names, given_command_name, ignored_args, switches_definition, aliases, treat_unknown_args_as_files? \\ false)

Returns a `Options` struct for the given parameters.