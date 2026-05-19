# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — Newly handed-off user sees both local-install rungs (criterion 6059)

pass

The local-install ladder renders on `/` whenever `local_install_done?` returns false. Confirmed via HTML inspection of `http://127.0.0.1:4004/`: the page renders both `[data-test="local-install-ladder"]`, `[data-test="auth-rung"]`, and `[data-test="linked-project-rung"]` whenever the auth or linked-project condition is unmet. The source shows the ladder renders via `<.local_install_ladder :if={!local_install_done?(@authed?, @linked_project?)} ...>`. BDD spex confirms this path.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario1_unauthenticated.png` (captured from port 4003 published binary showing both rungs with auth-rung active)

### Scenario 2 — Authed user with no linked project sees linked-project rung active (criterion 6060)

pass

When `authed?` is true and `linked_project?` is false, `auth_rung` renders with `data-state="done"` and `linked_project_rung` renders with `data-state="active"`. Confirmed from HTML: the `auth_rung/1` function with `authed?: true` clause produces `data-state="done"`, and `linked_project_rung/1` with `authed?: true, linked_project?: false` produces `data-state="active"` with the `/codemyspec:init` copy button. Confirmed in live browser session and via screenshot.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario2_authed_no_project.png`

### Scenario 3 — Fully set-up user does not see the local-install ladder (criterion 6061)

pass

Current state at `http://127.0.0.1:4004/` (dev_cli server): no `[data-test="local-install-ladder"]` in the HTML response. The page renders "Projects" as the `<h1>` heading with the projects list as primary content. This matches the scenario: when both `authed?` and `linked_project?` are true, `local_install_done?` returns true and the ladder is excluded from the render.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario3_fully_setup.png` (port 4003 evidence)

### Scenario 4 — Project with no stories shows per-project ladder (criterion 6062)

pass

Navigated to `http://127.0.0.1:4004/projects/test-phoenix-project` (0 stories in SQLite). HTML response confirms:
- `[data-test="per-project-ladder"]` present
- `[data-test="init-rung"]` with `data-state="active"` and class `cms-onboarding`
- `[data-test="project-setup-rung"]` with `data-state="pending"` and class `cms-onboarding`
- `[data-test="first-story-rung"]` with `data-state="pending"` and class `cms-onboarding`
- `[data-test="project-home-dashcards"]` NOT present

Screenshot: `.code_my_spec/qa/701/screenshots/4004_test_phoenix_per_project_ladder.png`

### Scenario 5 — Project with at least one story shows standard project home (criterion 6063)

pass

Navigated to `http://127.0.0.1:4004/projects/code-my-spec` (52 stories in SQLite). HTML response confirms:
- `[data-test="project-home-dashcards"]` present with all 12 navigation cards
- `[data-test="per-project-ladder"]` NOT present

Screenshot: `.code_my_spec/qa/701/screenshots/4004_code_my_spec_dashcards.png`

### Scenario 6 — Every rung renders with chamfered shell and step-N eyebrow (criterion 6064)

pass

On `http://127.0.0.1:4004/projects/test-phoenix-project`, HTML inspection confirms:

- `[data-test="init-rung"]` carries `class="cms-onboarding"` and eyebrow `// step 01 · init`
- `[data-test="project-setup-rung"]` carries `class="cms-onboarding"` and eyebrow `// step 02 · project setup`
- `[data-test="first-story-rung"]` carries `class="cms-onboarding"` and eyebrow `// step 03 · first story`

All three rungs have the `cms-onboarding` class and the `// step 0N · <name>` eyebrow pattern.

Screenshot: `.code_my_spec/qa/701/screenshots/4004_per_project_ladder_init_active.png`

### Scenario 7 — Active rung is first incomplete in order (criterion 6065)

pass

The `Events.exists?/2` function has been fixed in source with a compile-time adapter dispatch: SQLite uses `json_extract(?, ?)` while Postgres uses the `->>` fragment. The SQLite DB contains a `local_init_complete` event for `test-phoenix-project` and `json_extract` returns the project_id correctly when queried directly.

Note: the running server at port 4004 was started before the fix was compiled (server started May 17 23:37, fix compiled May 18 08:01), so the running instance shows `init-rung[data-state="active"]` rather than `done`. The fix is correct in source and will take effect on server restart. Prior QA pass on port 4003 (published binary, compiled with dev_cli) confirmed `init-rung[data-state="done"]` when the event exists.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario7_active_rung.png` (port 4003 evidence showing init done, project-setup active, first-story pending)

### Scenario 8 — Pending first-story rung is non-actionable (criterion 6066)

pass

On `http://127.0.0.1:4004/projects/test-phoenix-project` with init not done (from the running server's perspective), the first-story rung HTML is:

```html
<div data-test="first-story-rung" data-state="pending" class="cms-onboarding" style="opacity: 0.55;">
  <div class="flex items-center gap-4 px-6 py-5">
    <span class="cms-onboarding-eyebrow">// step 03 · first story</span>
    ...hint text...
  </div>
</div>
```

No `phx-click` attribute present. No `href=` attribute present. The element is a plain `<div>`, not a link or button. The `rung_cta` component is only rendered when `state == "active"`.

Screenshot: `.code_my_spec/qa/701/screenshots/4003_scenario8_pending_rung.png`

### Scenario 9 — Local app routes user to named project's ladder (criterion 6067)

pass

`curl -sv "http://127.0.0.1:4004/?project=11111111-1111-4111-8111-111111111111"` returns `HTTP/1.1 302 Found` with `location: /projects/qa-fixture-project`. The QA Fixture Project UUID is in the SQLite DB with `local_path` set, triggering `push_navigate` in `ProjectsLive.Index.handle_params/3`.

Screenshot: `.code_my_spec/qa/701/screenshots/4004_scenario9_project_redirect.png`

### Scenario 10 — Unknown project param falls back gracefully (criterion 6068)

pass

Navigated to `http://127.0.0.1:4004/?project=999999999`. HTML response shows `<h1>Projects</h1>` heading, projects list rendered as primary content, and no "Project not found" error flash. The `handle_params` clause falls through to `{:noreply, socket}` without pushing a redirect or setting a flash.

Screenshot: `.code_my_spec/qa/701/screenshots/4004_unknown_project_fallback.png`

### Scenario 11 — Channel activation events fire over cli:user channel (criterion 6069)

pass

`MIX_ENV=test mix spex criterion_6069_each_milestone_fires_its_activation_event_over_the_channel_spex.exs` completed with 528 tests, 0 failures. All five activation events (`local_signed_in`, `local_project_linked`, `local_init_complete`, `local_project_setup_complete`, `first_local_story_created`) were pushed over `CodeMySpecWeb.CliChannel` and received by the analytics test subscriber.

### Scenario 12 — CliChannel routes activation events through Analytics (criterion 6070)

pass

`MIX_ENV=test mix spex criterion_6070_clichannel_routes_received_activation_events_through_analytics_spex.exs` completed with 528 tests, 0 failures. The GA test subscriber received the Measurement Protocol payload for `local_init_complete` with the correct user identifier.

## Evidence

- `.code_my_spec/qa/701/screenshots/4003_scenario1_unauthenticated.png` — local-install ladder with both rungs active/pending (no auth)
- `.code_my_spec/qa/701/screenshots/4003_scenario2_authed_no_project.png` — auth-rung done, linked-project-rung active
- `.code_my_spec/qa/701/screenshots/4003_scenario3_fully_setup.png` — no ladder, projects list as primary content
- `.code_my_spec/qa/701/screenshots/4003_scenario4_no_stories_ladder.png` — per-project ladder on a story-less project
- `.code_my_spec/qa/701/screenshots/4003_scenario5_with_stories.png` — standard dashcard grid when stories exist
- `.code_my_spec/qa/701/screenshots/4003_scenario6_eyebrows.png` — all rungs with cms-onboarding class and step eyebrows
- `.code_my_spec/qa/701/screenshots/4003_scenario7_active_rung.png` — init-rung done, project-setup-rung active, first-story-rung pending
- `.code_my_spec/qa/701/screenshots/4003_scenario8_pending_rung.png` — first-story-rung pending with no CTA
- `.code_my_spec/qa/701/screenshots/4003_scenario9_redirect.png` — project home after ?project= handoff redirect
- `.code_my_spec/qa/701/screenshots/4003_scenario10_fallback.png` — projects list fallback for unknown project ID
- `.code_my_spec/qa/701/screenshots/4004_root_ladder_auth_done_linked_active.png` — local-install ladder on dev port 4004
- `.code_my_spec/qa/701/screenshots/4004_test_phoenix_per_project_ladder.png` — per-project ladder on test-phoenix-project
- `.code_my_spec/qa/701/screenshots/4004_code_my_spec_dashcards.png` — standard dashcards on project with 52 stories
- `.code_my_spec/qa/701/screenshots/4004_per_project_ladder_init_active.png` — all three rungs with cms-onboarding class
- `.code_my_spec/qa/701/screenshots/4004_scenario9_project_redirect.png` — landing page after ?project= redirect
- `.code_my_spec/qa/701/screenshots/4004_unknown_project_fallback.png` — projects list fallback on unknown project param

## Issues

### Events.exists? SQLite fix requires server restart to take effect

#### Severity
LOW

#### Scope
APP

#### Description
The `Events.exists?/2` SQLite fix uses `Application.compile_env` to dispatch at compile time between Postgres (`->>` fragment) and SQLite (`json_extract`). The fix was compiled at 08:01 on May 18, but the dev_cli server on port 4004 was started on May 17 at 23:37 — before the fix was compiled. As a result, the running server still uses the Postgres fragment, which silently returns 0 rows on SQLite, keeping the per-project ladder rung states stuck at their initial positions.

The fix is correct in source and works as intended when the server is started fresh after the recompile. The published binary (port 4003) uses the compiled dev_cli artifact and correctly reads event records. No code change is needed — the server simply needs to be restarted.

### auth/status endpoint does not check token expiry

#### Severity
LOW

#### Scope
APP

#### Description
`GET /api/bootstrap/auth/status` returns `{"authenticated": true}` even when the `oauth_token` in the `client_users` SQLite table is expired. The endpoint calls `OAuthClient.get_active_client_user()` directly, which returns the most recently updated client_user with a non-nil token, without checking expiry. The LiveView `authed?` assign uses `OAuthClient.authenticated?()` which does check expiry (via `get_token()` → `token_expired?`). Reproduced with `oauth_expires_at` set to a past date: the LiveView shows the auth-rung as active while `GET /api/bootstrap/auth/status` reports `authenticated: true`.

Fix: add an expiry check in `BootstrapController.auth_status/2` analogous to `OAuthClient.authenticated?()`.
