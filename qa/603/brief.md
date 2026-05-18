# Qa Story Brief

Story 603 — Onboarding lives at /app and reveals the next setup step.

## Tool

web

## Auth

Password login via Vibium at http://localhost:4000/users/log-in.

Use the password form (bottom form on the page, action `/users/log-in`). The page has two stacked forms — scope to `form[action="/users/log-in"]` to disambiguate.

Credentials (from QA seed script):
- Email: `qa@codemyspec.local`
- Password: `qa-password-123!`

The QA seed creates this user on first run. After login, the browser session cookie is established and all subsequent Vibium navigations are authenticated.

## Seeds

Run before testing to ensure the QA user exists:

```
mix run priv/repo/qa_seeds.exs
```

The seed creates:
- User `qa@codemyspec.local` / `qa-password-123!`
- Account with slug `qa-account`
- Project `QA Fixture Project` (id `11111111-1111-4111-8111-111111111111`)

For testing the zero-account state (AC1/AC4-zero-account), a separate user with no accounts is needed. Use the app's registration flow at `/users/register` to create a fresh user, or check if the QA user can have its account removed. The QA seed user has an account, so AC1 testing requires either a new registration or resetting state.

For AC2 (account but no projects), login as the QA user if the fixture project has been deleted, or register a fresh user and create an account via /app.

For AC3/AC5/AC6, login as the QA user (account + project exists).

## What To Test

### AC1 — /app renders the create-account form when user has zero accounts

1. Register a fresh user at `http://localhost:4000/users/register`
2. Login as that user
3. Navigate to `http://localhost:4000/app`
4. Assert: `form#account_form` is present on the page
5. Assert: `form#project_form` is NOT present

### AC2 — /app renders the project-name form when user has an account but zero projects

1. From AC1's zero-account state, submit the account creation form with a name (e.g. "My Account")
2. After account creation, navigate to `http://localhost:4000/app`
3. Assert: `form#project_form` is present
4. Assert: `form#account_form` is NOT present

### AC3 — /app renders the primary app view when both account and project exist

1. Login as `qa@codemyspec.local` (has account + project from seed)
2. Navigate to `http://localhost:4000/app`
3. Assert: neither `form#account_form` nor `form#project_form` is present
4. Assert: page contains "Overview" text

### AC4 — Routes redirect to /app when user lacks account or project

Two sub-scenarios:

**4a — Zero-account user visiting account-required route:**
1. Login as fresh user with no accounts
2. Navigate to `http://localhost:4000/app/projects`
3. Assert: redirected to `/app`

**4b — User with account but no projects visiting project-required route:**
1. Login as user with account but no projects (from AC2 state)
2. Navigate to `http://localhost:4000/app/issues`
3. Assert: redirected to `/app`

### AC5 — Valid project name creates project, sets active, advances to primary view

1. Login as user with account but no projects (from AC2 state)
2. Navigate to `http://localhost:4000/app` — project-name form visible
3. Fill `form#project_form` name input with "Test Project"
4. Submit the form
5. Assert: redirected to `/app` after submission
6. Assert: fresh load of `/app` shows "Overview", not `form#project_form`

### AC6 — Empty project name re-renders form with validation errors

1. Login as user with account but no projects
2. Navigate to `http://localhost:4000/app` — project-name form visible
3. Clear the name field and submit with empty value
4. Assert: no redirect occurs — still on `/app` with `form#project_form` present
5. Assert: validation error message appears on the form

## Result Path

`.code_my_spec/qa/603/result.md`
