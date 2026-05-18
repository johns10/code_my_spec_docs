# Qa Result

## Status

pass

## Scenarios

### Scenario 1: Spex test suite — all 17 criteria

Ran `mix spex test/spex/711_agent_bootstraps_a_project/` and verified all 17 spex files compiled and ran.

Result: 497 tests total, 0 failures. All 17 story-711 criteria passed.

Criteria coverage:

- **6239** (first install creates CLAUDE.md with managed section) — passed
- **6240** (re-install preserves user content, replaces managed section) — passed
- **6241** (install_agents_md writes AGENTS.md when mix.exs present) — passed
- **6242** (install_agents_md errors with project-root directive when mix.exs absent) — passed
- **6243** (first install copies every priv/rules .md into .code_my_spec/rules/) — passed
- **6244** (re-install preserves user-modified rule file) — passed
- **6245** (sync_project returns non-zero Files: and Components: summary) — passed
- **6246** (unauthenticated sync reports "skipped (not authenticated)" but completes local sync) — passed
- **6247** (Init.command renders 5/6 progress, full checklist, only Auth inlined, Auth marked next) — passed
- **6248** (Init.Elixir.evaluate returns {:ok, :valid} via cassette init_elixir_pass.json) — passed
- **6249** (Init.PhoenixInstaller.evaluate returns {:ok, :invalid, detail} naming mix archive.install hex phx_new via cassette) — passed
- **6250** (Init.PhoenixProject.evaluate returns {:ok, :valid} with mix.exs + lib/ + config/ present) — passed
- **6251** (Init.PhoenixProject.command returns relaunch/project-root prompt and names cwd when mix.exs absent) — passed
- **6252** (Init.Auth.evaluate returns {:ok, :valid} when ClientUser row exists) — passed
- **6253** (Init.Auth.command returns sign-in prompt naming CodeMySpec, cannot complete automatically) — passed
- **6254** (Init.CliConfig.evaluate returns {:ok, :valid} when Project row local_path matches cwd) — passed
- **6255** (Init.CliConfig.command returns prompt naming list_projects and init_project and project_id) — passed

### Scenario 2: Boundary warning inspection

Ran `mix spex 2>&1 | grep "forbidden reference.*Init"`. Result: 9 boundary warnings (one per Init sub-step alias in criteria 6247-6255 spex files). These are compile-time warnings emitted by the Boundary library, not test failures. All tests still pass because the spex compiler is disabled in mix.exs at production time.

The warnings indicate that `CodeMySpecSpex` (boundary) references `CodeMySpec.AgentTasks.Init.*` modules which are in the `CodeMySpec` boundary — but `CodeMySpecSpex` only declares `CodeMySpec.McpServers` as an allowed dep, not `CodeMySpec` directly.

### Scenario 3: Browser smoke tests — local app health and bootstrap API

`curl -sSf http://127.0.0.1:4004/health` returned `{"status":"ok"}` — local app is running.

`curl -sSf http://127.0.0.1:4004/api/bootstrap/auth/status` returned `{"email":"johns10@gmail.com","authenticated":true}` — bootstrap auth status endpoint is reachable and correctly reports authenticated state.

### Scenario 4: Init page rendering — browser verification

Navigated to `http://127.0.0.1:4004/projects/code-my-spec/init`. Page rendered correctly with header `PROJECT INIT (6/6)` and all six sub-steps checked:
- Auth (checked)
- Elixir (checked)
- Phoenix installer (checked)
- Postgresql (checked)
- Phoenix project (checked)
- Cli config (checked)

Navigated to `http://127.0.0.1:4004/projects/qa-fixture-project/init` (the QA sandbox). Page rendered correctly with header `PROJECT INIT (6/6)` and all six sub-steps checked. This confirms `Init.CliConfig` is satisfied for both the main project and the sandbox.

## Evidence

- `.code_my_spec/qa/711/screenshots/711_local_app_home.png` — Local app home at port 4004, auth and project link sections visible
- `.code_my_spec/qa/711/screenshots/711_project_hub.png` — Code My Spec project hub showing navigation cards
- `.code_my_spec/qa/711/screenshots/711_init_page.png` — Init page for main project: PROJECT INIT (6/6), all sub-steps checked
- `.code_my_spec/qa/711/screenshots/711_sandbox_init_page.png` — Init page for QA sandbox: PROJECT INIT (6/6), all sub-steps checked

## Issues

### Spex files for criteria 6247-6255 reference CodeMySpec.AgentTasks.Init.* in violation of CodeMySpecSpex boundary

#### Severity
MEDIUM

#### Scope
APP

#### Description
Nine of the seventeen spex files for story 711 import modules from `CodeMySpec.AgentTasks.Init.*` directly. The `CodeMySpecSpex` boundary only declares `CodeMySpec.McpServers` as an allowed dependency — not `CodeMySpec` itself. This produces nine Boundary library warnings at compile time:

- `criterion_6247` imports `CodeMySpec.AgentTasks.Init`
- `criterion_6248` imports `CodeMySpec.AgentTasks.Init.Elixir`
- `criterion_6249` imports `CodeMySpec.AgentTasks.Init.PhoenixInstaller`
- `criterion_6250` imports `CodeMySpec.AgentTasks.Init.PhoenixProject`
- `criterion_6251` imports `CodeMySpec.AgentTasks.Init.PhoenixProject`
- `criterion_6252` imports `CodeMySpec.AgentTasks.Init.Auth`
- `criterion_6253` imports `CodeMySpec.AgentTasks.Init.Auth`
- `criterion_6254` imports `CodeMySpec.AgentTasks.Init.CliConfig`
- `criterion_6255` imports `CodeMySpec.AgentTasks.Init.CliConfig`

The tests pass currently because the spex compiler is disabled in mix.exs (`:spex` not in `:compilers`). When the spex compiler is re-enabled, these violations will become errors that block compilation. The fix is either: (a) move `AgentTasks.Init.*` modules into `CodeMySpec.McpServers` boundary scope (since they are the agent surface), or (b) add `CodeMySpec` as an allowed dep in `CodeMySpecSpex`. Option (a) is architecturally cleaner since these init steps are the agent-facing bootstrap surface.

### Criterion 6247 checklist word-matching assertion is weaker than intended

#### Severity
LOW

#### Scope
APP

#### Description
The spex for criterion 6247 checks sub-step names using `~w(Auth Elixir Phoenix installer Postgresql Phoenix project Cli config)` which produces a list of individual words: `["Auth", "Elixir", "Phoenix", "installer", "Postgresql", "Phoenix", "project", "Cli", "config"]`. Each word is asserted individually against the prompt. This means "Phoenix" is checked twice (once for "Phoenix installer" and once for "Phoenix project") and "installer", "project", "Cli", "config" are checked as standalone tokens.

The assertion does not verify that the checklist contains "Phoenix installer" or "Cli config" as full step names — it only verifies the individual words appear somewhere in the prompt. If a future refactor renames "Cli config" to "Config" and moves "cli" somewhere else in the text, the test would still pass even though the step name changed.

This is a test specificity issue, not a broken test. The spex passes correctly against the current implementation. A stronger assertion would check for the full step names as rendered by `Init.step_name/1`.
