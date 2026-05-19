# Qa Story Brief

Story 701 — Local app onboarding guides me from sign-in to my first story.

## Tool

web (Vibium MCP browser tools for all LiveView pages on port 4004)

## Auth

No authentication required for the local app. `CodeMySpecLocalWeb` runs on port 4004 with `Plugs.LocalOnly` — it accepts any loopback connection without user credentials. Navigate directly to `http://127.0.0.1:4004/`.

Auth state for the local-install ladder (authed rung) comes from the `client_users` table in the SQLite DB. The `OAuthClient.authenticated?()` check reads the most recent `client_user` row.

## Seeds

Use existing projects in the local SQLite DB:

- `code-my-spec` slug → project has stories (use for "project with stories" scenarios)
- `test-phoenix-project` slug → project with no stories (use for "project without stories" / per-project ladder scenarios)
- `qa-fixture-project` slug → UUID `11111111-1111-4111-8111-111111111111` (use for `?project=<id>` redirect scenario)

Current auth state: signed in as `johns10@gmail.com` (auth rung shows as `done`). No project has `client_user_id` set matching the active client user (linked-project rung shows as `active`).

## What To Test

### Scenario 1 — Newly handed-off user sees both local-install rungs (criterion 6059)
1. Navigate to `http://127.0.0.1:4004/`
2. Verify `[data-test="local-install-ladder"]` is present
3. Verify `[data-test="auth-rung"]` is present
4. Verify `[data-test="linked-project-rung"]` is present
5. Screenshot: `701_01_home_ladder.png`

### Scenario 2 — Authed user with no linked project sees auth done and linked-project active (criterion 6060)
1. Navigate to `http://127.0.0.1:4004/`
2. Verify `[data-test="auth-rung"][data-state="done"]` (user is signed in)
3. Verify `[data-test="linked-project-rung"][data-state="active"]` (no linked project for this user)
4. Screenshot: `701_02_authed_no_linked.png`

### Scenario 3 — Fully set-up user does not see the local-install ladder (criterion 6061)
- Requires SQLite state where both rungs are done. Observe with the current state (if linked_project? becomes true).
- Verify the "Projects" heading is the primary content and `[data-test="local-install-ladder"]` is absent.

### Scenario 4 — Project with no stories shows per-project ladder (criterion 6062)
1. Navigate to `http://127.0.0.1:4004/projects/test-phoenix-project`
2. Verify `[data-test="per-project-ladder"]` is present
3. Verify `[data-test="init-rung"]`, `[data-test="project-setup-rung"]`, `[data-test="first-story-rung"]`
4. Verify `[data-test="project-home-dashcards"]` is NOT present
5. Screenshot: `701_04_per_project_ladder.png`

### Scenario 5 — Project with at least one story shows standard project home (criterion 6063)
1. Navigate to `http://127.0.0.1:4004/projects/code-my-spec`
2. Verify `[data-test="project-home-dashcards"]` is present
3. Verify `[data-test="per-project-ladder"]` is NOT present
4. Screenshot: `701_05_standard_project_home.png`

### Scenario 6 — Every rung renders with chamfered shell and step-N eyebrow (criterion 6064)
1. Navigate to `http://127.0.0.1:4004/projects/test-phoenix-project`
2. Verify each rung carries class `cms-onboarding`
3. Verify eyebrow texts: `// step 01 · init`, `// step 02 · project setup`, `// step 03 · first story`
4. Screenshot: `701_06_rung_eyebrows.png`

### Scenario 7 — Active rung is first incomplete in order (criterion 6065)
1. Observe `test-phoenix-project` with init not done
2. Verify `init-rung[data-state="active"]`, `project-setup-rung[data-state="pending"]`, `first-story-rung[data-state="pending"]`
3. Screenshot: `701_07_rung_states.png`

### Scenario 8 — Pending first-story rung is non-actionable (criterion 6066)
1. On `http://127.0.0.1:4004/projects/test-phoenix-project` with init NOT done
2. Verify `first-story-rung[data-state="pending"]`
3. Inspect HTML: confirm no `phx-click` attribute and no `href=` on pending first-story rung
4. Screenshot: `701_08_pending_first_story.png`

### Scenario 9 — `?project=<id>` routes to named project (criterion 6067)
1. Navigate to `http://127.0.0.1:4004/?project=11111111-1111-4111-8111-111111111111`
2. Verify redirect to `/projects/qa-fixture-project`
3. Screenshot: `701_09_project_redirect.png`

### Scenario 10 — Unknown project ID falls back gracefully (criterion 6068)
1. Navigate to `http://127.0.0.1:4004/?project=999999999`
2. Verify "Projects" heading renders (fallback to projects list)
3. Verify no "Project not found" error flash
4. Screenshot: `701_10_unknown_fallback.png`

### Scenario 11 — Channel activation events fired over cli channel (criteria 6069, 6070)
- These criteria exercise the hosted `CodeMySpecWeb.CliChannel` via Phoenix.ChannelTest (in-process)
- Review source implementation: `lib/code_my_spec_web/channels/cli_channel.ex`
- Verify the `@activation_events` whitelist includes all 5 events and each is dispatched via `Analytics.dispatch/3`

## Result Path

`.code_my_spec/qa/701/`
