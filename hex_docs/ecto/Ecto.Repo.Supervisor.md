# Ecto.Repo.Supervisor



## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## compile_config(repo, opts)

Retrieves the compile time configuration.

## init_config(type, repo, otp_app, opts)

Retrieves the runtime configuration.

## parse_url(url)

Parses an Ecto URL allowed in configuration.

The format must be:

    "ecto://username:password@hostname:port/database?ssl=true&timeout=1000"

## start_link(repo, otp_app, adapter, opts)

Starts the repo supervisor.