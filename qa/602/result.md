# Qa Result

## Status

pass

## Scenarios

### Scenario 1: Register page renders GitHub and Google OAuth buttons

pass

Navigated to `http://127.0.0.1:4000/users/register` via Vibium. Both "Continue with GitHub" (href `/auth/github/login`) and "Continue with Google" (href `/auth/google/login`) buttons render correctly in the sign-up form. The GitHub button carries `data-registration-method="github"` and the Google button carries `data-registration-method="google"`.

Evidence: `.code_my_spec/qa/602/screenshots/602_register_page.png`

### Scenario 2: Login page renders GitHub and Google OAuth buttons

pass

Navigated to `http://127.0.0.1:4000/users/log-in` via Vibium. Both "Continue with GitHub" and "Continue with Google" buttons render on the login page alongside the magic-link and password forms.

Evidence: `.code_my_spec/qa/602/screenshots/602_actual_login_page.png`

### Scenario 3: GitHub login initiation redirects to GitHub OAuth

pass

`GET /auth/github/login` returns HTTP 302 with `Location: https://github.com/login/oauth/authorize?client_id=Ov23liFpnT7j3bK5OC1L&redirect_uri=https%3A%2F%2Fdev.codemyspec.com%2Fauth%2Fgithub%2Fcallback&response_type=code&scope=user%3Aemail&state=...`. The session cookie is set with `oauth_flow=login`, `oauth_provider=github`, and `oauth_session_params` containing the generated state. Scope is `user:email` (minimal, identity-only — correct for login flow).

### Scenario 4: Google login initiation redirects to Google OAuth

pass

`GET /auth/google/login` returns HTTP 302 with `Location: https://accounts.google.com/o/oauth2/v2/auth?access_type=offline&client_id=657486809717-...&redirect_uri=https%3A%2F%2Fdev.codemyspec.com%2Fauth%2Fgoogle%2Fcallback&response_type=code&scope=openid+email+profile&state=...`. The `access_type=offline` parameter requests a refresh token. Scope is `openid email profile` (correct for identity-only login).

### Scenario 5: Google callback with access_denied error redirects to login

pass

`GET /auth/google/callback?error=access_denied` with a login-flow session cookie (obtained from the initiation redirect) returns HTTP 302 to `/users/log-in`. The controller correctly detects the OAuth error and routes to the login error handler rather than proceeding with token exchange.

### Scenario 6: GitHub callback with access_denied error redirects to login

pass

`GET /auth/github/callback?error=access_denied` with a login-flow session cookie returns HTTP 302 to `/users/log-in`. Same error-handling path as Google.

### Scenario 7: Criterion 5493 — First Google signup creates user with confirmed_at set

pass

Spex scenario verifies that after the Google OAuth callback, the user is redirected to `/app` (not a confirmation-step URL), and a session token is set. The session resolves to the new user's email on `/app/users/settings`.

### Scenario 8: Criterion 5494 — First Google signup persists integration row

pass

Spex scenario verifies the settings page shows "Disconnect" (not "Connect Google") after OAuth signup, confirming the integration row was persisted.

### Scenario 9: Criterion 5495 — Second Google sign-in is idempotent

pass

Spex scenario verifies the same provider `sub` completing the callback twice produces no duplicate User or Integration records; both sessions surface the same email.

### Scenario 10: Criterion 5496 — Same email from different provider links to existing user

pass

Spex scenario verifies that a Google signup followed by a GitHub signup with the same email links to the same User record rather than creating a duplicate.

### Scenario 11: Criterion 5497 — Provider response without email aborts registration

pass

Spex scenario verifies that a GitHub callback with an empty emails list sets no session token and redirects to `/users/log-in`.

### Scenario 12: Criterion 5498 — Integration save failure does not gate login

pass

Spex scenario verifies that a Google callback with an empty `access_token` (causing integration save failure) still logs the user in and the settings page renders their email.

## Evidence

- `.code_my_spec/qa/602/screenshots/602_register_page.png` — Register page (`/users/register`) with both GitHub and Google OAuth buttons visible
- `.code_my_spec/qa/602/screenshots/602_actual_login_page.png` — Login page (`/users/log-in`) with both OAuth buttons visible
- `.code_my_spec/qa/602/screenshots/602_login_page.png` — Login page in re-auth mode (existing session)

Curl evidence:

`GET /auth/github/login` → `302 Location: https://github.com/login/oauth/authorize?client_id=Ov23liFpnT7j3bK5OC1L&...&scope=user%3Aemail`

`GET /auth/google/login` → `302 Location: https://accounts.google.com/o/oauth2/v2/auth?...&scope=openid+email+profile`

`GET /auth/google/callback?error=access_denied` (login-flow cookie) → `302 Location: /users/log-in`

`GET /auth/github/callback?error=access_denied` (login-flow cookie) → `302 Location: /users/log-in`

`mix spex test/spex/602_oauth_registration_logs_the_user_in_via_the_callback/` → 525 tests, 0 failures

## Issues

### OAuth callback not end-to-end testable against localhost

#### Severity
INFO

#### Scope
QA

#### Description

The OAuth callback flow (token exchange → user creation → session → redirect) cannot be driven end-to-end from a real browser against `http://127.0.0.1:4000` because the configured `redirect_uri` is `https://dev.codemyspec.com/auth/:provider/callback` — a Cloudflare-tunneled hostname that routes real provider responses to the production domain, not localhost. There is no local OAuth stub server (e.g., a fake Google OIDC endpoint on localhost that would redirect back to `127.0.0.1:4000/auth/google/callback`).

Mitigation in place: `ReqCassette`-based spex scenarios replay real provider responses in-process and fully exercise the callback contract including session creation, user persistence, and redirect behavior. All 6 criteria pass.

If full end-to-end browser coverage is required in the future, add a `localhost`-scoped `redirect_uri` to the Google/GitHub OAuth app configuration for dev, or stand up a local OAuth stub. Not blocking for this pass.
