# Phoenix.Config



## cache(module, key, fun)

Caches a value in Phoenix configuration handler for the module.

The given function needs to return a tuple with `:cache` if the
value should be cached or `:nocache` if the value should not be
cached because it can be consequently considered stale.

Notice writes are not serialized to the server, we expect the
function that generates the cache to be idempotent.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## clear_cache(module)

Clears all cached entries in the endpoint.

## config_change(module, changed, removed)

Changes the configuration for the given module.

It receives a keyword list with changed config and another
with removed ones. The changed config are updated while the
removed ones stop the configuration server, effectively removing
the table.

## from_env(otp_app, module, defaults)

Reads the configuration for module from the given OTP app.

Useful to read a particular value at compilation time.

## merge(a, b)

Take 2 keyword lists and merge them recursively.

Used to merge configuration values into defaults.

## permanent(module, key, value)

Adds permanent configuration.

Permanent configuration is not deleted on hot code reload.

## put(module, key, value)

Puts a given key-value pair in config.

## start_link(arg)

Starts a Phoenix configuration handler.