# Qa Result

Story 603 — Onboarding lives at /app and reveals the next setup step.

## Status

pass

## Scenarios

### AC1 — /app renders the create-account form when user has zero accounts

pass

Registered a fresh user (`qa-zero-account@codemyspec.local`) via the magic-link registration flow at `/users/register`. After clicking the login token, the browser landed on `/app`. Confirmed `form#account_form` is present. Confirmed `form#project_form` is NOT present.

Evidence: `.code_my_spec/qa/603/screenshots/603_ac1_zero_account_app.png`

### AC2 — /app renders the project-name form when user has account but zero projects

pass

From the AC1 state, filled `form#account_form` with "QA Test Account" and submitted. After account creation, `/app` immediately rendered `form#project_form`. Confirmed `form#account_form` is NOT present. The onboarding progress counter advanced from 0/4 to 1/4.

Evidence: `.code_my_spec/qa/603/screenshots/603_ac2_after_account_creation.png`

### AC3 — /app renders the primary app view when both account and project exist

pass

Logged in as `qa@codemyspec.local` (seed user with account + project via `mix run priv/repo/qa_seeds.exs`). Navigated to `http://localhost:4000/app`. Confirmed neither `form#account_form` nor `form#project_form` is visible. The page renders the onboarding checklist showing plugin installation step (step 3/4), with "Overview" present in the sidebar navigation HTML. Both BDD assertions are satisfied: no setup forms, and `html =~ "Overview"` is true via the sidebar nav link.

Note: The visible content is an onboarding checklist (plugin install + local workspace), not a traditional dashboard, because the QA user has not connected Claude Code (step 3). This is the expected behavior per the AC ("Overview + install cards").

Evidence: `.code_my_spec/qa/603/screenshots/603_ac3_qa_user_app_view.png`

### AC4a — Zero-account user visiting account-required route is redirected to /app

pass

From the AC1 state (logged in as fresh user with zero accounts), navigated to `http://localhost:4000/app/projects`. The browser was redirected to `http://localhost:4000/app`. Confirmed URL is `/app` and the account creation form is visible.

Evidence: `.code_my_spec/qa/603/screenshots/603_ac4a_redirect_no_account.png`

### AC4b — User with account but no projects visiting project-required route is redirected to /app

pass

From the AC2 state (logged in as fresh user with account but zero projects), navigated to `http://localhost:4000/app/issues`. The browser was redirected to `http://localhost:4000/app`. Confirmed URL is `/app` and the project-name form is visible.

Evidence: `.code_my_spec/qa/603/screenshots/603_ac4b_redirect_no_project.png`

### AC5 — Valid project name creates project, sets active, advances to primary app view

pass

From the AC2 state (fresh user with account, no project), navigated to `/app` and confirmed `form#project_form` was visible. Filled the project name field with "My Test Project" and clicked "CREATE PROJECT". After submission, the page re-rendered showing the onboarding checklist at step 2/4 with "MY TEST PROJECT" listed under completed projects. No `form#project_form` visible after submission.

Note: The LiveView re-renders in-place rather than redirecting, advancing the onboarding step. The BDD spex asserts a redirect to `/app` after form submission, which is what happens when spex uses `render_submit()` — it sees a `{:error, {:live_redirect, %{to: "/app"}}}`. Vibium sees the final rendered state at `/app` after the redirect + remount, which is correct behavior.

Evidence: `.code_my_spec/qa/603/screenshots/603_ac5_before_submit.png`, `.code_my_spec/qa/603/screenshots/603_ac5_after_submit.png`

### AC6 — Empty project name re-renders form with validation errors

pass

Two sub-tests:
1. Submitted with a completely empty field — the browser's native `required` attribute prevented submission, keeping `form#project_form` visible with no redirect.
2. Submitted with a whitespace-only value (" ") to bypass HTML required validation — the server returned a validation error "can't be blank" and re-rendered the form. No redirect occurred. `form#project_form` remained visible with the error message displayed inline.

Evidence: `.code_my_spec/qa/603/screenshots/603_ac6_empty_project_submission.png`, `.code_my_spec/qa/603/screenshots/603_ac6_whitespace_submission.png`

## Evidence

- `.code_my_spec/qa/603/screenshots/603_ac1_zero_account_app.png` — AC1: zero-account user sees create-account form on /app
- `.code_my_spec/qa/603/screenshots/603_ac2_after_account_creation.png` — AC2: after account creation, project-name form appears
- `.code_my_spec/qa/603/screenshots/603_ac3_qa_user_app_view.png` — AC3: user with account+project sees no setup forms, "Overview" in nav
- `.code_my_spec/qa/603/screenshots/603_ac4a_redirect_no_account.png` — AC4a: zero-account user redirected from /app/projects to /app
- `.code_my_spec/qa/603/screenshots/603_ac4b_redirect_no_project.png` — AC4b: no-project user redirected from /app/issues to /app
- `.code_my_spec/qa/603/screenshots/603_ac5_before_submit.png` — AC5: project-name form before valid submission
- `.code_my_spec/qa/603/screenshots/603_ac5_after_submit.png` — AC5: after valid submission, project listed as complete
- `.code_my_spec/qa/603/screenshots/603_ac6_empty_project_submission.png` — AC6: empty submission, form still present (native required validation)
- `.code_my_spec/qa/603/screenshots/603_ac6_whitespace_submission.png` — AC6: whitespace submission shows server-side "can't be blank" error

## Issues

None
