# Qa Story Brief

## Tool

web (Vibium MCP browser tools — LiveView surface on port 4000)

## Auth

Navigate to `http://127.0.0.1:4000/users/log-in`.

For the returning-user account (QA seed user, has an existing project):
- Fill the password form (bottom form on the page):
  - `form[action="/users/log-in"] input[name='user[email]']` → `qa@codemyspec.local`
  - `form[action="/users/log-in"] input[name='user[password]']` → `qa-password-123!`
- Submit. Landing page is `/app/users/settings`; navigate to `/app` to begin testing.

For the zero-projects (first-time user) path:
- Register a fresh account at `http://127.0.0.1:4000/users/register`
- Use a unique email (e.g. `qa-fresh-605@codemyspec.local`) and password `qa-password-123!`
- Log in with those credentials then navigate to `/app`

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

This creates/updates:
- Email `qa@codemyspec.local` / password `qa-password-123!`
- Account `qa-account`
- Project `QA Fixture Project` (id `11111111-1111-4111-8111-111111111111`)

The QA seed user already has one project, putting them in "returning user" state for criteria 5509, 5510 (partially), 5511 (returning path). A fresh browser registration is used to exercise the zero-projects path (criterion 5512 and 5511 first-time path).

## What To Test

### Scenario 1 — Returning user sees no project-name input (criterion 5509)

1. Run seeds, log in as `qa@codemyspec.local`, navigate to `http://127.0.0.1:4000/app`
2. Confirm `input[name='project[name]']` is NOT present on the page
3. Confirm `[data-test='project-rung'][data-state='done']` is present (project step done)
4. Confirm install step commands are visible (`plugin marketplace add` text present)
5. Screenshot the `/app` page state

### Scenario 2 — Install instructions render for returning user (criterion 5511, returning path)

1. On the same `/app` session as Scenario 1
2. Confirm the plugin rung is present (`[data-test='plugin-rung']`)
3. Confirm the install commands are rendered — look for `plugin marketplace add` in page text
4. Screenshot the plugin rung area

### Scenario 3 — First-time user sees project-name input (criterion 5512)

1. Register a new account at `http://127.0.0.1:4000/users/register`
   - Use email `qa-fresh-605@codemyspec.local`, password `qa-password-123!`
2. Complete email confirmation (check `/dev/mailbox` if needed, or check if auto-confirmed in dev)
3. Navigate to `http://127.0.0.1:4000/app`
4. Confirm `input[name='project[name]']` IS present
5. Confirm page contains text related to naming your first project (heading "Name your first project.")
6. Screenshot the first-time `/app` state

### Scenario 4 — Install instructions render for first-time user (criterion 5511, zero-projects path)

1. On the same first-time user session as Scenario 3
2. Confirm `[data-test='plugin-rung'][data-state='pending']` is present
3. The plugin rung in pending state means it renders alongside the project-name form
4. Screenshot the page showing both the project form and the pending plugin rung

### Scenario 5 — has_projects? scoped to active account (criterion 5510)

1. Log in as `qa@codemyspec.local` (has project in qa-account)
2. Navigate to `/app` — confirm no project-name input (returning user state)
3. Navigate to `http://127.0.0.1:4000/app/accounts` and create a new team account
4. Navigate to `http://127.0.0.1:4000/app/accounts/picker` and switch to the new team account
5. Navigate to `http://127.0.0.1:4000/app` after switching
6. Confirm `input[name='project[name]']` IS now present (empty account has no projects)
7. Screenshot both the picker switch and the resulting /app state

### Scenario 6 — Project added in another tab does not flip form mid-session (criterion 5384)

1. Using the first-time user session from Scenario 3 (or a fresh registration)
2. Navigate to `/app` and confirm the project-name form is visible
3. Submit the project form to create a project (simulating "Tab B" creating a project)
4. Without navigating away or refreshing, check whether the project-name input disappeared
   - Expected: the form does NOT disappear mid-session (no reactive flip)
   - Note: in a Vibium session, LiveView may push a navigate after project creation — observe what actually happens and document the behavior

## Result Path

`.code_my_spec/qa/605/result.md`

## Setup Notes

The QA seed puts `qa@codemyspec.local` in returning-user state with one existing project. Criterion 5512 and the first-time path of criterion 5511 require a zero-project account — use a fresh registration in dev (no email confirmation gate in dev environment) or create a second account via the accounts picker.

The BDD spex for criterion 5511 checks for `[data-test='plugin-rung'][data-state='pending']` on first-time users and the text `plugin marketplace add` + `Install CodeMySpec` for returning users. The source code confirms: plugin-rung renders in "pending" state when `active_step` is `:project` (no projects yet), and "active"/"done" states when the plugin step is reached.

Criterion 5384 (no mid-session flip) is partially tested here but is primarily verified by the spex. In a browser session, LiveView's `push_navigate(to: ~p"/app")` fires after project creation, which causes a page reload — so the browser test will see a navigation, which is consistent with the spec's intent (the flip only happens on explicit reload, not via reactive assign). Document what is observed.
