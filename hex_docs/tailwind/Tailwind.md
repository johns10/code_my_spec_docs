# Tailwind



## configured_version/0

Returns the configured tailwind version.

## configured_target/0

Returns the configured tailwind target. By default, it is automatically detected.

## config_for!/1

Returns the configuration for the given profile.

Returns nil if the profile does not exist.

## bin_path/0

Returns the path to the executable.

The executable may not be available if it was not yet installed.

## bin_version/0

Returns the version of the tailwind executable.

Returns `{:ok, version_string}` on success or `:error` when the executable
is not available.

## run/2

Runs the given command with `args`.

The given args will be appended to the configured args.
The task output will be streamed directly to stdio. It
returns the status of the underlying call.

## install_and_run/2

Installs, if not available, and then runs `tailwind`.

Returns the same as `run/2`.

## default_base_url/0

The default URL to install Tailwind from.

## install/1

Installs tailwind with `configured_version/0`.