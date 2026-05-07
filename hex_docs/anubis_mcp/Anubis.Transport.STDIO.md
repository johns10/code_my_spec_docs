# Anubis.Transport.STDIO

A transport implementation that uses standard input/output.

> ## Notes {: .info}
>
> For initialization and setup, check our [Installation & Setup](./installation.html) and
> the [Transport options](./transport_options.html) guides for reference.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## option/0

The options for the STDIO transport.

- `:command` - The command to run, it will be searched in the system's PATH.
- `:args` - The arguments to pass to the command, as a list of strings.
- `:env` - The extra environment variables to set for the command, as a map.
- `:cwd` - The working directory for the command.
- `:client` - The client to send the messages to, respecting the `GenServer` "Name Registration" section

And any other `GenServer` init option.