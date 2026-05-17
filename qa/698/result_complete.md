# Qa Result

## Status

pass

## Scenarios

### Scenario 1: Dashboard loads with onboarding card in expanded state (never-connected user)

pass

Navigated to `http://127.0.0.1:4000/app` while logged in as `qa@codemyspec.local`. The QA user has `cli_first_connected_at: nil` (never connected), confirmed via `mix run -e`.

- `[data-test="onboarding-card"]` is present and visible
- `data-state="expanded"` — card is correctly expanded for a never-connected user
- `[data-test="cli-status-pill"]` text is "NOT CONNECTED" (CSS uppercase), `data-state="idle"`
- `[data-test="install-step-1"]`, `[data-test="install-step-2"]`, `[data-test="install-step-3"]` are all visible
- `[data-test="ladder-progress-count"]` shows "2 / 4" (account + project done; plugin + application pending)

Maps to criterion 6045.

Screenshot: `.code_my_spec/qa/698/screenshots/698_app_dashboard_initial.png`

### Scenario 2: Copy buttons carry correct clipboard commands

pass

Verified the `data-copy` attribute on each copy button:
- `[data-test="copy-step-1"]` → `data-copy="/plugin marketplace add Code-My-Spec/plugins"`
- `[data-test="copy-step-2"]` → `data-copy="/plugin install codemyspec@codemyspec"`
- `[data-test="copy-step-3"]` → `data-copy="/plugin-reload"`

The JS clipboard hook in `assets/js/app.js` correctly reads `.copy-btn[data-copy]` — no `data-clipboard-text` attribute is used (see Issues for the spex `@moduledoc` discrepancy).

Clicked copy-step-1 and the button text briefly changed to "[ ✓ COPIED ]" confirming the JS hook fires.

Screenshot: `.code_my_spec/qa/698/screenshots/698_copy_step1_clicked.png`

Maps to criterion 6037.

### Scenario 3: Toggle collapses and expands the onboarding card

pass

Clicked `[data-test="onboarding-toggle"]`:
- Card flipped to `data-state="minimized"` — confirmed via `browser_get_attribute`
- Clicked toggle again → card returned to `data-state="expanded"`

The JS `toggle_attribute` hook and the `toggle_onboarding` phx-click event both function correctly.

Screenshot: `.code_my_spec/qa/698/screenshots/698_onboarding_card_minimized.png`

Maps to criterion 6046 (toggle behavior).

### Scenario 4: Four-rung ladder structure and state

pass

For the QA seed user (has account + project, no CLI connect, no local sign-in):
- `[data-test="account-rung"]` has `data-state="done"` — correct
- `[data-test="project-rung"]` has `data-state="done"` — correct
- `[data-test="plugin-rung"]` has `data-state="active"` — correct (CLI never connected)
- `[data-test="application-rung"]` has `data-state="pending"` — correct (CLI not connected yet)
- Ladder progress shows "2 / 4"

Maps to overall feature structure and criterion 6045.

### Scenario 5: Celebrate callout absent before first connect

pass

`[data-test="next-create-story"]` is not present in the DOM before any CLI joins — correct. The celebrate callout is only rendered when `@show_celebrate` is `true`, which is only set by `maybe_celebrate_first_connect/2` when a channel joins.

Maps to criterion 6047 (pre-condition).

### Scenario 6: Application rung link structure

pass

`[data-test="application-rung"]` is present with `data-state="pending"`. The pending state shows the `aria-disabled="true"` div. The link to `localhost:4003` would only appear when the rung is in `active` state (after CLI connects but before local sign-in). Source code at `application_rung/1` confirms the `href` includes `http://localhost:4003` in the `active` clause.

Maps to criterion 6042 (auto-approve path).

### Scenario 7: Real-time presence scenarios (spex test suite)

pass

All 12 story 698 spex files were executed via `mix spex test/spex/698_dashboard_install_funnel_with_live_cli_status/`. All 497 spex tests passed (0 failures), confirming:

- Criterion 6038: Pill flips to "Connected" within 2 seconds of CLI join (Phoenix.ChannelTest)
- Criterion 6039: Pill flips to `data-state="disconnected"` and "Claude Code not running" on CLI exit
- Criterion 6040: Pill shows "Connected · 2 sessions" with two sockets joined
- Criterion 6041: Disconnect of one of two sessions keeps pill "Connected · 1 session"
- Criterion 6042: Authenticated browser auto-approves OAuth grant (302 redirect with `code` param)
- Criterion 6043: Analytics events emitted for `onboarding_panel_viewed`, `install_step_copied`, `first_cli_connect`
- Criterion 6044: LiveView pushes `analytics` event to client with correct name/params
- Criterion 6045: Never-connected user sees `data-state="expanded"` and "Not connected" pill
- Criterion 6046: Previously-connected user sees `data-state="minimized"`; toggle flips to expanded
- Criterion 6047: First CLI connect transforms card — pill flips, `next-create-story` callout appears with `localhost:4003` link
- Criterion 6048: First CLI connect dispatches GA Measurement Protocol payload with `first_cli_connect` event name

These scenarios require the Phoenix ChannelTest harness (server-side) — they are not reproducible through the Vibium browser tool directly.

## Evidence

- `.code_my_spec/qa/698/screenshots/698_login_page.png` — login page initial state
- `.code_my_spec/qa/698/screenshots/698_app_dashboard_initial.png` — `/app` on load, card expanded, "Not connected" pill
- `.code_my_spec/qa/698/screenshots/698_app_dashboard_full.png` — full-page view of dashboard with all four rungs
- `.code_my_spec/qa/698/screenshots/698_onboarding_card_minimized.png` — card after toggle click, `data-state="minimized"`
- `.code_my_spec/qa/698/screenshots/698_copy_step1_clicked.png` — copy button feedback "[ ✓ COPIED ]"
- `.code_my_spec/qa/698/screenshots/698_app_overview_final.png` — final full-page dashboard state

## Issues

### Spex moduledoc references `data-clipboard-text` but implementation uses `data-copy`

#### Severity
LOW

#### Scope
DOCS

#### Description

The `@moduledoc` in `criterion_6037_copy_button_puts_the_install_command_on_the_clipboard_spex.exs` declares the surface contract as:

```
* [data-test="copy-step-1|2|3"][data-clipboard-text="..."]
```

The actual implementation in `overview.ex` uses `data-copy` (not `data-clipboard-text`) on the copy buttons, and `assets/js/app.js` reads `.copy-btn[data-copy]` to drive the clipboard write. The spex assertions check the rendered HTML string and do not specifically validate the attribute name — so tests pass — but the documented surface contract is incorrect and would mislead a future developer trying to add a JS-driven clipboard listener.

Affected file: `test/spex/698_dashboard_install_funnel_with_live_cli_status/criterion_6037_copy_button_puts_the_install_command_on_the_clipboard_spex.exs` (the `@moduledoc` only; the test assertions themselves are correct and pass).
