# Qa Story Brief

## Tool

web (Vibium MCP browser tools — LiveView surface on port 4000)

## Auth

Register a fresh user via `/users/register` — the wizard requires a new user with zero accounts and zero projects. The QA seed user (`qa@codemyspec.local`) already has an account and project and will NOT trigger the wizard.

Steps to authenticate as a fresh user:
1. Navigate to `http://127.0.0.1:4000/users/register`
2. Fill the email input (`input[name="user[email]"]` with placeholder `you@domain.dev`) with a unique email (e.g. `qa-604-fresh-<timestamp>@codemyspec.local`)
3. Click `button` "Email me a login link" — this sends a magic-link email
4. Navigate to `http://127.0.0.1:4000/dev/mailbox` to read the magic-link email
5. Open the Text body section, copy the token URL (beginning with `https://dev.codemyspec.com/users/log-in/<token>`)
6. Replace `dev.codemyspec.com` with `127.0.0.1:4000` and navigate there — lands on `/app` with "User confirmed successfully." flash

No shell auth scripts needed — magic-link registration done entirely in-browser via Vibium.

## Seeds

Run base seeds before testing:

```
mix run priv/repo/qa_seeds.exs
```

No story-specific seed beyond registration of a fresh user (done in-browser during the test).

## What To Test

### Scenario A: Registration and account creation (prerequisite wizard flow)
1. Navigate to `http://127.0.0.1:4000/users/register`
2. Register with unique email `qa-604-fresh-<timestamp>@codemyspec.local`
3. Visit `/dev/mailbox`, grab magic-link token, navigate to `http://127.0.0.1:4000/users/log-in/<token>`
4. Verify lands on `/app` showing the account creation step (step 01 active, 0/4 onboarding)
5. Verify `[data-test="account-rung"][data-state="active"]` is present
6. Verify `[data-test="project-rung"][data-state="pending"]` is present
7. Verify `form#project_form` is NOT present (project form absent when account step active)
8. Fill account name and submit — expect redirect back to `/app` showing project-name form

### Scenario B: Multi-word name title-cases each word and strips spaces (criterion 5375)
1. On the project-name step, fill `input[name="project[name]"]` with `my project`
2. Verify live preview shows "Will be used as module: MyProject"
3. Submit the form
4. Navigate to `/app/projects/{id}/edit`
5. Confirm `input[name="project[module_name]"]` has value `MyProject`

### Scenario C: Active project preference set to new project (criterion 5507)
1. After project creation, navigate to `http://127.0.0.1:4000/app/issues` (`:require_active_project` gated route)
2. Expect: HTTP 200 at `/app/issues` with "No issues found." — no redirect to `/projects/picker`

### Scenario D: User lands on /app after creation with no picker detour (criterion 5508)
1. After submitting the project-name form, confirm URL lands on `/app`
2. Confirm the page shows the wizard at step 03 (plugin) — step 02 marked done as project name
3. No account picker or project picker detour in the path

### Scenario E: Created project scoped to active account (criterion 5505)
1. Navigate to `/app/projects` after project creation
2. Confirm "my project" appears in the account-scoped listing
3. DB confirm: project's `account_id` matches the account created in step 01

## Result Path

`.code_my_spec/qa/604/result.md`

## Setup Notes

The registration page (`/users/register`) uses a magic-link-only flow (no password). The form has `input[name="user[email]"]` with placeholder `you@domain.dev` and a submit button. After submission, user lands at `/users/check-email?email=...`. The magic-link email in dev mailbox has a "Text body" section with the token URL. A login magic link (sent after email confirmation) does NOT use `remember_me: true`, so the session is non-persistent by default — navigate carefully to avoid session loss on cross-live_session boundaries.
