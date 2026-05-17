# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — Returning user sees no project-name input (criterion 5509)

pass

Logged in as `qa@codemyspec.local` (seed user, has existing project "QA Fixture Project" in the "Code My Spec" account). Navigated to `http://127.0.0.1:4000/app`.

- `input[name='project[name]']` — not found (returns nil). Project name form is absent.
- `[data-test='project-rung']` has `data-state="done"`. Projects counted as done.
- The install steps text `plugin marketplace add` was present in the plugin rung content.

The returning user correctly skips the project-name form and sees the overview ladder with all completed steps collapsed into "done" tiles.

Evidence: `.code_my_spec/qa/605/screenshots/605_scenario1_returning_user_app.png`

### Scenario 2 — Install instructions render for returning user (criterion 5511, returning path)

pass

On the same `/app` session as Scenario 1 (qa@codemyspec.local, has project):

- `[data-test='plugin-rung']` has `data-state="active"` (project done, plugin not yet done).
- Plugin rung text contains `plugin marketplace add Code-My-Spec/plugins` and the heading `INSTALL CODEMYSPEC`.
- Text `plugin marketplace add` confirmed present via `browser_get_text`.

The install instructions render correctly for a returning user alongside the overview.

Evidence: `.code_my_spec/qa/605/screenshots/605_scenario2_install_instructions_returning.png`

### Scenario 3 — First-time user sees project-name input (criterion 5512)

pass

Registered a fresh account via magic link (`qa-fresh-605@codemyspec.local`). The magic link email was retrieved from the dev mailbox at `/dev/mailbox` and the token was used with `127.0.0.1:4000` (instead of `dev.codemyspec.com` in the email body). The confirmation was successful and the user was redirected to `/app`.

Upon landing on `/app` the fresh user had no account, so the account step (step 01) was active. The project form was not yet visible because the account step gate must be cleared first. After creating an account ("Fresh Test Account"):

- `input[name='project[name]']` — found (present).
- `[data-test='project-rung']` has `data-state="active"`.
- Page text includes "Name your first project." as the heading for the project rung.

The project-name input renders correctly once the account step is satisfied and the user has zero projects.

Note: criterion 5512's BDD spex uses `given_ :empty_state_user_on_onboarding` which sets up the LiveView with an account but no projects (not a truly zero-account user). The browser test confirms the same behavior: once an account exists and there are no projects, the project-name input is present. A brand-new user without any account sees the account form first, which is the correct UX ordering and not a bug.

Evidence: `.code_my_spec/qa/605/screenshots/605_scenario3_firsttime_user_app.png`, `.code_my_spec/qa/605/screenshots/605_scenario3_after_account_creation.png`

### Scenario 4 — Install instructions render for first-time user (criterion 5511, zero-projects path)

pass

On the same first-time user session after account creation but before project creation:

- `[data-test='plugin-rung']` has `data-state="pending"` (project step not done, plugin step not yet reached).
- This matches the BDD spex assertion: `[data-test='plugin-rung'][data-state='pending']` is present alongside the project-name form.

The plugin rung renders in "pending" state alongside the project form for a first-time user.

Evidence: `.code_my_spec/qa/605/screenshots/605_scenario4_firsttime_plugin_pending.png`

### Scenario 5 — has_projects? scoped to active account (criterion 5510)

pass

Starting as `qa@codemyspec.local` on the "Code My Spec" account (has project):
- `/app` shows project rung as "done" — no project-name input.

Created a new team account "QA Team 605" via `/app/accounts` using the Create Account button.

Navigated to `/app/accounts/picker` and clicked the "QA Team 605" entry (which uses `phx-click="account-selected"`). The picker navigated to `/app` with "Account selected successfully" flash.

After the account switch:
- Active account shown: "QA TEAM 605" (1/4 progress — account done, project not done).
- `input[name='project[name]']` — found (present).
- `[data-test='project-rung']` has `data-state="active"`.

Then navigated explicitly to `http://127.0.0.1:4000/app` to confirm fresh mount:
- Project-name input still present.

`has_projects?` is correctly scoped to the active account. Switching from a populated account to an empty one re-shows the project-name form on the next page load.

Evidence: `.code_my_spec/qa/605/screenshots/605_scenario5_accounts_page.png`, `.code_my_spec/qa/605/screenshots/605_scenario5_team_account_created.png`, `.code_my_spec/qa/605/screenshots/605_scenario5_account_picker.png`, `.code_my_spec/qa/605/screenshots/605_scenario5_after_account_switch.png`, `.code_my_spec/qa/605/screenshots/605_scenario5_empty_account_project_form_visible.png`

### Scenario 6 — Project creation uses push_navigate, not mid-session reactive flip (criterion 5384)

pass

Using the first-time user session after account creation (before project creation):
- Project-name form visible (pre-create state captured in screenshot).
- Submitted the project form with name "My Fresh Project".

After submission, `save_project` handler calls `push_navigate(socket, to: ~p"/app")`. This triggered a full page reload (not an in-place LiveView update). After the reload:
- `input[name='project[name]']` — not found (absent).
- `[data-test='project-rung']` has `data-state="done"`.

The form disappears because the page reloaded (push_navigate), not because of a reactive assign update. This is the correct behavior: the check is evaluated once at mount/page-load time. A separate tab creating a project would not flip the form in an already-mounted session because the in-session state is not reactive to external project creation events.

Evidence: `.code_my_spec/qa/605/screenshots/605_scenario6_before_project_create.png`, `.code_my_spec/qa/605/screenshots/605_scenario6_after_project_create.png`

## Evidence

- `.code_my_spec/qa/605/screenshots/605_scenario1_returning_user_app.png` — returning user `/app` state (no project form, project rung done)
- `.code_my_spec/qa/605/screenshots/605_scenario2_install_instructions_returning.png` — full page showing install instructions for returning user
- `.code_my_spec/qa/605/screenshots/605_scenario3_firsttime_user_app.png` — fresh user landing on `/app` (account form active, before account creation)
- `.code_my_spec/qa/605/screenshots/605_scenario3_after_account_creation.png` — fresh user after account creation (project form now visible)
- `.code_my_spec/qa/605/screenshots/605_scenario4_firsttime_plugin_pending.png` — plugin rung in pending state alongside project form
- `.code_my_spec/qa/605/screenshots/605_scenario5_accounts_page.png` — accounts list before creating new team account
- `.code_my_spec/qa/605/screenshots/605_scenario5_team_account_created.png` — "QA Team 605" account created successfully
- `.code_my_spec/qa/605/screenshots/605_scenario5_account_picker.png` — account picker showing all accounts
- `.code_my_spec/qa/605/screenshots/605_scenario5_after_account_switch.png` — `/app` immediately after switching to empty team account (project form visible)
- `.code_my_spec/qa/605/screenshots/605_scenario5_empty_account_project_form_visible.png` — `/app` fresh mount with empty team account active (project form confirmed)
- `.code_my_spec/qa/605/screenshots/605_scenario6_before_project_create.png` — project form before submission
- `.code_my_spec/qa/605/screenshots/605_scenario6_after_project_create.png` — `/app` after push_navigate following project creation (form gone, project rung done)

## Issues

None
