# Qa Story Brief

## Tool

web (Vibium MCP browser) for UI surface — register and login pages showing OAuth buttons. curl for controller surface — OAuth initiation routes (302 redirect verification) and error-path callback behavior. mix spex for the full callback contract — real provider token exchange cannot be replayed against the running app via browser; cassette-based spex is the accepted verification mechanism.

## Auth

No authentication required. The pages under test (`/users/register`, `/users/log-in`, `/auth/:provider/login`, `/auth/:provider/callback` error path) are all publicly accessible. Session cookies for error-path callback tests are captured from the initiation redirect response mid-test.

## Seeds

No seed scripts required. The OAuth flow creates new users on each callback. Error-path tests do not create users. Spex scenarios generate unique user identities via `System.unique_integer/1` and build their own cassettes.

## What To Test

- Navigate to `http://127.0.0.1:4000/users/register` — verify both "Continue with GitHub" (href `/auth/github/login`) and "Continue with Google" (href `/auth/google/login`) buttons render. Screenshot for evidence.
- Navigate to `http://127.0.0.1:4000/users/log-in` — verify both OAuth buttons render on the login page. Screenshot for evidence.
- `GET /auth/github/login` via curl — verify HTTP 302 and Location header points to `https://github.com/login/oauth/authorize` with correct client_id and scope `user:email`.
- `GET /auth/google/login` via curl — verify HTTP 302 and Location header points to `https://accounts.google.com/o/oauth2/v2/auth` with correct client_id and scope `openid email profile`.
- `GET /auth/google/callback?error=access_denied` via curl with a login-flow session cookie — verify HTTP 302 redirect to `/users/log-in` (error path aborts to login, not settings).
- `GET /auth/github/callback?error=access_denied` via curl with a login-flow session cookie — verify HTTP 302 redirect to `/users/log-in`.
- Run `mix spex test/spex/602_oauth_registration_logs_the_user_in_via_the_callback/` — verify all 6 criteria pass: confirmed_at set, integration row persisted, repeat sign-in idempotent, same-email cross-provider linking, missing-email abort, integration-save-failure does not gate login.

## Result Path

.code_my_spec/qa/602/result.md
