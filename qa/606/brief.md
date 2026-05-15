# Qa Story Brief

## Tool

web

## Auth

Three personas required:

- **Anonymous (criterion 5399)** — delete all cookies before testing. Visiting `/app` should redirect to `/users/log-in`.

- **Zero-account user (criteria 5513, 5514, 5516)** — register a fresh throwaway address. The story is specifically about account creation as the first wizard step, so this user must have no existing accounts.
  1. `browser_delete_cookies`
  2. Navigate to `http://localhost:4000/users/register`.
  3. Fill `input[name='user[email]']` with `qa-606-zero-#{System.unique_integer([:positive])}@codemyspec.local`.
  4. Submit `#registration_form`.
  5. Fetch the magic-link token from `http://localhost:4000/dev/mailbox` (most-recent message → `#text-body-content`).
  6. Visit `http://localhost:4000/users/log-in/<token>` — lands on `/app` with the account-rung active.

- **Single-account user, no active selection (criterion 5517)** and **single-account user with active selection (criterion 5518)** — seeded user (`qa@codemyspec.local` / `qa-password-123!`) is already a member of `Code My Spec` and `QA Second Account` (two accounts, courtesy of story 607's setup script). For 5517 we need ZERO active-account preference; for 5518 we need ONE set. Reset the preferences between scenarios:

  ```
  cat > /tmp/qa_606_reset_prefs.exs <<'EOF'
  alias CodeMySpec.{Users, UserPreferences, Repo}
  import Ecto.Query

  user = Users.get_user_by_email("qa@codemyspec.local")
  scope = CodeMySpec.Users.Scope.for_user(user)

  # Toggle: pass "clear" to clear, anything else to set first account active
  mode = System.argv() |> List.first() || "clear"

  case mode do
    "clear" ->
      from(p in CodeMySpec.UserPreferences.UserPreference, where: p.user_id == ^user.id)
      |> Repo.update_all(set: [active_account_id: nil, active_project_id: nil])
      IO.puts("cleared preferences for #{user.email}")

    "set" ->
      [first | _] = CodeMySpec.Accounts.list_accounts(scope)
      {:ok, _} = UserPreferences.select_active_account(scope, first.id)
      IO.puts("set active_account=#{first.name} for #{user.email}")
  end
  EOF
  ```

  Then run `mix run /tmp/qa_606_reset_prefs.exs clear` before 5517 and `mix run /tmp/qa_606_reset_prefs.exs set` before 5518. In each case, log in via `#login_form_password` (email `qa@codemyspec.local`, password `qa-password-123!`).

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

(Idempotent. Story 607 left `qa@codemyspec.local` with two accounts and a `QA Second Account`. That's still useful for 5517/5518 — both are valid "has at least one account" states.)

The zero-account user is created live during the test via `/users/register`.

If the Swoosh mailbox is dirty from prior runs, clear it at `http://localhost:4000/dev/mailbox` → "Empty mailbox" before fetching a magic link.

## What To Test

Capture screenshots into `.code_my_spec/qa/606/screenshots/` (use bare filenames in the `browser_screenshot` call; Vibium saves to `~/Pictures/Vibium/` then we copy into the result dir).

1. **5399 — Unauthenticated visitor is redirected to login.**
   `browser_delete_cookies` → navigate to `http://localhost:4000/app` → assert URL contains `/users/log-in` (the plug-based `require_authenticated_user` redirect).

2. **5513 — Zero-account user sees the create-account form on /app.**
   Register + magic-link-confirm a fresh user (per Auth). After confirm, browser lands on `/app`. Assert:
   - `data-test="account-rung"` with `data-state="active"` is present
   - `input[name="account[name]"]` is present with placeholder `Acme`
   - Heading text contains "Name your account"
   - No `data-test="account-rung"` element with `data-state="done"`.

3. **5514 — Valid submission creates the account and advances onboarding.**
   Continuing as the same zero-account user on `/app`, fill `input[name="account[name]"]` with `My QA Account 606` and submit `#account_form`. Assert:
   - Page navigates back to `/app` (the LiveView calls `push_navigate(socket, to: ~p"/app")`).
   - `data-test="account-rung"` now renders with `data-state="done"` and shows the account name.
   - `data-test="project-rung"` is now `active` (the next rung).
   - In DB: `CodeMySpec.Accounts.list_accounts(scope_for_user("qa-606-zero-...@...")) ` returns a list containing the new account. (Verify with `mix run -e ...` or by trusting the UI.)

4. **5516 — Invalid submission re-renders with errors and creates no account.**
   Register another fresh throwaway user (or use a previously-registered one IF it still has zero accounts — easier to register fresh). On `/app`, leave `input[name="account[name]"]` blank and submit. Assert:
   - URL stays at `/app`.
   - Form still shows the empty input + an inline validation error (the `Account.create_changeset` validates `:name` required + length 1..255).
   - `data-test="account-rung"` is still `active` (NOT `done`).
   - No new account exists for this user (verify via `mix run`).

5. **5517 — User with accounts but no active selection has the first auto-assigned.**
   Run `mix run /tmp/qa_606_reset_prefs.exs clear`. Delete cookies. Log in via password form (`#login_form_password_email` + `#user_password` + `#login_form_password button[name='user[remember_me]']`). Navigate to `/app`. Assert:
   - URL stays at `/app`.
   - `data-test="account-rung"` is `done` (NOT `active` — meaning create-account form is NOT shown).
   - `data-test="project-rung"` is `active` (the next rung) OR `done` if a project already exists for this user/account.
   - DB has the active_account_id set to a real account (run `mix run -e 'IO.inspect(CodeMySpec.UserPreferences.UserPreference |> CodeMySpec.Repo.get_by(user_id: <id>))'`).

6. **5518 — Returning user with active account skips create-account step.**
   Run `mix run /tmp/qa_606_reset_prefs.exs set`. Delete cookies. Log in again. Navigate to `/app`. Assert:
   - `data-test="account-rung"` is `done` and shows the active account's name.
   - No `input[name="account[name]"]` is present anywhere on the page.
   - `active_step` on the rung ladder is `:project` (or beyond), NOT `:account`.

For each scenario, capture a screenshot at the key assertion checkpoint. On any unexpected redirect or render, capture and note the actual URL + visible heading.

## Result Path

.code_my_spec/qa/606/result.md

## Setup Notes

- AppLive.Overview's `ensure_active_account/1` mount fallback (lib/code_my_spec_web/live/app_live/overview.ex line ~48) handles three cases: scope already has active_account → continue; user has zero accounts → render onboarding ladder with `:account` active; user has accounts but no active → pick first via `UserPreferences.select_active_account/2`, then re-derive scope. Both the "zero accounts" and "auto-pick first" paths are exercised here.
- The form submit handler `create_account` (overview.ex line ~148) creates the account via `Accounts.create_account/2`, calls `UserPreferences.select_active_account/2`, and `push_navigate`s back to `/app`. The re-mount picks up the updated scope.
- Validation errors surface via `surface_slug_errors_on_name/1` — slug-level errors get mapped onto the `:name` field. An empty name should trigger "can't be blank" on `:name` from `validate_required([:name, :slug])` (or the equivalent message — `Account.create_changeset/1` is the source of truth).
- The 607 QA run left two throwaway users (`qa-zero-1778816679-24332@codemyspec.local`, `qa-stale-1778817295-32509@codemyspec.local`) in the DB. Each has zero accounts because the create-account form was never submitted. These can be reused for 5513/5516 INSTEAD of registering fresh, saving a magic-link round-trip — but if either has been since logged into in another session they might have an account, so verify zero-account state first.
