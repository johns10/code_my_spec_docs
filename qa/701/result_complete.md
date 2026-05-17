# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — Newly handed-off user sees both local-install rungs (criterion 6059)

pass

Navigated to `http://127.0.0.1:4003/` with `oauth_token=NULL` in the SQLite `client_users` table (simulating no auth state). The `local-install-ladder` rendered with both rungs:
- `[data-test="local-install-ladder"]` present ✓
- `[data-test="auth-rung"]` with `data-state="active"` and "Sign in" CTA ✓
- `[data-test="linked-project-rung"]` with `data-state="pending"` and `aria-disabled="true"` ✓

Confirmed by spex test: `mix test criterion_6059_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario1_unauthenticated.png`

### Scenario 2 — Authed user with no linked project sees linked-project rung active (criterion 6060)

pass

With a valid Cloak-encrypted token set for client_user 1 (johns10@gmail.com) and no project rows having `client_user_id=1` in SQLite, the page rendered:
- `[data-test="auth-rung"][data-state="done"]` with "✓ Signed in as johns10@gmail.com" ✓
- `[data-test="linked-project-rung"][data-state="active"]` with copy-able `/codemyspec:init` command ✓

Confirmed by spex test: `mix test criterion_6060_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario2_authed_no_project.png`

### Scenario 3 — Fully set-up user does not see the local-install ladder (criterion 6061)

pass

Set `client_user_id=1` on the "Code My Spec" project in SQLite (the project with a valid `local_path`). Navigated to `http://127.0.0.1:4003/`:
- `[data-test="local-install-ladder"]` NOT rendered ✓
- `<h1>Projects</h1>` heading present ✓
- Projects list (filtered to linked project) shown as primary content ✓

Confirmed by spex test: `mix test criterion_6061_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario3_fully_setup.png`

### Scenario 4 — Project with no stories shows per-project ladder (criterion 6062)

pass

Used "Test Phoenix Project" (slug `test-phoenix-project`, 0 stories in SQLite). Navigated to `http://127.0.0.1:4003/projects/test-phoenix-project`:
- `[data-test="per-project-ladder"]` present ✓
- `[data-test="init-rung"]` present ✓
- `[data-test="project-setup-rung"]` present ✓
- `[data-test="first-story-rung"]` present ✓
- `[data-test="project-home-dashcards"]` NOT rendered ✓

Note: The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) already has a story in SQLite so it shows dashcards. Used Test Phoenix Project (0 stories) for this scenario instead.

Confirmed by spex test: `mix test criterion_6062_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario4_no_stories_ladder.png`

### Scenario 5 — Project with at least one story shows standard project home (criterion 6063)

pass

Navigated to `http://127.0.0.1:4003/projects/qa-fixture-project` (QA Fixture Project has 1 story in SQLite):
- `[data-test="project-home-dashcards"]` present with all 12 nav cards ✓
- `[data-test="per-project-ladder"]` NOT rendered ✓

Confirmed by spex test: `mix test criterion_6063_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario5_with_stories.png`

### Scenario 6 — Every rung renders with chamfered shell and step-N eyebrow (criterion 6064)

pass

On `http://127.0.0.1:4003/projects/test-phoenix-project` (no stories, all three rungs visible):

Each rung carries `class="cms-onboarding"` ✓

Eyebrows confirmed in HTML:
- `init-rung`: "// step 01 · init" ✓
- `project-setup-rung`: "// step 02 · project setup" ✓
- `first-story-rung`: "// step 03 · first story" ✓

Confirmed by spex test: `mix test criterion_6064_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario6_eyebrows.png`

### Scenario 7 — Active rung is first incomplete in order (criterion 6065)

pass

Inserted `local_init_complete` event into SQLite events table for Test Phoenix Project (`project_id=12481677-31ee-4d1c-9c73-760aede5f048`). Navigated to the project page:
- `[data-test="init-rung"][data-state="done"]` with "✓ Done" indicator ✓
- `[data-test="project-setup-rung"][data-state="active"]` with `/codemyspec:next` copy button ✓
- `[data-test="first-story-rung"][data-state="pending"]` with reduced opacity ✓

Confirmed by spex test: `mix test criterion_6065_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario7_active_rung.png`

### Scenario 8 — Pending first-story rung is non-actionable (criterion 6066)

pass

On `http://127.0.0.1:4003/projects/test-phoenix-project` with init NOT done (deleted the event):
- `[data-test="first-story-rung"][data-state="pending"]` ✓
- HTML of first-story rung contains NO `phx-click` attribute ✓
- HTML of first-story rung contains NO `href=` attribute ✓
- Element has `style="opacity: 0.55;"` (visual non-actionable indicator) ✓

Confirmed by spex test: `mix test criterion_6066_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario8_pending_rung.png`

### Scenario 9 — Local app routes user to named project's ladder (criterion 6067)

pass

Navigated to `http://127.0.0.1:4003/?project=11111111-1111-4111-8111-111111111111` (QA Fixture Project UUID). Browser redirected to `http://127.0.0.1:4003/projects/qa-fixture-project`. The QA Fixture Project has `local_path` set in SQLite, triggering the `push_navigate` redirect.

Confirmed by spex test: `mix test criterion_6067_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario9_redirect.png`

### Scenario 10 — Missing or unknown project query param falls back to projects list (criterion 6068)

pass

Navigated to `http://127.0.0.1:4003/?project=999999999` (unknown integer ID). Page rendered the projects list:
- URL stayed at `/?project=999999999` (no redirect, no error) ✓
- "Projects" heading visible in page text ✓
- No "Project not found" error flash ✓

Confirmed by spex test: `mix test criterion_6068_..._spex.exs` → 1 test, 0 failures.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario10_fallback.png`

### Scenario 11 — Channel activation events fire (criteria 6069 and 6070)

pass

Ran spex tests via `mix test`:
- `criterion_6069_each_milestone_fires_its_activation_event_over_the_channel_spex.exs` → 1 test, 0 failures. All 5 activation events (`local_signed_in`, `local_project_linked`, `local_init_complete`, `local_project_setup_complete`, `first_local_story_created`) received by the analytics test subscriber.
- `criterion_6070_clichannel_routes_received_activation_events_through_analytics_spex.exs` → 1 test, 0 failures. GA test subscriber received the Measurement Protocol payload for `local_init_complete` with correct user identifier.

## Evidence

- `.code_my_spec/qa/701/screenshots/4003_scenario1_unauthenticated.png` — local-install-ladder with auth-rung active (no token)
- `.code_my_spec/qa/701/screenshots/4003_scenario2_authed_no_project.png` — auth-rung done, linked-project-rung active
- `.code_my_spec/qa/701/screenshots/4003_scenario3_fully_setup.png` — no ladder, only projects list
- `.code_my_spec/qa/701/screenshots/4003_scenario4_no_stories_ladder.png` — per-project ladder on test-phoenix-project
- `.code_my_spec/qa/701/screenshots/4003_scenario5_with_stories.png` — dashcards on qa-fixture-project (has stories)
- `.code_my_spec/qa/701/screenshots/4003_scenario6_eyebrows.png` — all rungs with cms-onboarding class and step eyebrows
- `.code_my_spec/qa/701/screenshots/4003_scenario7_active_rung.png` — init done, project-setup active, first-story pending
- `.code_my_spec/qa/701/screenshots/4003_scenario8_pending_rung.png` — first-story rung pending, no CTA affordances
- `.code_my_spec/qa/701/screenshots/4003_scenario9_redirect.png` — landed on /projects/qa-fixture-project after ?project= handoff
- `.code_my_spec/qa/701/screenshots/4003_scenario10_fallback.png` — projects list on unknown project ID

## Issues

### QA plan misidentifies local app database as shared Postgres

#### Severity
MEDIUM

#### Scope
QA

#### Description
The QA plan and brief assume the local app at port 4003 shares the Postgres `code_my_spec_dev` database with the hosted app at port 4000. In fact, the running IEx session for port 4003 uses `MIX_ENV=dev_cli`, which configures the Cloak-encrypted SQLite database at `~/.codemyspec/cli.db`. All `mix run` seed commands (which default to `MIX_ENV=dev`) modify Postgres and have no effect on the local app's actual data.

To seed the local (SQLite) side, use `MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs`. However, this currently fails if port 4003 is already running because `--no-halt` mode occupies the port. The workaround during this QA run was to manipulate SQLite directly via the `sqlite3` CLI, being careful not to store raw bytes in the Cloak-encrypted token columns (this caused a page crash).

The QA plan's Seeds section should document the SQLite DB path (`~/.codemyspec/cli.db`) and note that `MIX_ENV=dev_cli` is required for the local app's seed data. The brief template should also warn that the encrypted token columns cannot be set via direct SQL; use `MIX_ENV=dev_cli mix run` or the auth flow instead.

### auth_status endpoint reports expired tokens as authenticated

#### Severity
LOW

#### Scope
APP

#### Description
`GET /api/bootstrap/auth/status` uses `OAuthClient.get_active_client_user()` directly, which returns the most recently updated client_user with a non-nil `oauth_token`, WITHOUT checking whether the token is expired. This means the endpoint can report `authenticated: true` with `email: johns10@gmail.com` even when the actual token is expired and `OAuthClient.authenticated?()` (which does check expiry) returns false.

Reproduced by setting `oauth_expires_at` to a past date in SQLite while leaving `oauth_token` non-null. The LiveView correctly shows `auth-rung[data-state="active"]` (because it uses `OAuthClient.authenticated?()`), but `curl /api/bootstrap/auth/status` returns `{"email":"johns10@gmail.com","authenticated":true}`.

This creates misleading state for any tool that relies on the API endpoint to confirm auth status. The fix is to add an expiry check in `auth_status` similar to `OAuthClient.authenticated?()`.

### cli_qa_seeds.exs cannot run while local app occupies port 4003

#### Severity
LOW

#### Scope
QA

#### Description
`MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs` fails with `:eaddrinuse` when the local Phoenix server is already running on port 4003, because `dev_cli` still starts the `CodeMySpecLocalWeb.Endpoint` during `Application.start`. The seed script has no way to run in isolation without the full application boot sequence.

Options to fix: (1) Add a `--no-start` compatible path in the seed script, (2) gate the endpoint start on an environment variable like `NO_ENDPOINT=true`, or (3) document that seeds must be run before starting the dev_cli server. For now, direct SQLite manipulation (`sqlite3 ~/.codemyspec/cli.db`) is the workaround.
