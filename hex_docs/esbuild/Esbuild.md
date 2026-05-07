# Esbuild

Esbuild is an installer and runner for [esbuild](https://esbuild.github.io).

## Profiles

You can define multiple esbuild profiles. By default, there is a
profile called `:default` which you can configure its args, current
directory and environment:

    config :esbuild,
      version: "0.25.0",
      default: [
        args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
        cd: Path.expand("../assets", __DIR__),
        env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
      ]

## Esbuild configuration

There are four global configurations for the esbuild application:

  * `:version` - the expected esbuild version

  * `:version_check` - whether to perform the version check or not.
    Useful when you manage the esbuild executable with an external
    tool (eg. npm)

  * `:path` - the path to find the esbuild executable at. By
    default, it is automatically downloaded and placed inside
    the `_build` directory of your current app

Overriding the `:path` is not recommended, as we will automatically
download and manage `esbuild` for you. But in case you can't download
it (for example, the npm registry is behind a proxy), you may want to
set the `:path` to a configurable system location.

For instance, you can install `esbuild` globally with `npm`:

    $ npm install -g esbuild

On Unix, the executable will be at:

    NPM_ROOT/esbuild/node_modules/@esbuild/TARGET/bin/esbuild

On Windows, it will be at:

    NPM_ROOT/esbuild/node_modules/@esbuild/win32-x(32|64)/esbuild.exe

Where `NPM_ROOT` is the result of `npm root -g` and `TARGET` is your system
target architecture.

Once you find the location of the executable, you can store it in a
`MIX_ESBUILD_PATH` environment variable, which you can then read in
your configuration file:

    config :esbuild, path: System.get_env("MIX_ESBUILD_PATH")

## bin_path()

Returns the path to the executable.

The executable may not be available if it was not yet installed.

## bin_version()

Returns the version of the esbuild executable.

Returns `{:ok, version_string}` on success or `:error` when the executable
is not available.

## config_for!(profile)

Returns the configuration for the given profile.

Returns nil if the profile does not exist.

## configured_version()

Returns the configured esbuild version.

## install()

Installs esbuild with `configured_version/0`.

If invoked concurrently, this task will perform concurrent installs.

## install_and_run(profile, args)

Installs, if not available, and then runs `esbuild`.

This task may be invoked concurrently and it will avoid concurrent installs.

Returns the same as `run/2`.

## run(profile, extra_args)

Runs the given command with `args`.

The given args will be appended to the configured args.
The task output will be streamed directly to stdio. It
returns the status of the underlying call.