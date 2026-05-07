# Postgrex.TypeServer



## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## done(server, ref)

Unlocks the given reference for a given module if no update.

## fetch(server)

Fetches a lock for the given type server.

We attempt to achieve a lock on the type server for updating the entries.
If another process got the lock we wait for it to finish.

## start_link(arg)

Starts a type server.

## update(server, ref, type_infos)

Update the type server using the given reference and configuration.