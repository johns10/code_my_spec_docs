# Mix.Tasks.Esbuild.Install

Installs esbuild under `_build`.

```bash
$ mix esbuild.install
$ mix esbuild.install --if-missing
```

By default, it installs 0.25.0 but you
can configure it in your config files, such as:

    config :esbuild, :version, "0.25.0"

## Options

    * `--runtime-config` - load the runtime configuration
      before executing command

    * `--if-missing` - install only if the given version
      does not exist