# Phoenix

This is the documentation for the Phoenix project.

To get started, see our [overview guides](overview.html).

## json_library()

Returns the configured JSON encoding library for Phoenix.

To customize the JSON library, including the following
in your `config/config.exs`:

    config :phoenix, :json_library, AlternativeJsonLibrary

## plug_init_mode()

Returns the `:plug_init_mode` that controls when plugs are
initialized.

We recommend to set it to `:runtime` in development for
compilation time improvements. It must be `:compile` in
production (the default).

This option is passed as the `:init_mode` to `Plug.Builder.compile/3`.