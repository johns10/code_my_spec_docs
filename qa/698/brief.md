# Qa Story Brief

## Tool

web (Vibium MCP browser tools for all LiveView routes on port 4000)

## Auth

Login via the password form at `http://127.0.0.1:4000/users/log-in`:
- Email: `qa@codemyspec.local`
- Password: `qa-password-123!`
- Use the password form (second form on the page), scoped to `form[action="/users/log-in"]`
- Submit with `#login_form_password button` (first button = "Log in and stay logged in")
- After login, navigate to `http://127.0.0.1:4000/app`

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

This creates user `qa@codemyspec.local` / `qa-password-123!`, account `qa-account`, project `QA Fixture Project` (id `11111111-1111-4111-8111-111111111111`).

Note: The QA seed user already has an account (`code-my-spec`) and a project, so when logged in as this user the dashboard will be at step 03 (plugin/CLI install), not step 01 (create account). The `never-connected` vs `previously-connected` pill state depends on whether `cli_first_connected_at` is set on the user record.

## What To Test

### Scenario 1: Dashboard loads and shows onboarding card (never-connected state)
- Navigate to `http://127.0.0.1:4000/app` while logged in
- Assert the page renders with `[data-test="onboarding-card"]` present
- Assert the onboarding card has `data-state="expanded"` (never-connected user)
- Assert the CLI status pill `[data-test="cli-status-pill"]` shows "Not connected"
- Assert `[data-test="install-step-1"]`, `[data-test="install-step-2"]`, `[data-test="install-step-3"]` are visible within the expanded card
- Assert the ladder progress `[data-test="ladder-progress-count"]` reflects correct step count
- Maps to: criterion 6045 (Never-connected user sees the onboarding component expanded)

### Scenario 2: Copy buttons carry correct clipboard commands
- On `/app`, find the copy buttons inside the expanded onboarding card
- Assert `[data-test="copy-step-1"]` has `data-copy` attribute containing `/plugin marketplace add Code-My-Spec/plugins`
- Assert `[data-test="copy-step-2"]` has `data-copy` attribute containing `/plugin install codemyspec@codemyspec`
- Assert `[data-test="copy-step-3"]` has `data-copy` attribute containing `/plugin-reload`
- Note: the spec checks `data-clipboard-text` but the source uses `data-copy` — verify which attribute is actually present
- Maps to: criterion 6037 (Copy button puts the install command on the clipboard)

### Scenario 3: Status pill text and data-state when never connected
- On `/app`, read the full HTML of `[data-test="cli-status-pill"]`
- Assert text content is "Not connected"
- Assert `data-state="idle"` (pill_state for 0 sessions, never connected = "idle")
- Maps to: criterion 6045, 6038 (initial state)

### Scenario 4: Toggle collapses and expands the onboarding card
- On `/app` with card expanded, click `[data-test="onboarding-toggle"]`
- Assert card flips to `data-state="minimized"`
- Click the toggle again
- Assert card flips back to `data-state="expanded"`
- Maps to: criterion 6046 (toggle expand/collapse)

### Scenario 5: Pill state when previously connected (if testable via DB reset)
- This requires setting `cli_first_connected_at` on the user — only possible via the channel join or direct DB manipulation
- Check if the QA user already has `cli_first_connected_at` set (if so, the pill will show "Claude Code not running" instead of "Not connected")
- If already set: assert `data-state="disconnected"` and text "Claude Code not running"
- If not set: assert `data-state="idle"` and text "Not connected"
- Maps to: criterion 6046 (Previously-connected user sees the onboarding component minimized)

### Scenario 6: Four-rung ladder present and correct for QA user
- QA user has account and project, so rungs 1 and 2 should be `data-state="done"`
- Assert `[data-test="account-rung"][data-state="done"]` is present
- Assert `[data-test="project-rung"][data-state="done"]` is present
- Assert `[data-test="plugin-rung"]` is present (active or done depending on CLI history)
- Assert `[data-test="ladder-progress"]` is visible
- Maps to: overall feature structure

### Scenario 7: Application rung links to localhost:4003
- Assert `[data-test="application-rung"]` is present
- If state is "active", assert the `href` contains `localhost:4003`
- Maps to: criterion 6042 (browser auto-approves OAuth grant — the link is the entry)

### Scenario 8: Channel-driven pill update (live presence) — structural check only
- The real-time flip (criterion 6038, 6039) requires joining the Phoenix channel via `Phoenix.ChannelTest`
- In browser-only QA, we cannot directly join a websocket channel the same way a test process does
- Instead: verify the LiveView subscribes to `cli_status:user:<id>` topic by checking page source/socket
- Document that full real-time testing is covered by the spex unit tests (`criterion_6038`, `6039`, `6040`, `6041`, `6047`)
- Capture screenshot as evidence of pill state; note this criterion requires channel test harness for full verification

## Setup Notes

The QA seed user (`qa@codemyspec.local`) already has an account and project set up. The dashboard will show rungs 1 and 2 as "done" and present rung 3 (plugin) as active. The `cli_first_connected_at` field determines whether the pill shows "Not connected" (never connected, `data-state="idle"`) or "Claude Code not running" (previously connected, `data-state="disconnected"`).

The real-time presence scenarios (criteria 6038, 6039, 6040, 6041, 6047) require Phoenix channel test infrastructure (`subscribe_and_join`) which is not available through the Vibium browser tool. Those criteria are covered by the Spex BDD test suite. Browser QA can verify static states and structural correctness.

The copy-button clipboard contract in the source code uses `data-copy` attribute, while the BDD spec references `data-clipboard-text`. This discrepancy should be flagged as a finding.

## Result Path

`.code_my_spec/qa/698/result.md`
