# GitHub.Auth.Cache

Optional caching process for GitHub App and Installation tokens

This cache uses a local ETS table to store tokens, so they are not shared across a cluster.
However, this is generally okay, as multiple tokens can be used for the same GitHub App or
Installation at the same time.

Assuming the expiration time given to this cache is correct, it will automatically handle
invalidating tokens both periodically and on-demand.

## Usage

To enable caching, include this module in your application's top-level supervisor:

    # application.ex
    defmodule MyApp.Application do
      use Application

      def start(_type, _args) do
        children = [
          # ...
          GitHub.Auth.Cache
        ]

        opts = [strategy: :one_for_one, name: MyApp.Supervisor]
        Supervisor.start_link(children, opts)
      end
    end

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## get(key)

Get a previously stored value if unexpired

Here the key is presumed to be `{:app, app_id}` or `{:installation, installation_id}`, though
any key will work. Returns `:error` if the key is not found or if the stored value has expired.

## put(key, expiration, value)

Set a value in the cache

Here the key is presumed to be `{:app, app_id}` or `{:installation, installation_id}`, though
any key will work. The expiration must be a Unix timestamp (seconds since Jan 1, 1970).