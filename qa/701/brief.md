# Qa Story Brief

Story 701 — Local app onboarding guides me from sign-in to my first story.

## Tool

web (Vibium MCP browser tools for all LiveView routes on port 4003)

## Auth

Local app (port 4003) uses no user auth — `LocalOnly` plug accepts loopback
connections directly. Just navigate to `http://127.0.0.1:4003/`.

Auth state for the local-install ladder comes from the `client_users` table in
the Postgres DB. The `OAuthClient.authenticated?()` check reads the most recent
`client_user` row and validates the token is not expired.

- Unauthenticated state (for "newly handed-off user"): no client_user row with a
  valid (non-expired) token. The existing `client_users` row has an expired token
  (2026-04-20), so the app reads as unauthenticated by default.
- Authenticated state: requires a `client_users` row with a future `oauth_expires_at`
  and a non-null `oauth_token`. Create one for the test scenario via the Elixir shell:
  `mix run -e 'CodeMySpec.Repo.insert!(%CodeMySpec.ClientUsers.ClientUser{id: 99, email: "qa@codemyspec.local", oauth_token: "qa-fake-token-valid", oauth_expires_at: DateTime.add(DateTime.utc_now(), 30, :day) |> DateTime.truncate(:second)})'`

Channels/analytics tests (criteria 6069, 6070) exercise the hosted `CliChannel`
over WebSocket — these require joining the hosted server's `cli:user:<id>` channel.
Those scenarios are not exercisable via Vibium alone and are assessed via
`mix test test/spex/701_*` output.

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

The QA fixture project (`11111111-1111-4111-8111-111111111111`, name "QA Fixture
Project", local_path=/Users/johndavenport/Documents/github/code_my_spec) is
established. Project slug is `qa-fixture-project`.

For the "authed + linked project" scenario, the project's `client_user_id` must
match the active client_user's `id`. Update it:

```
mix run -e '
client_user = CodeMySpec.Repo.get(CodeMySpec.ClientUsers.ClientUser, 99)
proj = CodeMySpec.Repo.get(CodeMySpec.Projects.Project, "11111111-1111-4111-8111-111111111111")
proj |> Ecto.Changeset.change(client_user_id: client_user.id) |> CodeMySpec.Repo.update!()
'
```

For the "project with stories" scenario, insert a story via the hosted port 4000
UI (log in as qa@codemyspec.local / qa-password-123! and create a story) or use
the iex shell.

## What To Test

### Scenario 1 — Newly handed-off user sees both local-install rungs (criterion 6059)
- Navigate to `http://127.0.0.1:4003/` with no valid client_user token (default state)
- Expected: `[data-test="local-install-ladder"]` is visible
- Expected: `[data-test="auth-rung"]` is present in the ladder
- Expected: `[data-test="linked-project-rung"]` is present in the ladder
- Capture screenshot: `4003_scenario1_unauthenticated.png`

### Scenario 2 — Authed user with no linked project sees only linked-project rung active (criterion 6060)
- Create a fresh client_user with a valid token (see Seeds section)
- Navigate to `http://127.0.0.1:4003/`
- Expected: `[data-test="auth-rung"][data-state="done"]` — auth rung is done
- Expected: `[data-test="linked-project-rung"][data-state="active"]` — linked-project rung is active
- Capture screenshot: `4003_scenario2_authed_no_project.png`

### Scenario 3 — Fully set-up user does not see the local-install ladder (criterion 6061)
- Set `client_user_id` on the QA project to match the valid client_user (see Seeds)
- Navigate to `http://127.0.0.1:4003/`
- Expected: `[data-test="local-install-ladder"]` is NOT rendered
- Expected: page has an `h1` heading and the text "Projects"
- Capture screenshot: `4003_scenario3_fully_setup.png`

### Scenario 4 — Project with no stories shows per-project ladder (criterion 6062)
- Navigate to `http://127.0.0.1:4003/projects/qa-fixture-project`
- Expected: `[data-test="per-project-ladder"]` is present
- Expected: `[data-test="init-rung"]`, `[data-test="project-setup-rung"]`, and `[data-test="first-story-rung"]` are all present
- Expected: `[data-test="project-home-dashcards"]` is NOT present
- Capture screenshot: `4003_scenario4_no_stories_ladder.png`

### Scenario 5 — Project with at least one story shows standard project home (criterion 6063)
- Add a story to the QA project (use hosted UI or iex)
- Navigate to `http://127.0.0.1:4003/projects/qa-fixture-project`
- Expected: `[data-test="project-home-dashcards"]` is present
- Expected: `[data-test="per-project-ladder"]` is NOT present
- Capture screenshot: `4003_scenario5_with_stories.png`

### Scenario 6 — Every rung renders with chamfered shell and step-N eyebrow (criterion 6064)
- Navigate to `http://127.0.0.1:4003/projects/qa-fixture-project` (no stories state)
- For each rung: check element `[data-test="<rung>"].cms-onboarding` exists
- Check `[data-test="init-rung"]` contains "// step 01"
- Check `[data-test="project-setup-rung"]` contains "// step 02"
- Check `[data-test="first-story-rung"]` contains "// step 03"
- Capture screenshot: `4003_scenario6_eyebrows.png`

### Scenario 7 — Active rung is the first incomplete in order (criterion 6065)
- Insert a `local_init_complete` event for the QA project in the events table
- Navigate to `http://127.0.0.1:4003/projects/qa-fixture-project`
- Expected: `[data-test="init-rung"][data-state="done"]`
- Expected: `[data-test="project-setup-rung"][data-state="active"]`
- Expected: `[data-test="first-story-rung"][data-state="pending"]`
- Capture screenshot: `4003_scenario7_active_rung.png`

### Scenario 8 — Pending first-story rung is non-actionable (criterion 6066)
- Navigate to `http://127.0.0.1:4003/projects/qa-fixture-project` with init NOT done
- Expected: `[data-test="first-story-rung"][data-state="pending"]`
- Expected: first-story rung HTML contains no `phx-click` attribute and no `href=`
- Capture screenshot: `4003_scenario8_pending_rung.png`

### Scenario 9 — Local app routes user to named project's ladder (criterion 6067)
- Navigate to `http://127.0.0.1:4003/?project=11111111-1111-4111-8111-111111111111`
- Expected: browser redirects to `http://127.0.0.1:4003/projects/qa-fixture-project`
- Note: project must have `local_path` set AND the project must be "linked" (has local_path)
- Capture screenshot: `4003_scenario9_redirect.png`

### Scenario 10 — Missing or unknown project query param falls back (criterion 6068)
- Navigate to `http://127.0.0.1:4003/?project=999999999`
- Expected: projects list renders (has "Projects" text)
- Expected: no "Project not found" error flash
- Capture screenshot: `4003_scenario10_fallback.png`

### Scenario 11 — Channel activation events (criteria 6069, 6070)
- These are unit/integration layer tests exercised via `mix test`
- Run: `mix test test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6069_each_milestone_fires_its_activation_event_over_the_channel_spex.exs --trace`
- Run: `mix test test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6070_clichannel_routes_received_activation_events_through_analytics_spex.exs --trace`
- Report pass/fail and any output

## Setup Notes

The local app at port 4003 shares the same Postgres DB as the hosted app at
port 4000. The `client_users` table is in Postgres, not SQLite. `OAuthClient`
reads from Postgres regardless of which endpoint you're on.

The `any_linked_project_for_client_user?` check requires both:
1. A `client_users` row with a valid (non-expired) token
2. A `projects` row with `local_path` set AND `client_user_id` matching the client user

For testing the "authed + no linked project" state, create a fresh client_user
with a valid token but do NOT set `client_user_id` on any project.

For the "init done" rung state tests, use `CodeMySpec.Events.record/2` to insert
a `local_init_complete` event with `project_id: "11111111-1111-4111-8111-111111111111"`.

## Result Path

`.code_my_spec/qa/701/result.md`
