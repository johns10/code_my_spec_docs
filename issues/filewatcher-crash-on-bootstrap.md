# FileWatcher crashes on fresh bootstrap (no user in DB)

## Status: Open

On a fresh project run before any user has been seeded, the ContentSync FileWatcher
crash-loops because it tries to load a user from the database during GenServer init.

## Problem

`FileWatcher.Server.init/1` calls `Impl.build_config/1` → `load_scope_from_config/0`
which does `Repo.get(User, user_id)`. When user_id 1 doesn't exist yet, it returns
`{:error, :user_not_found}` → `{:stop, reason}` → supervisor restarts → crash loop.

**Config that triggers it** (`config/dev.exs:99-106`):
```elixir
config :code_my_spec,
  watch_content: true,
  content_watch_scope: %{
    user_id: 1,
    account_id: "0f27281c-240b-4d6d-8e52-9c5972329522",
    project_id: "708492f9-454e-482f-a2eb-be64f0356b87"
  }
```

**Crash path:**
1. `application.ex:42-48` — adds FileWatcher to supervision tree in dev
2. `server.ex:20-47` — `init/1` calls `Impl.build_config(opts)`
3. `impl.ex:86-138` — `load_scope_from_config/0` queries DB for user, account, project
4. `server.ex:44-45` — `{:error, reason} -> {:stop, reason}` kills the GenServer

## Fix

Return `:ignore` from `init/1` when the scope can't be loaded. This tells the
supervisor the GenServer chose not to start — no crash, no restart loop. Log a
warning so the developer knows what happened.

```elixir
# server.ex init/1
{:error, reason} ->
  Logger.warning("FileWatcher not starting: #{inspect(reason)}")
  :ignore
```

## Files

- `lib/code_my_spec/content_sync/file_watcher/server.ex` — GenServer init
- `lib/code_my_spec/content_sync/file_watcher/impl.ex` — scope loading / user lookup
- `config/dev.exs` — hardcoded scope IDs
