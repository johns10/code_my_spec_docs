# Phoenix.Endpoint.Supervisor



## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## config_change(endpoint, changed, removed)

Callback that changes the configuration from the app callback.

## server?(otp_app, endpoint)

Checks if Endpoint's web server has been configured to start.

## start_link(otp_app, mod, opts \\ [])

Starts the endpoint supervision tree.

## static_lookup(endpoint, path)

Returns a two item tuple with the first element containing the
static path of a file in the static root directory
and the second element containing the sha512 of that file (for SRI).

When the file exists, it includes a timestamp. When it doesn't exist,
just the static path is returned.

The result is wrapped in a `{:cache | :nocache, value}` tuple so
the `Phoenix.Config` layer knows how to cache it.

## warmup(endpoint)

Invoked to warm up caches on start and config change.