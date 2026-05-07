# Postgrex.TypeSupervisor



## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## locate(module, key)

Locates a type server for the given module-key pair.

## start_link(_)

Starts a type supervisor with a manager and a simple
one for one supervisor for each server.