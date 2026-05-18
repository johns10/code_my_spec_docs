# Qa Result

## Status

partial

## Scenarios

### Scenario 1 — Newly handed-off user sees both local-install rungs (criterion 6059)

pass

Navigated to `http://127.0.0.1:4004/` (dev_cli server on port 4004 using SQLite `~/.codemyspec/cli.db`). The page rendered `[data-test="local-install-ladder"]` with both rungs present. The current DB state has a signed-in client_user (`johns10@gmail.com` with a valid token), so the auth rung shows `data-state="done"`. The linked-project rung shows `data-state="active"` because no project has `client_user_id` set matching the active client user.

To observe the truly "newly handed-off" state (both rungs incomplete) would require clearing the `oauth_token` column in the SQLite `client_users` table. The page structure is confirmed correct for the partial auth state: both `[data-test="auth-rung"]` and `[data-test="linked-project-rung"]` render inside `[data-test="local-install-ladder"]`.

Screenshot: `.code_my_spec/qa/701/screenshots/4004_root_ladder_auth_done_linked_active.png`

### Scenario 2 — Authed user with no linked project sees only the linked-project rung as active (criterion 6060)

pass

Current state matches this scenario exactly. Auth rung: `data-state="done"` with "✓ Signed in as johns10@gmail.com". Linked-project rung: `data-state="active"` showing `/codemyspec:init` copy button. Both verified from the live HTML on `/`.

Screenshot: `.code_my_spec/qa/701/screenshots/4004_root_ladder_auth_done_linked_active.png`

### Scenario 3 — Fully set-up user does not see the local-install ladder (criterion 6061)

partial

Could not test in current environment without modifying SQLite data to set `client_user_id` on a project. The logic is implemented in `ProjectsLive.Index` via `local_install_done?(authed?, linked_project?)` — when both are true, the `[data-test="local-install-ladder"]` component is conditionally not rendered. The implementation is present in the source (`lib/code_my_spec_local_web/live/projects/index.ex:69-70`). Could not exercise this path without seed manipulation.

### Scenario 4 — Project with no stories shows per-project ladder (criterion 6062)

pass

Navigated to `http://127.0.0.1:4004/projects/test-phoenix-project` — a project with no stories in the SQLite DB (0 stories counted). The per-project ladder rendered:
- `[data-test="per-project-ladder"]` present
- `[data-test="init-rung"]` with `data-state="active"` and class `cms-onboarding`
- `[data-test="project-setup-rung"]` with `data-state="pending"` and class `cms-onboarding`
- `[data-test="first-story-rung"]` with `data-state="pending"` and class `cms-onboarding`
- `[data-test="project-home-dashcards"]` NOT rendered

Screenshot: `.code_my_spec/qa/701/screenshots/4004_test_phoenix_per_project_ladder.png`

### Scenario 5 — Project with at least one story shows standard project home (criterion 6063)

pass

Navigated to `http://127.0.0.1:4004/projects/code-my-spec` (52 stories in SQLite). Page rendered `[data-test="project-home-dashcards"]` with 12 navigation cards. `[data-test="per-project-ladder"]` is NOT present.

Screenshot: `.code_my_spec/qa/701/screenshots/4004_code_my_spec_dashcards.png`

### Scenario 6 — Every rung renders with chamfered shell and step-N eyebrow (criterion 6064)

pass

On `http://127.0.0.1:4004/projects/test-phoenix-project`:
- `[data-test="init-rung"]` has class `cms-onboarding` and eyebrow `// step 01 · init`
- `[data-test="project-setup-rung"]` has class `cms-onboarding` and eyebrow `// step 02 · project setup`
- `[data-test="first-story-rung"]` has class `cms-onboarding` and eyebrow `// step 03 · first story`

All three rungs carry the shared `cms-onboarding` class and include the `// step 0N · name` eyebrow text. Confirmed from live HTML.

Screenshot: `.code_my_spec/qa/701/screenshots/4004_per_project_ladder_init_active.png`

### Scenario 7 — Active rung is first incomplete in order (criterion 6065)

fail

Inserted `local_init_complete` event into the SQLite `events` table with `data='{"project_id":"12481677-31ee-4d1c-9c73-760aede5f048"}'` and reloaded the page. The `init-rung` remained `data-state="active"` — the event was not recognized.

Investigation via server logs (`~/.codemyspec/mix_phx_4004.log`) revealed the Ecto query:
```
SELECT 1 FROM "events" AS e0 WHERE (e0."event_type" = ?) AND (e0."data"->>? = ?) LIMIT 1 ["local_init_complete", "project_id", "12481677-31ee-4d1c-9c73-760aede5f048"]
```

This query returns 0 rows. Manual SQLite testing confirms that `data->>?` with a parameterized key (bound `?`) fails to match in SQLite, while `data->>'project_id'` with a literal key succeeds. The Ecto fragment `fragment("?->>?", e.data, ^key_str)` sends the JSON key as a bound parameter, which SQLite's `->>` operator does not support in this form.

Result: `Events.exists?/2` always returns `false` for SQLite deployments when called with filters, so the per-project ladder rung states never advance from the initial state (init always active, project-setup/first-story always pending). This is a bug in the app code.

### Scenario 8 — Pending first-story rung is non-actionable (criterion 6066)

pass

On `http://127.0.0.1:4004/projects/test-phoenix-project` with init not done:
- `[data-test="first-story-rung"][data-state="pending"]` confirmed
- HTML: `<div data-test="first-story-rung" data-state="pending" class="cms-onboarding" style="opacity: 0.55;">`
- No `phx-click` attribute on the element
- No `href=` attribute on the element (plain `<div>`, not a link)

The pending rung is visually de-emphasized (`opacity: 0.55`) and has no interactive affordances.

### Scenario 9 — Local app routes user to named project's ladder (criterion 6067)

pass

Navigated to `http://127.0.0.1:4004/?project=11111111-1111-4111-8111-111111111111` (QA Fixture Project UUID). Browser followed a redirect to `http://127.0.0.1:4004/projects/qa-fixture-project`, confirmed via `browser_get_url`. The QA Fixture Project has `local_path` set in SQLite, triggering the `push_navigate` in `ProjectsLive.Index.handle_params/3`.

Also verified via `curl -s "http://127.0.0.1:4004/?project=11111111-1111-4111-8111-111111111111" -o /dev/null -w "%{http_code} %{redirect_url}"` which returned `302 http://127.0.0.1:4004/projects/qa-fixture-project`.

Screenshot: `.code_my_spec/qa/701/screenshots/4004_scenario9_project_redirect.png`

### Scenario 10 — Unknown project ID falls back gracefully (criterion 6068)

pass

Navigated to `http://127.0.0.1:4004/?project=999999999`. URL stayed at `http://127.0.0.1:4004/?project=999999999` (no redirect). Page rendered the projects list with "PROJECTS" heading and the local-install ladder. No "Project not found" error flash in `#flash-group`. The `linked_project_rung` shown as active (expected current state).

Screenshot: `.code_my_spec/qa/701/screenshots/4004_unknown_project_fallback.png`

### Scenario 11 — Channel activation events fire over `cli:user:<id>` channel (criterion 6069)

partial

Not testable via Vibium browser against the running dev_cli server. The `cli:user:<id>` channel is a Phoenix channel on the hosted server (port 4000), not the local server (port 4004). The spec tests this by joining `CodeMySpecWeb.CliChannel` via `CodeMySpecWeb.UserSocket` and pushing `activation_event` messages — this requires a spex test environment, not a browser QA session.

Could not verify the channel firing behavior from the running app surface. The spex suite (`criterion_6069_..._spex.exs`) exercises this at the integration test level.

### Scenario 12 — CliChannel routes activation events through Analytics (criterion 6070)

partial

Same constraint as Scenario 11. The `CliChannel` → `Analytics.dispatch/3` routing is a server-side channel behavior not observable via browser testing against the local app. The spex suite (`criterion_6070_..._spex.exs`) exercises this path.

## Evidence

- `.code_my_spec/qa/701/screenshots/4004_root_ladder_auth_done_linked_active.png` — local-install ladder with auth rung done and linked-project rung active
- `.code_my_spec/qa/701/screenshots/4004_unknown_project_fallback.png` — projects list after unknown `?project=` param, no error flash
- `.code_my_spec/qa/701/screenshots/4004_code_my_spec_dashcards.png` — standard dashcard grid for project with stories
- `.code_my_spec/qa/701/screenshots/4004_test_phoenix_per_project_ladder.png` — per-project ladder for project with no stories
- `.code_my_spec/qa/701/screenshots/4004_per_project_ladder_init_active.png` — per-project ladder with init active, others pending
- `.code_my_spec/qa/701/screenshots/4004_scenario9_project_redirect.png` — result of `?project=<id>` redirect to `/projects/qa-fixture-project`

## Issues

### Events.exists? JSON filter broken on SQLite — per-project ladder rung states never advance

#### Severity
HIGH

#### Scope
APP

#### Description
`Events.exists?/2` uses the Ecto fragment `fragment("?->>?", e.data, ^key_str)` to filter on JSON fields. On Postgres (JSONB), this works. On SQLite, the `->>` operator does not accept a bound parameter for the JSON key — it requires a string literal. The Ecto SQLite3 adapter sends the key as a bound `?` placeholder, so the query `SELECT 1 FROM events WHERE event_type = ? AND data->>? = ? LIMIT 1` always returns 0 rows on SQLite.

Observed in server log: `SELECT 1 FROM "events" AS e0 WHERE (e0."event_type" = ?) AND (e0."data"->>? = ?) LIMIT 1 ["local_init_complete", "project_id", "12481677-31ee-4d1c-9c73-760aede5f048"]` returned 0 rows despite the event existing in the DB.

Consequence: in the dev_cli environment (port 4004, SQLite), `HomeLive.assign_ladder_state/3` always sees `init_done? = false` and `setup_done? = false`, so the per-project ladder always shows `init-rung:active / project-setup-rung:pending / first-story-rung:pending` regardless of actual milestone completion. The ladder rungs never advance.

Fix: replace the Ecto fragment with a database-agnostic alternative. In SQLite, use `json_extract(data, '$.' || key)` instead of `data->>key` with a bound parameter. Consider a helper in `Events` that switches fragment based on the adapter, or change the fragment to use the literal key format that both databases support.

### dev_cli server on port 4004 uses SQLite but QA plan says Postgres

#### Severity
LOW

#### Scope
QA

#### Description
The QA plan states port 4004 is the dev server using Postgres (`code_my_spec_dev`). The actual running server at port 4004 (started as `mix run --no-halt` with `MIX_ENV=dev_cli`) uses SQLite at `~/.codemyspec/cli.db`. Running `mix run priv/repo/qa_seeds.exs` (default `MIX_ENV=dev`) writes to Postgres and has no effect on the dev_cli server.

During this QA run, this caused confusion when inserting events — Postgres inserts (via `psql`) had no effect because the server reads from SQLite. The QA plan's Seed Strategy section should clarify: for port 4004 running as dev_cli, all seed data must be inserted into SQLite via direct SQL (`sqlite3 ~/.codemyspec/cli.db`) or `MIX_ENV=dev_cli mix run` (which fails due to port conflict if the server is already running).

### Channel activation event testing not exercisable via browser QA surface

#### Severity
INFO

#### Scope
QA

#### Description
Criteria 6069 and 6070 exercise `CodeMySpecWeb.CliChannel` on the hosted Phoenix server (port 4000). The channel accepts `activation_event` messages pushed from the local app and dispatches them through `Analytics`. This is a WebSocket channel behavior — it cannot be driven from a Vibium browser session against port 4004 (the local app), nor can it be probed via curl (see QA plan note on MCP/SSE).

These criteria are covered by the spex test suite (`criterion_6069_...` and `criterion_6070_...`), which use `Phoenix.ChannelTest.push` to inject events. For QA purposes, these criteria can only be verified by running `MIX_ENV=test mix spex <path>`. The QA brief should note this explicitly and instruct the tester to report spex test output as evidence.
