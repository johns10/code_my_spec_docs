# Tailwind

Tailwind is an installer and runner for [tailwind](https://tailwindcss.com/).

## Profiles

You can define multiple tailwind profiles. By default, there is a
profile called `:default` which you can configure its args, current
directory and environment:

    config :tailwind,
      version: "4.1.12",
      default: [
        args: ~w(
          --input=assets/css/app.css
          --output=priv/static/assets/app.css
        ),
        cd: Path.expand("..", __DIR__),
      ]

## Tailwind configuration

There are four global configurations for the tailwind application:

  * `:version` - the expected tailwind version

  * `:version_check` - whether to perform the version check or not.
    Useful when you manage the tailwind executable with an external
    tool (eg. npm)

  * `:path` - the path to find the tailwind executable at. By
    default, it is automatically downloaded and placed inside
    the `_build` directory of your current app

  * `:target` - the target architecture for the tailwind executable.
    For example `"linux-x64-musl"`. By default, it is automatically detected
    based on system information.

Overriding the `:path` is not recommended, as we will automatically
download and manage `tailwind` for you. But in case you can't download
it (for example, GitHub behind a proxy), you may want to
set the `:path` to a configurable system location.

For instance, you can install `tailwind` and its CLI tool with `npm`.

From `/assets`:

    $ npm install tailwindcss @tailwindcss/cli

Then adjust your configuration:

    config :tailwind,
      # check if in sync with /assets/package.json
      version: "4.1.12",
      default: [
        args: ~w(
          --input=assets/css/app.css
          --output=priv/static/assets/app.css
        ),
        cd: Path.expand("..", __DIR__),
      ],
      # skip executable check/download
      version_check: false,
      # path to npm managed CLI tool
      path: Path.expand("../assets/node_modules/.bin/tailwindcss", __DIR__)

## bin_path()

Returns the path to the executable.

The executable may not be available if it was not yet installed.

## bin_version()

Returns the version of the tailwind executable.

Returns `{:ok, version_string}` on success or `:error` when the executable
is not available.

## config_for!(profile)

Returns the configuration for the given profile.

Returns nil if the profile does not exist.

## configured_target()

Returns the configured tailwind target. By default, it is automatically detected.

## configured_version()

Returns the configured tailwind version.

## default_base_url()

The default URL to install Tailwind from.

## install(base_url \\ default_base_url())

Installs tailwind with `configured_version/0`.

## install_and_run(profile, args)

Installs, if not available, and then runs `tailwind`.

Returns the same as `run/2`.

## run(profile, extra_args)

Runs the given command with `args`.

The given args will be appended to the configured args.
The task output will be streamed directly to stdio. It
returns the status of the underlying call.