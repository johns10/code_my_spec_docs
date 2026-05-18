# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — Newly registered user sees all four steps in order (criterion 6051)

pass

Logged in as fresh user `qa-700-fresh2@codemyspec.local` (confirmed via magic link, no account, no project, no CLI history). Navigated to `http://127.0.0.1:4000/app`.

All four rungs confirmed present in DOM:
- `[data-test='account-rung']` found — data-state="active", eyebrow "// step 01 · account"
- `[data-test='project-rung']` found — data-state="pending", eyebrow "// step 02 · project"
- `[data-test='plugin-rung']` found — data-state="pending", eyebrow "// step 03 · plugin"
- `[data-test='application-rung']` found — data-state="pending", eyebrow "// step 04 · application"

Page text confirmed document order via `browser_get_text` on `.max-w-2xl`: "// STEP 01 · ACCOUNT" → "// STEP 02 · PROJECT" → "// STEP 03 · PLUGIN" → "// STEP 04 · APPLICATION".

Evidence: `.code_my_spec/qa/700/screenshots/700_new_s1_fresh_user_app.png`

### Scenario 2 — Mid-journey user sees done/active/pending states side by side (criterion 6052)

pass

Advanced fresh user `qa-700-fresh2@codemyspec.local` by creating account "QA 5376 Account" and project "QA Test Project 700 Fresh". After project creation, `/app` shows:
- `[data-test='account-rung'][data-state='done']` — confirmed
- `[data-test='project-rung'][data-state='done']` — confirmed
- `[data-test='plugin-rung'][data-state='active']` — confirmed (first incomplete step for user with account + project but no CLI)
- `[data-test='application-rung'][data-state='pending']` — confirmed

All four states visible simultaneously on one page. Plugin rung shows "Install CodeMySpec" expanded panel.

Evidence: `.code_my_spec/qa/700/screenshots/700_new_s2_midjourney.png`

### Scenario 3 — Account-only user has project as the active step (criterion 6053)

pass

After fresh user created account "QA 5376 Account" (stopping before project creation), `/app` shows:
- `[data-test='account-rung'][data-state='done']` — confirmed
- `[data-test='project-rung'][data-state='active']` — confirmed (first incomplete step)
- `[data-test='plugin-rung'][data-state='pending']` — confirmed
- `[data-test='application-rung'][data-state='pending']` — confirmed
- No other rung carries data-state="active" — confirmed

Evidence: `.code_my_spec/qa/700/screenshots/700_new_s3_account_only.png`

### Scenario 4 — User with all server-side setup done has application as active step (criterion 6054)

pass

The QA seed user `qa@codemyspec.local` has `cli_first_connected_at` already set from a prior real CLI session. On `/app`:
- `[data-test='account-rung'][data-state='done']` — confirmed
- `[data-test='project-rung'][data-state='done']` — confirmed
- `[data-test='plugin-rung'][data-state='done']` — confirmed (class includes "cms-onboarding contents")
- `[data-test='application-rung'][data-state='active']` — confirmed
- No other rung carries data-state="active" — confirmed

Evidence: `.code_my_spec/qa/700/screenshots/700_new_qa_seed_app.png`

### Scenario 5 — Every step renders with chamfered shell and step-N eyebrow (criterion 6055)

pass

Tested across multiple states:

**Fresh user (account active, others pending):** All four `[data-test='*-rung']` elements carry `class="cms-onboarding"` — confirmed for all four rungs via `browser_get_attribute`.

**Account-only user (project active):** `[data-test='project-rung']` has `class="cms-onboarding"` — confirmed.

**Mid-journey (plugin active):** `[data-test='plugin-rung']` has `class="cms-onboarding contents"`. The BDD spex selector `[data-test='plugin-rung'].cms-onboarding` finds the element via `browser_find` — confirmed. The `display: contents` style makes the wrapper box-less but the class is present.

**CLI-connected user (application active):** `[data-test='plugin-rung']` has `class="cms-onboarding contents"` — confirmed present.

Eyebrow texts confirmed in all states: "// step 01 · account", "// step 02 · project", "// step 03 · plugin", "// step 04 · application" appear in correct order in page text.

Note: The prior QA run filed a MEDIUM issue that the plugin rung outer wrapper was missing `cms-onboarding`. That bug has been fixed — the class is now present alongside `contents`. The BDD spex `has_element?` assertion will pass since the element exists in DOM with the class.

Evidence: `.code_my_spec/qa/700/screenshots/700_new_s1_fresh_user_app.png`, `.code_my_spec/qa/700/screenshots/700_new_s2_midjourney.png`

### Scenario 6 — Pending project step renders without a submittable form (criterion 6056)

pass

Fresh user (no account, account rung active): project rung has `data-state="pending"`. Confirmed via `browser_find`:
- `form#project_form` — NOT found in DOM (returned nil)
- `input[name='project[name]']` — NOT found in DOM (returned nil)

The project rung as a pending tile has no submittable form.

Evidence: `.code_my_spec/qa/700/screenshots/700_new_s1_fresh_user_app.png`

### Scenario 7 — Pending application step does not navigate when clicked (criterion 6057)

pass

Fresh user (no account): `[data-test='application-rung']` has `data-state="pending"`. Confirmed:
- `a[data-test='application-rung']` — NOT found (returned nil) — the element is a `<div>`, not an `<a>`
- No href attribute pointing to the local workspace

The rung carries `aria-disabled="true"` and has no clickable link.

Evidence: `.code_my_spec/qa/700/screenshots/700_new_s1_fresh_user_app.png`

### Scenario 8 — Active application step opens local workspace in new tab (criterion 6058)

pass

QA seed user (`qa@codemyspec.local`) with `cli_first_connected_at` set, account+project done, plugin done:
- `a[data-test='application-rung']` found — element is an anchor tag (confirmed via `browser_find` returning `[a]`)
- `href`: `http://localhost:4003?project=b30eab87-f481-40f4-9797-85939e833487` — starts with `http://localhost:4003`
- `target`: `_blank` — confirmed via `browser_get_attribute`
- `rel`: `noopener noreferrer` — contains "noopener" — confirmed

Evidence: `.code_my_spec/qa/700/screenshots/700_new_qa_seed_app.png`

## Evidence

- `.code_my_spec/qa/700/screenshots/700_new_s1_fresh_user_app.png` — fresh user /app: welcome banner, all four rungs in order, account active (with form), project/plugin/application pending (no forms)
- `.code_my_spec/qa/700/screenshots/700_new_s2_midjourney.png` — mid-journey: account+project done, plugin active (expanded install panel), application pending
- `.code_my_spec/qa/700/screenshots/700_new_s3_account_only.png` — account-only user: account done, project active (with project name form), plugin+application pending
- `.code_my_spec/qa/700/screenshots/700_new_qa_seed_app.png` — CLI-connected user (qa@codemyspec.local): account+project+plugin done, application active with anchor href to localhost:4003

## Issues

None
