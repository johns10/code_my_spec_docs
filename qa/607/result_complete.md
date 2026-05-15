# Qa Result

## Status

pass

## Scenarios

### 5519 — Magic-link confirmation lands user on /app

**Steps:**
1. Visited `http://localhost:4000/users/register`.
2. Filled `user[email]` with `qa-zero-1778816679-24332@codemyspec.local` (fresh, never-seen address) and submitted via `Email me a login link`.
3. Page redirected to `/users/check-email` confirming the magic link was queued.
4. Opened `http://localhost:4000/dev/mailbox` and captured the magic-link token (`Z1VwuR2uQKtb4awys3h7OKqKgs0mNLGd8o0XHikGW3w`) from the most-recent email.
5. Visited `http://localhost:4000/users/log-in/Z1VwuR2uQKtb4awys3h7OKqKgs0mNLGd8o0XHikGW3w`.

**Outcome:** PASS. `browser_get_url` returned `http://localhost:4000/app` (exact match — no `/users/settings`, no `/app/accounts/picker`). Source: `UserSessionController.confirm/2` puts `user_return_to: ~p"/app"` in the session before calling `UserAuth.log_in_user/3`, which then redirects to the session's `user_return_to`. Evidence: `screenshots/02_5519_post_magic_link.png`.

### 5520 — Stale user_return_to overwritten with /app

**Steps:**
1. Deleted all cookies (fresh anonymous session).
2. Navigated to `http://localhost:4000/app/accounts/picker`. The plug-based `require_authenticated_user` redirected to `/users/log-in` after stashing `/app/accounts/picker` in `session[:user_return_to]` (via `maybe_store_return_to/1`).
3. Registered a NEW user (`qa-stale-1778817295-32509@codemyspec.local`) in the same browser session, preserving the stashed return-to.
4. Fetched the new magic-link token (`FuQDZpIu4mdfwIAjQVuPIoArefaUefwzLMQucVLa-X8`) from `/dev/mailbox`.
5. Visited the magic-link URL.

**Outcome:** PASS. Final URL was `http://localhost:4000/app`, NOT the stashed `/app/accounts/picker`. The controller's explicit `put_session(:user_return_to, ~p"/app")` (lib/code_my_spec_web/controllers/user_session_controller.ex:13) overwrote the stale value. Evidence: `screenshots/06_5520_stale_return_to_overwritten.png`.

### 5521 — Zero-account user redirected to /app from guarded route

**Steps:**
1. Logged in as the zero-account user from 5519 (no accounts).
2. Visited `http://localhost:4000/app/projects` (this is the SaaS-hosted `:require_active_account` live session route — the brief erroneously listed `/projects` but the real route lives under `/app/`).

**Outcome:** PASS. `browser_get_url` returned `http://localhost:4000/app` — the `:require_at_least_one_account` on_mount (lib/code_my_spec_web/user_auth.ex:261) caught the empty-accounts state and redirected to `/app` before `:require_active_account` could fire its picker fallback. Evidence: `screenshots/04b_5521_zero_account_visiting_app_projects.png`. Initial attempt with `/projects` (no `/app` prefix) hit a `NoRouteError`, which I include below as a Setup Notes item — `screenshots/04_5521_zero_account_visiting_projects.png` documents the misroute.

### 5522 — Zero-account user on /app sees the create-account form

**Steps:**
1. Logged in as zero-account user.
2. Visited `http://localhost:4000/app`.

**Outcome:** PASS. The `data-test="account-rung"` with `data-state="active"` rendered with text "Name your account" plus an `input[name="account[name]"]` (placeholder "Acme"). No redirect to `/app/accounts/picker`. Evidence: `screenshots/03_5522_zero_account_app_form.png`.

### 5523 — Single-account user reaches /projects without picker

**Steps:**
1. Logged out, deleted cookies, then logged in via `#login_form_password` with `qa@codemyspec.local` / `qa-password-123!`.
2. After login landed on `/` (note: `UserAuth.signed_in_path/1` returns `/app/users/settings` for an authenticated scope, but the conn's `current_scope` is not yet refreshed mid-pipeline so the fallback `/` clause matches — observation, not a 607 failure).
3. Navigated to `http://localhost:4000/app/projects`.

**Outcome:** PASS. `browser_get_url` stayed at `/app/projects` and the page rendered with an `<h1>` of "Projects". No intermediate flash of the picker. Evidence: `screenshots/07_5523_single_account_projects.png`.

### 5524 — Multi-account user with no active selection bypasses picker

**Setup steps (via `/tmp/qa_607_multi_account.exs`):**
- Loaded the existing `qa@codemyspec.local` user.
- Called `Accounts.create_account/2` to create `QA Second Account` (now user belongs to `code-my-spec` + `qa-second-account`).
- `Repo.update_all` cleared `active_account_id` and `active_project_id` on the user's `user_preferences` row.

**Test steps:**
1. Deleted cookies, logged in fresh.
2. Visited `http://localhost:4000/app/projects`.

**Outcome:** PASS. `browser_get_url` returned `/app/projects` — `:require_active_account` (lib/code_my_spec_web/user_auth.ex:282) detected the nil `active_account`, took `[first | _] = Accounts.list_accounts(scope)`, called `UserPreferences.select_active_account/2`, and continued the mount with the freshly-assigned scope. Picker was never reached. Evidence: `screenshots/09_5524_multi_account_projects.png`.

### 5527 — Direct visit to /app/accounts/picker renders the picker

**Steps:**
1. Logged in as the zero-account user.
2. Navigated directly to `http://localhost:4000/app/accounts/picker`.

**Outcome:** PASS. URL stayed at `/app/accounts/picker` and the page rendered with heading "Select Account" and subhead "Choose which account you'd like to work with". The picker route lives under `:require_authenticated` only (not `:require_active_account`), so it's reachable for any authenticated user regardless of account state. Evidence: `screenshots/05_5527_direct_picker_renders.png`.

### 5529 — Normal-flow walk through guarded routes never resolves to picker

**Steps (single-account user, captured URL at each step):**
1. `/app` → URL: `http://localhost:4000/app`
2. `/app/accounts` → URL: `http://localhost:4000/app/accounts`
3. `/app/projects` → URL: `http://localhost:4000/app/projects`
4. `/app/issues` → URL: `http://localhost:4000/app/issues`
5. `/app/content_admin` → URL: `http://localhost:4000/app/content_admin`

**Outcome:** PASS. None of the five intermediate URLs was `/app/accounts/picker`. Evidence: `screenshots/08_5529_walk_no_picker.png`.

## Evidence

- `screenshots/01_mailbox_magic_link.png` — Swoosh mailbox showing the magic-link email for the zero-account user.
- `screenshots/02_5519_post_magic_link.png` — Post-confirm landing on `/app`.
- `screenshots/03_5522_zero_account_app_form.png` — Zero-account `/app` rendering the create-account rung.
- `screenshots/04_5521_zero_account_visiting_projects.png` — `NoRouteError` from initial misroute to `/projects` (not a 607 failure, brief error).
- `screenshots/04b_5521_zero_account_visiting_app_projects.png` — `/app/projects` redirected to `/app`.
- `screenshots/05_5527_direct_picker_renders.png` — Picker rendering on direct visit.
- `screenshots/06_5520_stale_return_to_overwritten.png` — Stale return-to overridden post-magic-link.
- `screenshots/07_5523_single_account_projects.png` — Single-account `/app/projects` rendering.
- `screenshots/08_5529_walk_no_picker.png` — Final state after `/app/content_admin` walk.
- `screenshots/09_5524_multi_account_projects.png` — Multi-account `/app/projects` rendering after auto-pick.

## Issues

### Brief incorrectly references `/projects` instead of `/app/projects`

#### Severity

LOW

#### Scope

QA

#### Description

The brief I authored (`.code_my_spec/qa/607/brief.md`) repeatedly referenced `http://localhost:4000/projects` for criteria 5521, 5523, 5524, and 5529. The hosted SaaS endpoint actually serves project routes under the `/app/` namespace (e.g., `/app/projects`). A direct visit to `/projects` returns a Phoenix `NoRouteError` (404). All criteria still passed under the correct `/app/projects` URL, but a future tester reading the brief verbatim would hit the 404 before realizing the path is wrong. Suggest patching the brief or making 607's spex files the canonical source for the URL.

### Password-form login lands on `/` instead of `/app` or `/app/users/settings`

#### Severity

INFO

#### Scope

APP

#### Description

After a successful password login at `/users/log-in` (form id `login_form_password`), the browser ends up at `http://localhost:4000/` (the marketing root). `UserAuth.signed_in_path/1` has two clauses:

```elixir
def signed_in_path(%Plug.Conn{assigns: %{current_scope: %Scope{user: %Users.User{}}}}) do
  ~p"/app/users/settings"
end
def signed_in_path(_), do: ~p"/"
```

The second clause (fallback) matches when `conn.assigns.current_scope` doesn't carry a user struct yet — which is the case mid-pipeline during `log_in_user/3` because `current_scope` is set by `fetch_current_scope_for_user/2` on the *next* request after the session cookie is issued. So password login always lands on `/`.

This is unrelated to story 607 (magic-link confirmation correctly bypasses `signed_in_path/1` by pre-stashing `user_return_to: /app`), but it's a latent UX bug — a returning user signing in with password should arrive somewhere useful, not the marketing home page. Suggest either (a) populating `conn.assigns.current_scope` synchronously inside `log_in_user/3` before the redirect check, or (b) changing the fallback clause to inspect the just-logged-in user via `get_session(conn, :user_token)`.

### qa_seeds.exs crashes on missing stories table

#### Severity

MEDIUM

#### Scope

QA

#### Description

Running `mix run priv/repo/qa_seeds.exs` against the dev Postgres DB crashes partway through at line 145 with `(Postgrex.Error) ERROR 42P01 (undefined_table) relation "stories" does not exist`. User + account + project seeding (lines 1–144) complete successfully before the crash, so the script is partially idempotent — but anything downstream of stories-touching steps is unseeded. Cause is likely a missed `mix ecto.migrate` on the dev DB. Story 607 testing wasn't blocked, but the seed script should either skip cleanly when `stories` is absent or the dev DB should be migrated.
