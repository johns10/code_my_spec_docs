# Qa Story Brief

## Tool

mix spex (internal controller surface — no browser or HTTP API needed)

## Auth

No authentication required. All spex scenarios use `build_conn()` and `OAuthHelpers` cassettes to simulate OAuth callbacks directly against the test endpoint. No browser session or seed user needed.

## Seeds

No seed scripts required. Each spex scenario generates unique user identities via `System.unique_integer/1` and builds its own OAuth cassettes via `OAuthHelpers.build_google_cassette!/2` and `OAuthHelpers.build_github_cassette!/3`.

## What To Test

Run all six spex files for story 602:

```
mix spex test/spex/602_oauth_registration_logs_the_user_in_via_the_callback/
```

Scenarios covered:

- Criterion 5493: First Google signup creates a user with `confirmed_at` set — verifies redirect lands on `/app` (not a confirmation step) and session resolves to the new user's email on `/app/users/settings`
- Criterion 5494: First Google signup persists the integration row — verifies settings page shows "Disconnect" (not "Connect Google") after OAuth signup
- Criterion 5495: Second Google sign-in is idempotent — same provider sub completes the callback twice; both sessions surface the same email on settings
- Criterion 5496: Same email from a different OAuth provider links to the existing user — Google then GitHub with matching email; both sessions land on the same user
- Criterion 5497: Provider response without an email aborts registration — GitHub callback with empty emails list; no session token set, redirect to `/users/log-in`
- Criterion 5498: Integration save failure does not gate login — Google callback with empty `access_token`; user is still logged in and settings page renders their email

## Result Path

.code_my_spec/qa/602/result.md
