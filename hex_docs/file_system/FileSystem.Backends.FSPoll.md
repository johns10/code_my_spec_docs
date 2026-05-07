# FileSystem.Backends.FSPoll

File system backend for any OS.

## Backend Options

  * `:interval` (integer, default: 1000), polling interval

## Using FSPoll Backend

Unlike other backends, polling backend is never automatically chosen in any
OS environment, despite being usable on all platforms.

To use polling backend, one has to explicitly specify in the backend option.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.