# Oban.Repo

Wrappers around `Ecto.Repo` and `Ecto.Adapters.SQL` callbacks.

Each function resolves the correct repo instance and sets options such as `prefix` and `log`
according to `Oban.Config`.

> #### Meant for Extending Oban {: .warning}
>
> These functions should only be used when working with a repo inside engines, plugins, or other
> extensions for Oban. Favor using your application's repo directly when querying `Oban.Job`
> from your workers.

## Examples

The first argument for every function must be an `Oban.Config` struct. Many functions pass
configuration around as a `conf` key, and it can always be fetched with `Oban.config/1`. This
demonstrates fetching the default instance config and querying all jobs:

    Oban
    |> Oban.config()
    |> Oban.Repo.all(Oban.Job)

## aggregate(conf, arg1, arg2, opts \\ [])

Wraps `c:Ecto.Repo.aggregate/3` with an additional `Oban.Config` argument.

## all(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.all/2` with an additional `Oban.Config` argument.

## checkout(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.checkout/2` with an additional `Oban.Config` argument.

## config(conf)

Wraps `c:Ecto.Repo.config/0` with an additional `Oban.Config` argument.

## default_options(conf)

The default values extracted from `Oban.Config` for use in all queries with options.

## default_options(conf, arg1)

Wraps `c:Ecto.Repo.default_options/1` with an additional `Oban.Config` argument.

## delete(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.delete/2` with an additional `Oban.Config` argument.

## delete!(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.delete!/2` with an additional `Oban.Config` argument.

## delete_all(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.delete_all/2` with an additional `Oban.Config` argument.

## exists?(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.exists?/2` with an additional `Oban.Config` argument.

## get(conf, arg1, arg2, opts \\ [])

Wraps `c:Ecto.Repo.get/3` with an additional `Oban.Config` argument.

## get!(conf, arg1, arg2, opts \\ [])

Wraps `c:Ecto.Repo.get!/3` with an additional `Oban.Config` argument.

## get_by(conf, arg1, arg2, opts \\ [])

Wraps `c:Ecto.Repo.get_by/3` with an additional `Oban.Config` argument.

## get_by!(conf, arg1, arg2, opts \\ [])

Wraps `c:Ecto.Repo.get_by!/3` with an additional `Oban.Config` argument.

## get_dynamic_repo(conf)

Wraps `c:Ecto.Repo.get_dynamic_repo/0` with an additional `Oban.Config` argument.

## in_transaction?(conf)

Wraps `c:Ecto.Repo.in_transaction?/0` with an additional `Oban.Config` argument.

## insert(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.insert/2` with an additional `Oban.Config` argument.

## insert!(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.insert!/2` with an additional `Oban.Config` argument.

## insert_all(conf, arg1, arg2, opts \\ [])

Wraps `c:Ecto.Repo.insert_all/3` with an additional `Oban.Config` argument.

## insert_or_update(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.insert_or_update/2` with an additional `Oban.Config` argument.

## insert_or_update!(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.insert_or_update!/2` with an additional `Oban.Config` argument.

## load(conf, arg1, arg2)

Wraps `c:Ecto.Repo.load/2` with an additional `Oban.Config` argument.

## one(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.one/2` with an additional `Oban.Config` argument.

## one!(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.one!/2` with an additional `Oban.Config` argument.

## preload(conf, arg1, arg2, opts \\ [])

Wraps `c:Ecto.Repo.preload/3` with an additional `Oban.Config` argument.

## put_dynamic_repo(conf, arg1)

Wraps `c:Ecto.Repo.put_dynamic_repo/1` with an additional `Oban.Config` argument.

## query(conf, statement, params \\ [], opts \\ [])

Wraps `Ecto.Adapters.SQL.Repo.query/4` with an added `Oban.Config` argument.

## query!(conf, statement, params \\ [], opts \\ [])

Wraps `Ecto.Adapters.SQL.Repo.query!/4` with an added `Oban.Config` argument.

## reload(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.reload/2` with an additional `Oban.Config` argument.

## reload!(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.reload!/2` with an additional `Oban.Config` argument.

## rollback(conf, arg1)

Wraps `c:Ecto.Repo.rollback/1` with an additional `Oban.Config` argument.

## stream(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.stream/2` with an additional `Oban.Config` argument.

## to_sql(conf, kind, queryable)

Wraps `Ecto.Adapters.SQL.Repo.to_sql/2` with an added `Oban.Config` argument.

## transaction(conf, fun_or_multi, opts \\ [])

Wraps `c:Ecto.Repo.transaction/2` with an additional `Oban.Config` argument and automatic
retries with backoff.

## Options

Backoff helpers, in addition to the standard transaction options:

* `delay` — the time to sleep between retries, defaults to `500ms`
* `retry` — the number of retries for unexpected errors, defaults to `5`
* `expected_delay` — the time to sleep between expected errors, e.g. `serialization` or
  `lock_not_available`, defaults to `10ms`
* `expected_retry` — the number of retries for expected errors, defaults to `20`

## update(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.update/2` with an additional `Oban.Config` argument.

## update!(conf, arg1, opts \\ [])

Wraps `c:Ecto.Repo.update!/2` with an additional `Oban.Config` argument.

## update_all(conf, arg1, arg2, opts \\ [])

Wraps `c:Ecto.Repo.update_all/3` with an additional `Oban.Config` argument.