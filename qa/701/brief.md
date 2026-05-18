# Qa Story Brief

Story 701 — Local app onboarding guides me from sign-in to my first story.

## Tool

web (Vibium MCP browser tools for all LiveView pages on port 4004)

## Auth

No authentication required. The local app (`CodeMySpecLocalWeb`) runs on port 4004 using `Plugs.LocalOnly` — it accepts any loopback connection without user credentials. Navigate directly to `http://127.0.0.1:4004/`.

Auth state for the local-install ladder comes from the `client_users` table in the SQLite DB at `~/.codemyspec/cli.db`. The `OAuthClient.authenticated?()` check reads the most recent `client_user` row and validates the token is not expired.

Note: The running server at port 4004 uses `MIX_ENV=dev_cli` (SQLite), NOT `MIX_ENV=dev` (Postgres). All seed data must target SQLite via `sqlite3 ~/.codemyspec/cli.db` or `MIX_ENV=dev_cli mix run` (may fail if server is already running on port 4004 due to `:eaddrinuse`).

## Seeds

The following projects exist in the SQLite DB (`~/.codemyspec/cli.db`) and can be used for testing:

- `code-my-spec` slug → `/Users/johndavenport/Documents/github/code_my_spec` — has 52 stories (use for "project with stories" scenarios)
- `test-phoenix-project` slug → `/Users/johndavenport/Documents/github/code_my_spec_test_repos/test_phoenix_project` — has 0 stories (use for "project without stories" scenarios)
- `qa-fixture-project` slug → `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` — has 1 story; UUID `11111111-1111-4111-8111-111111111111` (use for `?project=<id>` redirect scenario)

Current auth state: signed in as `johns10@gmail.com` (auth rung shows as `done`). No project has `client_user_id` set (linked-project rung shows as `active`).

For the init-done rung state (criterion 6065), insert a `local_init_complete` event via `sqlite3 ~/.codemyspec/cli.db "INSERT INTO events (event_type, data, inserted_at) VALUES ('local_init_complete', '{\"project_id\":\"<project-uuid>\"}', datetime('now'));"`. Note: this currently has no effect due to a bug in `Events.exists?/2` with SQLite (parameterized JSON key extraction fails — see Issues in result.md).

## What To Test

### Scenario 1 — Local-install ladder renders on `/` (criteria 6059, 6060)

1. Navigate to `http://127.0.0.1:4004/`
2. Verify `[data-test="local-install-ladder"]` is present in the DOM
3. Verify `[data-test="auth-rung"]` is present
4. Verify `[data-test="linked-project-rung"]` is present
5. Check `data-state` on each rung — currently expect `auth-rung[data-state="done"]` (signed in) and `linked-project-rung[data-state="active"]` (no linked project)
6. Screenshot the page

### Scenario 2 — Fully set-up user does not see the local-install ladder (criterion 6061)

1. If both rungs are done (authed + linked project), navigate to `http://127.0.0.1:4004/`
2. Verify `[data-test="local-install-ladder"]` is NOT present
3. Verify the "Projects" heading renders as the primary content
4. Note: this requires SQLite manipulation to set `client_user_id` on a project row

### Scenario 3 — Project with no stories shows per-project ladder (criterion 6062)

1. Navigate to `http://127.0.0.1:4004/projects/test-phoenix-project`
2. Verify `[data-test="per-project-ladder"]` is present
3. Verify all three rungs: `[data-test="init-rung"]`, `[data-test="project-setup-rung"]`, `[data-test="first-story-rung"]`
4. Verify `[data-test="project-home-dashcards"]` is NOT present
5. Screenshot the per-project ladder

### Scenario 4 — Project with at least one story shows standard project home (criterion 6063)

1. Navigate to `http://127.0.0.1:4004/projects/code-my-spec`
2. Verify `[data-test="project-home-dashcards"]` IS present
3. Verify `[data-test="per-project-ladder"]` is NOT present
4. Screenshot the standard dash-card grid

### Scenario 5 — Chamfered shell and step-N eyebrow on rungs (criterion 6064)

1. Navigate to `http://127.0.0.1:4004/projects/test-phoenix-project` (no stories)
2. For each rung: verify element carries class `cms-onboarding`
3. Verify eyebrow texts: `// step 01 · init`, `// step 02 · project setup`, `// step 03 · first story`
4. Screenshot the ladder

### Scenario 6 — Active rung is first incomplete in order (criterion 6065)

1. Attempt to insert `local_init_complete` event into SQLite for `test-phoenix-project`
2. Navigate to `http://127.0.0.1:4004/projects/test-phoenix-project`
3. Check `data-state` on each rung — observe whether event was picked up
4. Document actual vs expected behavior (this criterion may be blocked by the `Events.exists?` SQLite bug)

### Scenario 7 — Pending first-story rung is non-actionable (criterion 6066)

1. On `http://127.0.0.1:4004/projects/test-phoenix-project` with init NOT done
2. Verify `first-story-rung[data-state="pending"]`
3. Inspect HTML of first-story rung: confirm no `phx-click` attribute and no `href=`
4. Screenshot the pending first-story rung

### Scenario 8 — `?project=<id>` routes to named project (criterion 6067)

1. Navigate to `http://127.0.0.1:4004/?project=11111111-1111-4111-8111-111111111111`
2. Verify the browser redirects to `http://127.0.0.1:4004/projects/qa-fixture-project`
3. Screenshot the resulting page

### Scenario 9 — Unknown project ID falls back gracefully (criterion 6068)

1. Navigate to `http://127.0.0.1:4004/?project=999999999`
2. Verify the page shows the Projects list ("Projects" heading present)
3. Verify no "Project not found" error flash
4. Screenshot the fallback page

### Scenario 10 — Channel activation events (criteria 6069, 6070)

These criteria test the hosted `CodeMySpecWeb.CliChannel` — not testable via Vibium browser on the local app. Run the spex tests:

```
MIX_ENV=test mix spex test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6069_each_milestone_fires_its_activation_event_over_the_channel_spex.exs
MIX_ENV=test mix spex test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6070_clichannel_routes_received_activation_events_through_analytics_spex.exs
```

Report pass/fail from test output.

## Result Path

`.code_my_spec/qa/701/result.md`

## Setup Notes

The local app at port 4004 runs `MIX_ENV=dev_cli` which uses SQLite (`~/.codemyspec/cli.db`), not the Postgres `code_my_spec_dev` database. Do NOT use `psql` or `mix run priv/repo/qa_seeds.exs` (default Postgres) for data setup on port 4004 tests. Use `sqlite3 ~/.codemyspec/cli.db` instead.

Known issue: `Events.exists?/2` is broken on SQLite — the `fragment("?->>?", e.data, ^key_str)` Ecto query fails to match JSON fields when the key is parameterized. This means the per-project ladder rung states (init, project-setup, first-story) cannot be advanced beyond the initial state in the dev_cli environment.
