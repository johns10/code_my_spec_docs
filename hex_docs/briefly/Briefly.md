# Briefly

Simple, robust temporary file support for Elixir.

## Highlighted Features

* Create temporary files with prefix and extname options.
* Files are removed after the requesting process exits.
* File creation is based on [Plug.Upload](http://hexdocs.pm/plug/Plug.Upload.html)'s robust retry logic.
* Configurable; built-in support for system environment variables and fallbacks.

## Usage

The fastest way to use Briefly is with [`Mix.install/2`](https://hexdocs.pm/mix/Mix.html#install/2) (requires Elixir v1.12+):

```elixir
Mix.install([
  {:briefly, "~> 0.5.0"}
])

{:ok, path} = Briefly.create()
File.write!(path, "My temp file contents")
File.read!(path)
# => "My temp file contents"

# When this process exits, the file at `path` is removed
```

If you want to use Briefly in a Mix project, you can add the above dependency to your list of dependencies in `mix.exs`.

To use Briefly outside of the context of an application's dependency tree (e.g. in an .exs file), first run `Briefly.start`.

Briefly can also create a temporary directory:


```elixir
{:ok, dir} = Briefly.create(type: :directory)
File.write!(Path.join(dir, "test.txt"), "Some Text")
# When this process exits, the directory and file are removed
```

Refer to [the documentation](http://hexdocs.pm/briefly/Briefly.html#create/1) for a list of options that are available to `Briefly.create/1` and `Briefly.create!/1`.

## Configuration

The default, out-of-the-box settings for Briefly are equivalent to the
following Mix config:

```elixir
# config/config.exs
config :briefly,
  directory: [{:system, "TMPDIR"}, {:system, "TMP"}, {:system, "TEMP"}, "/tmp"],
  directory_mode: 0o755,
  default_prefix: "briefly",
  default_extname: ""
```

`directory` here declares an ordered list of possible directory definitions that Briefly will check in order.

The `{:system, env_var}` tuples point to system environment variables to be checked. If none of these are defined, Briefly will use the final entry: `/tmp`.

You can override the settings with your own candidates in your application Mix
config (and pass `prefix` and `extname` to `Briefly.create` to override
`default_prefix` and `default_extname` on a case-by-case basis).

## cleanup(pid \\ self())

Removes the temporary files and directories created by the process and returns their paths.

## create(opts \\ [])

Requests a temporary file to be created with the given options.

## create!(opts \\ [])

Requests a temporary file to be created with the given options
and raises on failure.

## give_away(path, to_pid, from_pid \\ self())

Assign ownership of the given tmp file to another process.