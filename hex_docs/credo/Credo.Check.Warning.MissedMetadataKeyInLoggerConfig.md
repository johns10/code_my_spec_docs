# Credo.Check.Warning.MissedMetadataKeyInLoggerConfig

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Ensures custom metadata keys are included in logger config.

Note that all metadata is optional and may not always be available.

For example, you might wish to include a custom `:error_code` metadata in your logs:

    Logger.error("We have a problem", [error_code: :pc_load_letter])

In your app's logger configuration, you would need to include the `:error_code` key:

    config :logger, :default_formatter,
      format: "[$level] $message $metadata\n",
      metadata: [:error_code, :file]

That way your logs might then receive lines like this:

    [error] We have a problem error_code=pc_load_letter file=lib/app.ex

If you want to allow any metadata to be printed, you can use `:all` in the logger's
metadata config.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:metadata_keys`

  Do not raise an issue for these Logger metadata keys.
  
  By default, we read the metadata keys configured as the current environment's
  `:default_formatter` (or `:console` for older versions of Elixir).
  
  You can use this parameter to dynamically load the environment/backend you care about,
  via `.credo.exs` (e.g. reading the `:file_log` config from `config/prod.exs`):
  
      {Credo.Check.Warning.MissedMetadataKeyInLoggerConfig,
        [
          metadata_keys:
            "config/prod.exs"
            |> Config.Reader.read!()
            |> get_in([:logger, :file_log, :metadata])
        ]}
  

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).