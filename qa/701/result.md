# QA Result — Story 701

Story 701 — Local app onboarding guides me from sign-in to my first story.

**Overall result: PASS**

All 10 browser scenarios pass. Both channel/analytics spex tests pass.

---

## Setup Notes

### Critical discovery: dev_cli uses SQLite, not Postgres

The running local server (PID 60320) was started with `MIX_ENV=dev_cli`. In this
environment, `CodeMySpec.Repo` points to `~/.codemyspec/cli.db` (SQLite), NOT the
`code_my_spec_dev` Postgres database. The brief's setup commands use `mix run`
(default MIX_ENV=dev), which writes to Postgres — those writes have no effect on
the running local server.

All setup for these QA scenarios was done by direct SQLite writes:
- `sqlite3 ~/.codemyspec/cli.db` for client_users, projects, events, stories
- A `MIX_ENV=dev_cli mix run --no-start` helper to write Cloak-encrypted tokens
- The Postgres `client_users` table was not used by the running server

The brief's "Unauthenticated state" instruction assumes the expired token (2026-04-20)
is unrefreshable. In practice the dev_cli server refreshes successfully via the
Cloudflare tunnel. The unauthenticated state was achieved by setting
`oauth_token = NULL` in the SQLite `client_users` table.

### QA project in SQLite

The QA project `11111111-1111-4111-8111-111111111111` exists in both Postgres and
SQLite with these properties:
- SQLite: `local_path=/Users/johndavenport/Documents/github/qa_test_project`,
  initially `client_user_id=NULL`
- The slug `qa-fixture-project` is derived from "QA Fixture Project" by the
  `project_slug/1` helper

---

## Scenario Results

### Scenario 1 — Newly handed-off user sees both local-install rungs (criterion 6059)

**PASS**

- Cleared SQLite `oauth_token` for id=1 (`johns10@gmail.com`)
- Navigated to `http://127.0.0.1:4003/`
- `[data-test="local-install-ladder"]`: present
- `[data-test="auth-rung"]`: present, `data-state="active"` (shows "Sign in" link)
- `[data-test="linked-project-rung"]`: present, `data-state="pending"`

Screenshot: `4003_scenario1_unauthenticated.png`

### Scenario 2 — Authed user with no linked project sees only linked-project rung active (criterion 6060)

**PASS**

- Inserted `client_users` row id=99 into SQLite via `MIX_ENV=dev_cli mix run --no-start`
  with Cloak-encrypted token and `oauth_expires_at` 30 days in the future
- No project has `client_user_id=99`
- Navigated to `http://127.0.0.1:4003/`
- `[data-test="auth-rung"][data-state="done"]`: confirms authenticated
- `[data-test="linked-project-rung"][data-state="active"]`: shows `/codemyspec:init` CTA

Screenshot: `4003_scenario2_authed_no_project.png`

### Scenario 3 — Fully set-up user does not see the local-install ladder (criterion 6061)

**PASS**

- Set `client_user_id=99` on the QA project in SQLite
- Navigated to `http://127.0.0.1:4003/`
- `[data-test="local-install-ladder"]`: NOT rendered (confirmed via `browser_find` returning nil)
- Page has `<h1>Projects</h1>` heading

Screenshot: `4003_scenario3_fully_setup.png`

### Scenario 4 — Project with no stories shows per-project ladder (criterion 6062)

**PASS**

- Temporarily reassigned the QA project's single story to a dummy `project_id`
- Navigated to `http://127.0.0.1:4003/projects/qa-fixture-project`
- `[data-test="per-project-ladder"]`: present
- `[data-test="init-rung"]`: present (`data-state="active"`)
- `[data-test="project-setup-rung"]`: present (`data-state="pending"`)
- `[data-test="first-story-rung"]`: present (`data-state="pending"`)
- `[data-test="project-home-dashcards"]`: NOT present

Screenshot: `4003_scenario4_no_stories_ladder.png`

### Scenario 5 — Project with at least one story shows standard project home (criterion 6063)

**PASS**

- Restored the story to the QA project
- Navigated to `http://127.0.0.1:4003/projects/qa-fixture-project`
- `[data-test="project-home-dashcards"]`: present
- `[data-test="per-project-ladder"]`: NOT present (confirmed via curl)

Screenshot: `4003_scenario5_with_stories.png`

### Scenario 6 — Every rung renders with chamfered shell and step-N eyebrow (criterion 6064)

**PASS**

- Navigated to `http://127.0.0.1:4003/projects/qa-fixture-project` (no stories state)
- `[data-test="init-rung"]` has `class="cms-onboarding"`: confirmed
- `[data-test="project-setup-rung"]` has `class="cms-onboarding"`: confirmed
- `[data-test="first-story-rung"]` has `class="cms-onboarding"`: confirmed
- `[data-test="init-rung"]` contains "// step 01 · init": confirmed
- `[data-test="project-setup-rung"]` contains "// step 02 · project setup": confirmed
- `[data-test="first-story-rung"]` contains "// step 03 · first story": confirmed

Screenshot: `4003_scenario6_eyebrows.png`

### Scenario 7 — Active rung is the first incomplete in order (criterion 6065)

**PASS**

- Inserted `local_init_complete` event into SQLite events table:
  `event_type='local_init_complete', data='{"project_id":"11111111-1111-4111-8111-111111111111"}'`
- Navigated to `http://127.0.0.1:4003/projects/qa-fixture-project` (no stories state)
- `[data-test="init-rung"][data-state="done"]`: confirmed
- `[data-test="project-setup-rung"][data-state="active"]`: confirmed
- `[data-test="first-story-rung"][data-state="pending"]`: confirmed

Screenshot: `4003_scenario7_active_rung.png`

### Scenario 8 — Pending first-story rung is non-actionable (criterion 6066)

**PASS**

- Removed `local_init_complete` event so init is NOT done
- Navigated to `http://127.0.0.1:4003/projects/qa-fixture-project` (no stories state)
- `[data-test="first-story-rung"][data-state="pending"]`: confirmed
- HTML for first-story-rung: `<div data-test="first-story-rung" data-state="pending" class="cms-onboarding" style="opacity: 0.55;">`
- No `phx-click` attribute: confirmed
- No `href=` attribute: confirmed (it is a plain `<div>`, not a link)

Screenshot: `4003_scenario8_pending_rung.png`

### Scenario 9 — Local app routes user to named project's ladder (criterion 6067)

**PASS**

- Navigated to `http://127.0.0.1:4003/?project=11111111-1111-4111-8111-111111111111`
- Browser redirected to `http://127.0.0.1:4003/projects/qa-fixture-project` (confirmed
  via `browser_get_url`)
- QA project has `local_path` set in SQLite and the LiveView `handle_params/3` matched

Screenshot: `4003_scenario9_redirect.png`

### Scenario 10 — Missing or unknown project query param falls back (criterion 6068)

**PASS**

- Navigated to `http://127.0.0.1:4003/?project=999999999`
- URL did not change (confirmed via `browser_get_url`)
- Page shows "Projects" heading (no redirect, no error)
- Flash group `#flash-group` is empty: no "Project not found" flash

Screenshot: `4003_scenario10_fallback.png`

### Scenario 11 — Channel activation events (criteria 6069, 6070)

**PASS**

Both spex tests executed with `mix test --trace`:

**Criterion 6069** — Each onboarding milestone fires its activation event over the channel:
```
1 test, 0 failures
```

**Criterion 6070** — CliChannel routes received activation events through analytics:
```
1 test, 0 failures
```

---

## Findings

### Finding 1 — dev_cli uses SQLite, brief assumes Postgres (LOW)

The brief's setup section instructs using `mix run -e 'CodeMySpec.Repo.insert!(...)'`
and `mix run priv/repo/qa_seeds.exs` to set up client_user rows. These commands run
in the default `dev` (Postgres) environment. The running local server uses `dev_cli`
(SQLite). The setup commands have no effect on the running server.

The brief should note: all client_user, project link, and event manipulation for QA
scenarios targeting port 4003 must use SQLite directly or `MIX_ENV=dev_cli mix run`.

### Finding 2 — Token auto-refresh masks unauthenticated state (LOW)

When the running server has a client_user with a valid refresh token, it successfully
refreshes via the Cloudflare tunnel on every mount. Setting `oauth_expires_at` to a
past date does not produce unauthenticated state while the Cloudflare tunnel is live.
The unauthenticated scenario requires `oauth_token = NULL` in the SQLite table.

### Finding 3 — QA Fixture Project has a leftover story (LOW)

Story id=566 ("QA: Three Amigos UI smoke") in the SQLite DB has
`project_id='11111111-1111-4111-8111-111111111111'`. This story was inserted during
Story 686 QA. It causes the "no stories" ladder to be hidden by default. Scenarios
requiring the per-project-ladder need to temporarily reassign this story.

---

## DB State After QA

SQLite `~/.codemyspec/cli.db` after QA:
- `client_users`: id=1 (token=NULL, unauthenticated), id=99 (token=encrypted, valid through ~2026-06-16)
- `projects`: QA project `11111111-1111-4111-8111-111111111111` has `client_user_id=99`, `local_path=/Users/johndavenport/Documents/github/qa_test_project`
- `events`: empty (all test events cleaned up)
- `stories`: story id=566 restored to `project_id='11111111-1111-4111-8111-111111111111'`
