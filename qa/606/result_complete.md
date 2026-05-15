# Qa Result

## Status

pass

## Scenarios

### 5399 — Unauthenticated visitor is redirected to login

**Steps:**
1. `browser_delete_cookies` (clean session).
2. Navigated to `http://localhost:4000/app`.

**Outcome:** PASS. `browser_get_url` returned `http://localhost:4000/users/log-in` — the plug-based `require_authenticated_user` (lib/code_my_spec_web/user_auth.ex:~355) caught the anonymous conn, stashed `/app` in `session[:user_return_to]` via `maybe_store_return_to/1`, and redirected to the login page. Evidence: `screenshots/606_01_5399_anon_redirect.png`.

### 5513 — User with zero accounts sees the create-account form

**Steps:**
1. Registered a fresh user `qa-606-zero-1778817855-40465@codemyspec.local` via `/users/register`.
2. Fetched the magic-link token (`RYB0NUprpR7eaLOBQr27p8AoE9aedPEmIgQ28Tgr57U`) from `/dev/mailbox`.
3. Confirmed via `/users/log-in/<token>`. Browser landed on `/app`.

**Outcome:** PASS. `data-test="account-rung"` rendered with `data-state="active"`, containing the heading "Name your account." and an `input[name="account[name]"]` (placeholder "Acme"). No other rung was active or done — fresh-user onboarding ladder at step 01. Evidence: `screenshots/606_02_5513_account_form_active.png`.

### 5514 — Valid submission creates the account and advances onboarding

**Steps:**
1. Continuing as the same zero-account user on `/app`.
2. Filled `input[name="account[name]"]` with `My QA Account 606`.
3. Clicked `#account_form button[type='submit']`.

**Outcome:** PASS. The LiveView's `handle_event("create_account", ...)` succeeded, set the active account, and `push_navigate`d back to `/app`. After re-mount:
- `data-test="account-rung"` is `data-state="done"`, showing "MY QA ACCOUNT 606" as the value.
- `data-test="project-rung"` is now `data-state="active"` ("Name your first project.").
- URL stayed at `/app`.

DB verification via `mix run` script:
```
user accounts: 1
  - My QA Account 606 (my-qa-account-606)
active_account_id: "57621ed3-09b2-4928-9f28-80289fbcf352"
```

Evidence: `screenshots/606_03_5514_account_created.png`.

### 5516 — Invalid submission re-renders the form with errors

**Steps:**
1. Registered another fresh zero-account user (`qa-606-invalid-1778817933-41669@codemyspec.local`) and confirmed via magic link.
2. On `/app` with the create-account rung active, attempted to submit the form with an empty `account[name]` field.
3. First attempt was blocked by the input's HTML5 `required` attribute (the browser's native validation refused to submit). Stripped the attribute via `browser_evaluate` (`document.querySelector("input[name='account[name]']").removeAttribute('required')`) to let the empty value reach the server.
4. Clicked submit again.

**Outcome:** PASS. URL stayed at `/app`. The form re-rendered with:
- `class="w-full input input-error"` on the empty input
- A new `<p class="mt-1.5 flex gap-2 items-center text-sm text-error">…can't be blank</p>` error message
- `data-test="account-rung"` still `data-state="active"` (not advanced)

DB verification: `Accounts.list_accounts(scope_for_user(...))` returned `0` accounts. No record was persisted. Evidence: `screenshots/606_04_5516_validation_error.png`.

### 5517 — User with accounts but no active selection has the first auto-assigned

**Setup (via `/tmp/qa_606_reset_prefs.exs clear`):**
- Loaded the seeded user `qa@codemyspec.local` (already a member of `Code My Spec` + `QA Second Account` from story 607's setup).
- `Repo.update_all` cleared `active_account_id` and `active_project_id` on `user_preferences`.

**Test steps:**
1. `browser_delete_cookies`, navigate to `/users/log-in`.
2. Logged in via `#login_form_password` with email/password.
3. Navigated to `http://localhost:4000/app`.

**Outcome:** PASS. URL stayed at `/app`. `data-test="account-rung"` is `data-state="done"`, showing "Code My Spec" as the auto-assigned active account. No `input[name="account[name]"]` is present anywhere — the create-account step was completely skipped. The `:require_active_account`-style fallback in `AppLive.Overview.ensure_active_account/1` (lib/code_my_spec_web/live/app_live/overview.ex:48) picked the first account via `Accounts.list_accounts/1` and called `UserPreferences.select_active_account/2`. Evidence: `screenshots/606_05_5517_auto_pick.png`.

### 5518 — Returning user with an active account skips the create-account step

**Setup (via `/tmp/qa_606_reset_prefs.exs set`):**
- Same seeded user, then `UserPreferences.select_active_account/2` set `Code My Spec` as the active account explicitly.

**Test steps:**
1. `browser_delete_cookies`, log in via password form.
2. Navigated to `http://localhost:4000/app`.

**Outcome:** PASS. `data-test="account-rung"` is `data-state="done"` showing "CODE MY SPEC". No `input[name="account[name]"]` is present. The user lands on the onboarding ladder past step 01 (account already provisioned + selected). Evidence: `screenshots/606_06_5518_skip_create.png`.

## Evidence

- `screenshots/606_01_5399_anon_redirect.png` — Anonymous `/app` visit redirected to `/users/log-in`.
- `screenshots/606_02_5513_account_form_active.png` — Zero-account user on `/app` with active create-account rung.
- `screenshots/606_03_5514_account_created.png` — Post-submit, account-rung done and project-rung active.
- `screenshots/606_04_5516_validation_error.png` — Empty submission re-rendered with `input-error` + "can't be blank".
- `screenshots/606_05_5517_auto_pick.png` — Multi-account user with cleared preference, account-rung done after auto-pick.
- `screenshots/606_06_5518_skip_create.png` — Single-active-account user, account-rung done on first render.

## Issues

### HTML5 `required` attribute blocks empty-submission test path

#### Severity

INFO

#### Scope

QA

#### Description

The `input[name="account[name]"]` on `AppLive.Overview`'s create-account form ships with HTML5 `required`. When a tester submits the form blank, the browser's native validation refuses to submit at all — the LiveView `create_account` handler never receives the event, so the server-side `validate_required([:name, :slug])` path in `Account.create_changeset/1` is never exercised through the UI.

This is defense-in-depth (good for real users) but does mean that:
1. A tester following the brief verbatim cannot directly observe the server-side error rendering without first stripping `required` via DevTools or `browser_evaluate`.
2. Future spex/wallaby scenarios for criterion 5516 should either disable HTML5 validation on the form during test (e.g. add `novalidate` attribute under `Mix.env() == :test`) or document the strip-required workaround.

This QA run verified BOTH layers: native `required` blocks the first attempt; after stripping it, the server-side validation correctly re-rendered the form with `input-error` + "can't be blank". Criterion 5516 is satisfied — but the test method to observe it is non-obvious.
