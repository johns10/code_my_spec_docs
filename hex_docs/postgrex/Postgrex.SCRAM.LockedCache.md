# Postgrex.SCRAM.LockedCache



## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## get(key)

Reads the cache key.

## run(key, fun)

Reads cache key or executes the given function if not
cached yet.