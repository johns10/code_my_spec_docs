# Mix.Tasks.Oban.Install

Install and configure Oban for use in an application.

## Example

Install using the default Ecto repo and matching engine:

```bash
mix oban.install
```

Specify a `SQLite3` repo and `Lite` engine explicitly:

```bash
mix oban.install --repo MyApp.LiteRepo --engine Oban.Engines.Lite
```

## Options

* `--engine` or `-e` — Select the engine for your repo, defaults to `Oban.Engines.Postgres`
* `--notifier` or `-n` — Select the pubsub notifier, defaults to `Oban.Notifiers.Postgres`
* `--repo` or `-r` — Specify an Ecto repo for Oban to use