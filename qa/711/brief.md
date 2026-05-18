# Qa Story Brief

## Tool

`mix spex` for all 17 criteria (spex BDD test runner). Supplementary browser testing via `mcp__vibium__browser_*` for the local UI at port 4004.

## Auth

No auth required for the local app at port 4004 (loopback-only, `LocalOnly` plug).

For spex tests: none — they boot ExUnit with a test database.

For browser testing (if needed for install tool verification): navigate directly to `http://127.0.0.1:4004/`.

## Seeds

Run the CLI QA seed to ensure a project row with `local_path` set to the sandbox:

```
MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs
```

Note: This may fail due to a pending unrelated migration (`stories_account_id_index`). If it fails, the spex tests are self-contained with their own `setup_active_project` fixture and do not need the CLI seed. The seed is only needed for browser-surface smoke tests.

For spex execution, no manual seed setup is required — each spex test uses `register_log_in_setup_account` + `setup_active_project` setup callbacks which create a fresh isolated environment.

## What To Test

### Scenario 1: Spex test suite for all 17 criteria

Run the full spex suite for story 711:

```
mix spex test/spex/711_agent_bootstraps_a_project/
```

Expected: 17 tests, 0 failures.

Each criterion maps to an acceptance criterion:

- **6239** — `install_claude_md` on a fresh directory creates CLAUDE.md with start/end markers
- **6240** — Re-running `install_claude_md` when CLAUDE.md already has user content preserves user content above/below markers and replaces the managed section
- **6241** — `install_agents_md` writes `.code_my_spec/AGENTS.md` when `mix.exs` is present and references the app name
- **6242** — `install_agents_md` returns an error naming `mix.exs` and instructs running from project root when `mix.exs` is absent
- **6243** — `install_rules` on a fresh directory copies every `.md` from `priv/rules/` into `.code_my_spec/rules/`
- **6244** — Re-running `install_rules` skips user-modified rule files while installing absent ones
- **6245** — `sync_project` with a populated `lib/` returns `Files: N` (non-zero) and `Components: N`
- **6246** — `sync_project` with no OAuth credentials returns `Remote sync: skipped (not authenticated)` but still includes `Files:` and `Components:` lines
- **6247** — `Init.command` with 5/6 sub-steps done renders `5/6` progress, full checklist, only Auth prompt inlined, Auth marked `<- next`
- **6248** — `Init.Elixir.evaluate` returns `{:ok, :valid}` when Elixir >= 1.18 (via cassette `init_elixir_pass.json`)
- **6249** — `Init.PhoenixInstaller.evaluate` returns `{:ok, :invalid, detail}` with `mix archive.install hex phx_new` when phx_new is absent (via cassette `init_phx_installer_missing.json`)
- **6250** — `Init.PhoenixProject.evaluate` returns `{:ok, :valid}` when `mix.exs`, `lib/`, and `config/` are all present
- **6251** — `Init.PhoenixProject.command` when `mix.exs` is absent returns a prompt mentioning "relaunch" and "project root" and names the cwd
- **6252** — `Init.Auth.evaluate` returns `{:ok, :valid}` when a `ClientUser` row with an OAuth token exists
- **6253** — `Init.Auth.command` returns a prompt mentioning "sign in", "CodeMySpec", and "cannot complete it automatically" when no ClientUser exists
- **6254** — `Init.CliConfig.evaluate` returns `{:ok, :valid}` when a Project row with `local_path` matching the cwd exists
- **6255** — `Init.CliConfig.command` returns a prompt naming `list_projects` and `init_project` and `project_id` when the cwd has no linked Project row

### Scenario 2: Boundary warning inspection

The spex files for criteria 6247-6255 reference `CodeMySpec.AgentTasks.Init.*` directly, crossing the `CodeMySpecSpex → CodeMySpec` boundary (only `CodeMySpec.McpServers` is declared as a dep). Verify these are warnings, not compilation errors:

```
mix spex 2>&1 | grep "forbidden reference.*711"
```

Expected: warnings appear but all tests pass (since the spex compiler is currently disabled in mix.exs).

### Scenario 3: Browser smoke test — local app lists projects

Verify the local app is running and the bootstrap endpoint responds:

```
curl -sSf http://127.0.0.1:4004/health
```

Expected: `{"status":"ok"}`

```
curl -sSf http://127.0.0.1:4004/api/bootstrap/auth/status
```

Expected: JSON with `authenticated` boolean field.

### Scenario 4: install_claude_md idempotency via browser

Navigate to `http://127.0.0.1:4004/` and verify the project hub renders. Check the sandbox project at `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` for any existing CLAUDE.md and `.code_my_spec/rules/` state.

## Setup Notes

This story tests the **agent-surface MCP tools**, not human-facing LiveViews. The primary testing surface is:

1. `mix spex` — exercises all 17 criteria via ExUnit + spex runner calling tool modules directly
2. `curl` against `/health` and `/api/bootstrap/auth/status` as a basic smoke test that the bootstrap API is reachable

The spex tests use `setup_active_project` which creates a temporary directory as the project cwd, so tests are fully isolated and do not mutate the sandbox.

ExCliVcr cassettes at `test/fixtures/cassettes/init_*.json` replay shell-out responses for criteria 6247-6249 so those tests pass regardless of the host Elixir/Phoenix installation state.

The boundary warnings in 6247-6255 (referencing `CodeMySpec.AgentTasks.Init.*`) are non-blocking because the spex compiler is disabled in `mix.exs`. They are a code quality concern worth filing as a QA issue.

## Result Path

`.code_my_spec/qa/711/result.md`
