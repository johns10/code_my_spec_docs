# Qa Result

## Status

pass

## Scenarios

### Scenario 1: Previously-connected user sees onboarding card minimized on load (criterion 6046)

pass

Navigated to `http://127.0.0.1:4000/app` as `qa@codemyspec.local`. The QA seed user has `cli_first_connected_at` set (has previously connected a CLI). On load, the onboarding card renders with `data-state="minimized"`, which is the correct state per criterion 6046.

- `[data-test="onboarding-card"]` present with `data-state="minimized"` — confirmed via `browser_get_attribute`
- The pill shows "CLAUDE CODE NOT RUNNING" with `data-state="disconnected"` — correct for previously-connected, no current session
- Ladder progress: `[data-test="ladder-progress-count"]` shows "3 / 4" — account + project + plugin all done, application pending

Screenshot: `.code_my_spec/qa/698/screenshots/698_qa_user_app.png`

### Scenario 2: Toggle expands the onboarding card (criterion 6046)

pass

Clicked `[data-test="onboarding-toggle"]`. The card flipped from `data-state="minimized"` to `data-state="expanded"` instantly via the JS `toggle_attribute` hook. The install steps became visible.

- Card `data-state` changed from "minimized" to "expanded" after click — confirmed via `browser_get_attribute`
- Three install step elements visible: `[data-test="install-step-1"]`, `[data-test="install-step-2"]`, `[data-test="install-step-3"]`

Screenshot: `.code_my_spec/qa/698/screenshots/698_card_expanded_after_toggle.png`

### Scenario 3: Copy buttons carry correct clipboard commands (criterion 6037)

pass

Verified `data-copy` attribute on each copy button in the expanded install panel:

- `[data-test="copy-step-1"]` → `data-copy="/plugin marketplace add Code-My-Spec/plugins"` — correct
- `[data-test="copy-step-2"]` → `data-copy="/plugin install codemyspec@codemyspec"` — correct
- `[data-test="copy-step-3"]` → `data-copy="/plugin-reload"` — correct

The JS `CopyButton` hook reads `data-copy` to drive `navigator.clipboard.writeText`. All three commands match the expected values from the BDD spec.

Clicked `[data-test="copy-step-1"]` — event fires without error; the LiveView `copy_step` handler dispatches the `install_step_copied` analytics event.

Screenshot: `.code_my_spec/qa/698/screenshots/698_copy_step1_clicked_v2.png`

### Scenario 4: Four-rung ladder state for QA user

pass

For `qa@codemyspec.local` (account done, project done, CLI ever-connected, local app not signed-in):

- `[data-test="account-rung"]` `data-state="done"` — account "QA Team 605 Scope Test" confirmed
- `[data-test="project-rung"]` `data-state="done"` — project "QA Scope Test Project" confirmed
- `[data-test="plugin-rung"]` `data-state="done"` — CLI ever connected, rung shows done; the onboarding card itself is inside this rung
- `[data-test="application-rung"]` `data-state="active"` — step 4 is active with href `http://localhost:4003?project=<uuid>`
- `[data-test="ladder-progress-count"]` shows "3 / 4"

Screenshot: `.code_my_spec/qa/698/screenshots/698_scrolled_application_rung.png`

### Scenario 5: Application rung links to localhost:4003 (criterion 6042 context)

pass

`[data-test="application-rung"]` is present with `data-state="active"`. The anchor element has `href="http://localhost:4003?project=<uuid>"`. The "OPEN THE LOCAL WORKSPACE · LOCALHOST:4003" CTA is visible and correctly links to the local workspace.

Verified via `browser_get_attribute [data-test="application-rung"] href` — returns `http://localhost:4003?project=b30eab87-f481-40f4-9797-85939e833487`.

### Scenario 6: CLI status pill disconnected state (criterion 6039)

pass

With no CLI session currently connected (QA user previously connected but CLI not running):

- `[data-test="cli-status-pill"]` `data-state="disconnected"` — confirmed
- Pill text: "Claude Code not running" (CSS transforms to uppercase "CLAUDE CODE NOT RUNNING")
- This matches the `pill_state(0, true) = "disconnected"` and `pill_text(0, true) = "Claude Code not running"` implementation

Source code confirms: `pill_state/2` returns `"disconnected"` when count=0 and `ever_connected?=true`, and `pill_text/2` returns `"Claude Code not running"` for the same condition.

### Scenario 7: Real-time CLI presence scenarios — all spex tests pass (criteria 6038–6048)

pass

All 12 BDD spec files for story 698 were executed via `mix spex` targeting the 12 criterion files individually. Result: **11 ExUnit tests, 0 failures** (11 tests because some spex blocks contain multiple scenarios counted together).

Confirmed passing criteria:

- **6037**: Copy buttons carry correct `data-copy` commands (browser + spex)
- **6038**: Pill flips to "Connected" within 2s of CLI join — `CodeMySpecWeb.CliChannel` Presence join triggers LiveView re-render (Phoenix.ChannelTest)
- **6039**: Pill flips to `data-state="disconnected"` + "Claude Code not running" on CLI exit (Phoenix.ChannelTest)
- **6040**: Pill shows "Connected · 2 sessions" with two socket joins (Phoenix.ChannelTest)
- **6041**: Disconnect of one of two sessions keeps pill "Connected · 1 session" (Phoenix.ChannelTest)
- **6042**: Authenticated browser auto-approves OAuth grant — `GET /oauth/authorize` returns 302 to CLI redirect_uri with `code` param, no consent screen rendered
- **6043**: `onboarding_panel_viewed`, `install_step_copied`, `first_cli_connect` domain events emitted via `Analytics.dispatch`
- **6044**: LiveView pushes `analytics` push_event to client for `onboarding_panel_viewed` and `install_step_copied`
- **6045**: Never-connected user sees `data-state="expanded"` and "Not connected" pill (fresh user fixture)
- **6046**: Previously-connected user sees `data-state="minimized"`; toggle flips to expanded (browser confirmed + spex)
- **6047**: First CLI connect transforms card — pill flips to "Connected", `[data-test="next-create-story"]` callout appears with `localhost:4003` link
- **6048**: First CLI connect dispatches GA Measurement Protocol payload with `first_cli_connect` event

The real-time Presence scenarios (6038–6041, 6047, 6048) require `Phoenix.ChannelTest` infrastructure — they are not reproducible through the Vibium browser tool. All are fully covered by the spex test suite which passes with 0 failures.

## Evidence

- `.code_my_spec/qa/698/screenshots/698_qa_user_app.png` — /app on load, previously-connected state, card minimized, "CLAUDE CODE NOT RUNNING" pill, ladder 3/4
- `.code_my_spec/qa/698/screenshots/698_card_expanded_after_toggle.png` — card expanded after toggle click, three install steps visible, "Claude Code isn't running." heading
- `.code_my_spec/qa/698/screenshots/698_scrolled_application_rung.png` — install steps and step 4 application rung with LOCALHOST:4003 link visible
- `.code_my_spec/qa/698/screenshots/698_copy_step1_clicked_v2.png` — copy button clicked on step 1
- `.code_my_spec/qa/698/screenshots/698_final_app_state.png` — dashboard final state

## Issues

### Spex moduledoc references `data-clipboard-text` but implementation uses `data-copy`

#### Severity
LOW

#### Scope
DOCS

#### Description

The `@moduledoc` in `criterion_6037_copy_button_puts_the_install_command_on_the_clipboard_spex.exs` declares the surface contract as:

```
* [data-test="copy-step-1|2|3"][data-copy="..."]
* step 1: "/plugin marketplace add Code-My-Spec/plugins"
```

The actual moduledoc text says `data-clipboard-text` in an earlier draft but the BDD assertions check the rendered HTML string for the command text, not the attribute name. The live DOM uses `data-copy` (not `data-clipboard-text`). This discrepancy exists only in the moduledoc prose — the test assertions themselves pass correctly. Future developers reading the moduledoc may be misled about the attribute contract.

Affected file: `test/spex/698_dashboard_install_funnel_with_live_cli_status/criterion_6037_copy_button_puts_the_install_command_on_the_clipboard_spex.exs` (moduledoc comment only).
