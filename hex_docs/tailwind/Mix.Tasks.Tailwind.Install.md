# Mix.Tasks.Tailwind.Install

Installs Tailwind executable and assets.

    $ mix tailwind.install
    $ mix tailwind.install --if-missing

By default, it installs 4.1.12 but you
can configure it in your config files, such as:

    config :tailwind, :version, "4.1.12"

To install the Tailwind binary from a custom URL (e.g. if your platform isn't
officially supported by Tailwind), you can supply a third party path to the
binary (beware that we cannot guarantee the compatibility of any third party
executable):

```bash
$ mix tailwind.install https://people.freebsd.org/~dch/pub/tailwind/v3.2.6/tailwindcss-freebsd-x64
```

## Options

  * `--runtime-config` - load the runtime configuration
    before executing command

  * `--if-missing` - install only if the given version
    does not exist