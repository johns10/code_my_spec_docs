# Qa Story Brief

## Tool

web (Vibium MCP browser tools against `http://127.0.0.1:4000`)

The magic-link auth flow is a LiveView + controller surface on the `:browser` pipeline. All scenarios navigate to the running app, submit forms, and assert on page state and URL.

## Auth

No pre-existing auth required. Each scenario creates or reuses the fresh user `qa-601-magic-test@codemyspec.local` registered via the registration form.

**Registration flow:**
1. Navigate to `http://127.0.0.1:4000/users/register`
2. Fill `input[type='email']` with `qa-601-magic-test@codemyspec.local`
3. Click `button` ("Email me a login link")
4. Navigate to `http://127.0.0.1:4000/dev/mailbox`
5. Get `href` from `a[href*='log-in']` — replace `https://dev.codemyspec.com` with `http://127.0.0.1:4000`
6. Navigate to the local token URL

**Login magic-link flow (second link):**
1. Navigate to `http://127.0.0.1:4000/users/log-in`
2. Fill `@e13` (magic-link form email input) with the registered email
3. Click `@e14` ("Log in with email →")
4. Navigate to `/dev/mailbox` and grab the new token URL
5. Navigate to the local token URL

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

Run to ensure db is healthy. The magic-link scenarios use a fresh user `qa-601-magic-test@codemyspec.local` — no seed entry required for this user.

## What To Test

### Scenario 1 — Magic link click logs in directly with no intermediate screen (criterion 5489)

1. Navigate to `http://127.0.0.1:4000/users/register`
2. Register `qa-601-magic-test@codemyspec.local` via magic link form
3. Screenshot the "Check your email" confirmation page
4. Navigate to `/dev/mailbox` and get the magic link URL
5. Navigate to the local token URL (replacing dev.codemyspec.com with 127.0.0.1:4000)
6. Assert the final URL is `/app` (302 redirect, no intermediate screen)
7. Assert the flash message "User confirmed successfully." is visible
8. Assert the sidebar shows the logged-in email

### Scenario 2 — Successful magic link auth redirects to /app (criterion 5490)

Verified as part of Scenario 1. After following the magic link token URL, assert:
- Final URL is exactly `http://127.0.0.1:4000/app`

### Scenario 3 — Session persists across live_session boundaries (fix from c7b2c6c6)

1. After magic link login (from Scenario 1), navigate to `http://127.0.0.1:4000/app/users/settings`
2. Assert the URL stays at `/app/users/settings` (no redirect to log-in)
3. Assert the user email appears on the settings page
4. This confirms `remember_me: "true"` is forced so the persistent cookie survives cross-boundary navigation

### Scenario 4 — Repeated magic link auth is idempotent (criterion 5491)

1. From the logged-in state (or after navigating away), go to `http://127.0.0.1:4000/users/log-in`
2. Request a second magic link for `qa-601-magic-test@codemyspec.local` via the top magic-link form
3. Get the new token URL from `/dev/mailbox`
4. Navigate to the new local token URL
5. Assert final URL is `/app`
6. Assert the user is logged in (email in sidebar)
7. Navigate to `/app/users/settings` and assert 200 (URL stays at settings, not redirected)

### Scenario 5 — Used/invalid magic link does not log in (criterion 5492)

1. Try to use the first (already-used) magic link token URL again
2. Assert the final URL is `/users/log-in` (redirect)
3. Assert the flash error "The link is invalid or it has expired." is visible
4. Assert no session token is set (user is not logged in)
5. Confirm with `curl -sv` that the 302 redirect cookie contains only the flash message, not a `user_token`

## Result Path

`.code_my_spec/qa/601/result.md`
