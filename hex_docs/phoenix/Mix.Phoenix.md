# Mix.Phoenix



## base()

Returns the module base name based on the configuration value.

    config :my_app
      namespace: My.App

## check_module_name_availability!(name)

Checks the availability of a given module name.

## context_app()

Returns the OTP context app.

## context_app_path(ctx_app, rel_path)

Returns the context app path prefix to be used in generated context files.

## context_base(ctx_app)

Returns the context module base name based on the configuration value.

    config :my_app
      namespace: My.App

## context_lib_path(ctx_app, rel_path)

Returns the context lib path to be used in generated context files.

## context_test_path(ctx_app, rel_path)

Returns the context test path to be used in generated context files.

## copy_from(apps, source_dir, binding, mapping)

Copies files from source dir to target dir
according to the given map.

Files are evaluated against EEx according to
the given binding.

## ensure_live_view_compat!(generator_mod)

Ensures user's LiveView is compatible with the current generators.

## eval_from(apps, source_file_path, binding)

Evals EEx files from source dir.

Files are evaluated against EEx according to
the given binding.

## generator_paths()

The paths to look for template files for generators.

Defaults to checking the current app's `priv` directory,
and falls back to Phoenix's `priv` directory.

## in_umbrella?(app_path)

Checks if the given `app_path` is inside an umbrella.

## inflect(singular)

Inflects path, scope, alias and more from the given name.

## Examples

    iex> Mix.Phoenix.inflect("user")
    [alias: "User",
     human: "User",
     base: "Phoenix",
     web_module: "PhoenixWeb",
     module: "Phoenix.User",
     scoped: "User",
     singular: "user",
     path: "user"]

    iex> Mix.Phoenix.inflect("Admin.User")
    [alias: "User",
     human: "User",
     base: "Phoenix",
     web_module: "PhoenixWeb",
     module: "Phoenix.Admin.User",
     scoped: "Admin.User",
     singular: "user",
     path: "admin/user"]

    iex> Mix.Phoenix.inflect("Admin.SuperUser")
    [alias: "SuperUser",
     human: "Super user",
     base: "Phoenix",
     web_module: "PhoenixWeb",
     module: "Phoenix.Admin.SuperUser",
     scoped: "Admin.SuperUser",
     singular: "super_user",
     path: "admin/super_user"]

## modules()

Returns all compiled modules in a project.

## otp_app()

Returns the OTP app from the Mix project configuration.

## prompt_for_conflicts(generator_files)

Prompts to continue if any files exist.

## web_module(base)

Returns the web module prefix.

## web_path(ctx_app, rel_path \\ "")

Returns the web prefix to be used in generated file specs.

## web_test_path(ctx_app, rel_path \\ "")

Returns the test prefix to be used in generated file specs.