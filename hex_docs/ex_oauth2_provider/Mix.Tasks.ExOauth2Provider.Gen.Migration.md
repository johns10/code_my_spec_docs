# Mix.Tasks.ExOauth2Provider.Gen.Migration

Generates migration file.

    mix ex_oauth2_provider.gen.migrations -r MyApp.Repo

    mix ex_oauth2_provider.gen.migrations -r MyApp.Repo --namespace oauth2

This generator will add the oauth2 migration file in `priv/repo/migrations`.

The repository must be set under `:ecto_repos` in the current app
configuration or given via the `-r` option.

By default, the migration will be generated to the
"priv/YOUR_REPO/migrations" directory of the current application but it
can be configured to be any subdirectory of `priv` by specifying the
`:priv` key under the repository configuration.

## Arguments

  * `-r`, `--repo` - the repo module
  * `--binary-id` - use binary id for primary keys
  * `--namespace` - namespace to prepend table and schema module name