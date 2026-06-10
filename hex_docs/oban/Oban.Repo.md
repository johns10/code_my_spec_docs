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

## default_options/1

The default values extracted from `Oban.Config` for use in all queries with options.

## query/4

Wraps `Ecto.Adapters.SQL.Repo.query/4` with an added `Oban.Config` argument.

## query!/4

Wraps `Ecto.Adapters.SQL.Repo.query!/4` with an added `Oban.Config` argument.

## to_sql/3

Wraps `Ecto.Adapters.SQL.Repo.to_sql/2` with an added `Oban.Config` argument.

## transaction/3

Wraps `c:Ecto.Repo.transaction/2` with an additional `Oban.Config` argument and automatic
retries with backoff.

## Options

Backoff helpers, in addition to the standard transaction options:

* `delay` — the time to sleep between retries, defaults to `500ms`
* `retry` — the number of retries for unexpected errors, defaults to `5`
* `expected_delay` — the time to sleep between expected errors, e.g. `serialization` or
  `lock_not_available`, defaults to `10ms`
* `expected_retry` — the number of retries for expected errors, defaults to `20`