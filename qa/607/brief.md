# Qa Story Brief

## Tool

web

## Auth

Three personas required:

- **Zero-account user** — must be created fresh during the test (registration form → magic-link confirm). Use the live system flow so the test exercises the full signup pipeline.
  1. Browser: `GET http://localhost:4000/users/register`
  2. Fill `user[email]` with a unique throwaway address (e.g. `qa-zero-#{System.unique_integer([:positive])}@codemyspec.local`) and submit.
  3. Open the Swoosh mailbox preview at `http://localhost:4000/dev/mailbox`, find the most-recent magic-link email, copy the `/users/log-in/:token` URL.
  4. Visit the link in the browser session — that lands the user logged-in.

- **Single-account user** — `qa_seeds.exs` provisions exactly this. After seeding, log in via the email form at `http://localhost:4000/users/log-in`:
  - Email: `qa@codemyspec.local`
  - Password: `qa-password-123!`
  Click the password tab on the form (or use the password field directly — magic link is on the same page).

- **Multi-account user (no active selection)** — start from the seeded single-account user, then create a second account via the in-app form, then clear `user_preferences.active_account_id` via iex (or follow the form flow then nuke the preference). Easiest path:
  ```
  iex -S mix
  iex> alias CodeMySpec.{Accounts, Repo, Users, UserPreferences}
  iex> {user, _} = Users.get_user_by_email_and_password("qa@codemyspec.local", "qa-password-123!") |> then(&{&1, nil})
  iex> scope = CodeMySpec.Users.Scope.for_user(user)
  iex> {:ok, _} = Accounts.create_account(scope, %{name: "Second Account"})
  iex> Repo.update_all(Ecto.Query.from(p in CodeMySpec.UserPreferences.UserPreference, where: p.user_id == ^user.id), set: [active_account_id: nil])
  ```
  Then re-login via the email/password form to pick up the cleared preference.

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

That gives you the single-account user (`qa@codemyspec.local` / `qa-password-123!`, account slug `qa-account`, project `QA Fixture Project`). The zero-account user is created live during the test; the multi-account user is built up via iex after seeding.

If the Swoosh local mailbox is dirty from a prior run, clear it: visit `http://localhost:4000/dev/mailbox` and use the "Delete all" link.

## What To Test

Exercise each of the eight acceptance criteria. Use `mcp__vibium__browser_*` throughout. Capture screenshots into `.code_my_spec/qa/607/screenshots/` at each `data-test` checkpoint and at any failure.

1. **5519 — Magic-link confirmation lands user on /app.**
   Register a new throwaway user, fetch magic link from `/dev/mailbox`, visit it. Assert final URL is exactly `/app` (no `/app/users/settings`, no `/app/accounts/picker`).

2. **5520 — Stale `user_return_to` overwritten with /app.**
   Before logging in, visit `http://localhost:4000/app/accounts/picker` (this stashes `user_return_to` in the session for the redirect-after-login). Then go through the magic-link flow as a brand-new user. Assert post-confirm URL is `/app`, NOT the stashed picker path.

3. **5521 — Zero-account user redirected to /app from a guarded route.**
   While logged in as the zero-account user, visit `http://localhost:4000/app/projects`. Assert resulting URL is `/app` (not `/app/accounts/picker`, not a crash page).

4. **5522 — Zero-account user on /app sees the create-account form.**
   While logged in as the zero-account user, visit `http://localhost:4000/app`. Assert the page renders the "Name your account" rung in active state (look for `data-test="account-rung"` with `data-state="active"` and an `input[name="account[name]"]`). Assert NO redirect to `/app/accounts/picker`.

5. **5523 — Single-account user reaches /projects without picker.**
   Log in as the seeded user (`qa@codemyspec.local`). Visit `http://localhost:4000/app/projects`. Assert URL stays at `/app/projects` and the project list renders. Assert no intermediate flash of `/app/accounts/picker`.

6. **5524 — Multi-account user with no active selection bypasses picker.**
   Set up the multi-account user (see Auth). Log in fresh. Visit `http://localhost:4000/app/projects`. Assert URL is `/app/projects`, not the picker. The system should auto-pick the first account.

7. **5527 — Direct visit to /app/accounts/picker renders the picker.**
   While logged in (any account state), visit `http://localhost:4000/app/accounts/picker` directly. Assert URL stays at `/app/accounts/picker` and the picker UI renders (look for a list of accounts to select, or a `data-test="picker"` element if present).

8. **5529 — Normal-flow walk through guarded routes never resolves to picker.**
   As the seeded single-account user, walk from `/app` → click any "Open" project link → navigate `/app/projects/:id/stories` (or whichever guarded route the UI exposes). At each step capture the URL. Assert NONE of the intermediate URLs is `/app/accounts/picker`.

For each scenario, capture a screenshot at the assertion point and one at any unexpected redirect. If the criterion fails, capture the exact URL the browser landed on and the visible heading text.

## Result Path

.code_my_spec/qa/607/result.md

## Setup Notes

- The hosted endpoint is `http://localhost:4000` (HTTP — the QA plan notes 4001 for HTTPS which we don't need for this story).
- `:require_at_least_one_account` is the `on_mount` hook that redirects zero-account users to `/app`; check `lib/code_my_spec_web/user_auth.ex` line ~261. The `:require_active_account` mount (~line 282) is the one that auto-picks the first account for users with at least one.
- The signed_in_path fallback (`/app/users/settings`) is *not* what magic-link confirmation uses — `UserSessionController.confirm/2` puts `user_return_to: ~p"/app"` in the session before calling `log_in_user/3`, so the magic-link path is independent of `signed_in_path/1`. If the test fails on 5519, suspect the controller, not the user_auth fallback.
- The picker route (`/app/accounts/picker`) IS reachable; it just shouldn't be the redirect target. Criterion 5527 verifies it still works for users who go there on purpose (e.g. via an account-switch menu).
