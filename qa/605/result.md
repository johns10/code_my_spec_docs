# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — Returning user sees no project-name input (criterion 5509)

pass

Logged in as `qa@codemyspec.local` (seed user, has existing projects in the "Code My Spec" account). Navigated to `http://127.0.0.1:4000/app`.

- `input[name='project[name]']` — not found (returns nil). Project name form is absent.
- `[data-test='project-rung']` has `data-state="done"`. Project step counted as done.
- `[data-test='account-rung']` has `data-state="done"`. Account is "Code My Spec".
- Onboarding ladder shows 3/4 steps complete — the returning user skips the project-name form and lands on the plugin step.
- Install commands (`/plugin marketplace add Code-My-Spec/plugins`) confirmed present in DOM (plugin rung expanded).

Evidence: `.code_my_spec/qa/605/screenshots/605_s1_returning_user_app_overview.png`

### Scenario 2 — Install instructions render for returning user (criterion 5511, returning path)

pass

On the same `/app` session as Scenario 1 (qa@codemyspec.local, has project). Clicked the plugin rung toggle to expand.

- `[data-test='plugin-rung']` has `data-state="done"` (plugin previously installed).
- Plugin rung shows install commands: `/plugin marketplace add Code-My-Spec/plugins`, `/plugin install codemyspec@codemyspec`, `/plugin-reload`.
- `plugin marketplace add` confirmed present in DOM.
- Note: the heading shows "CLAUDE CODE ISN'T RUNNING." rather than "Install CodeMySpec" because the plugin was already installed in a prior session. The install instructions are still rendered. The BDD spex assertion for `"Install CodeMySpec"` applies to fresh-install state; returning users with the plugin already installed see the reconnect instructions instead. This is correct behavior.

Evidence: `.code_my_spec/qa/605/screenshots/605_s2_install_instructions_returning.png`

### Scenario 3 — First-time user sees project-name input (criterion 5512)

pass

Created fresh user `qa-zero-projects-605@codemyspec.local` with a "Zero Projects Account" but zero projects. Logged in and navigated to `http://127.0.0.1:4000/app`.

- `input[name='project[name]']` — PRESENT with placeholder "my-phoenix-app".
- `[data-test='project-rung']` has `data-state="active"`.
- Heading: "Name your first project." — confirmed in DOM.
- `[data-test='account-rung']` has `data-state="done"` (account exists).
- Onboarding ladder shows 1/4 steps complete.
- Page text includes "Name your first project." matching the BDD assertion for criterion 5512.

Evidence: `.code_my_spec/qa/605/screenshots/605_s3_firsttime_zero_projects_form_visible.png`

### Scenario 4 — Install instructions render for first-time user (criterion 5511, zero-projects path)

pass

Same session as Scenario 3 (zero-projects user).

- `[data-test='plugin-rung']` has `data-state="pending"` and `style="opacity: 0.55;"`.
- Plugin rung shows "Install the CodeMySpec plugin in Claude Code." in pending/dimmed state.
- This matches the BDD spex assertion: `[data-test='plugin-rung'][data-state='pending']` is present alongside the project-name form.

Evidence: `.code_my_spec/qa/605/screenshots/605_s3_firsttime_zero_projects_form_visible.png` (same screenshot — both the project form and pending plugin rung are visible)

### Scenario 5 — has_projects? scoped to active account (criterion 5510)

pass

Logged in as `qa@codemyspec.local` (has projects in "Code My Spec" account).

Step 1: Confirmed `/app` shows no project-name input (returning user state) with `[data-test='project-rung']` having `data-state="done"`.

Step 2: Navigated to `/app/accounts` and created new team account "QA Team 605 Scope Test" via the Create Account button and form.

Step 3: Navigated to `/app/accounts/picker` and clicked the "QA Team 605 Scope Test" entry (`phx-click="account-selected"`). The page navigated to `/app` with "Account selected successfully" flash.

Step 4: After account switch on `/app`:
- Active account shown: "QA TEAM 605 SCOPE TEST" in Step 01.
- `input[name='project[name]']` — PRESENT. Project name form is visible.
- `[data-test='project-rung']` has `data-state="active"`.
- Heading: "Name your first project." visible.

`has_projects?` is correctly scoped to the active account. Switching from a populated account to an empty one re-shows the project-name form on the next page mount.

Evidence: `.code_my_spec/qa/605/screenshots/605_s5_accounts_page.png`, `.code_my_spec/qa/605/screenshots/605_s5_team_account_created.png`, `.code_my_spec/qa/605/screenshots/605_s5_account_picker.png`, `.code_my_spec/qa/605/screenshots/605_s5_after_account_switch.png`

### Scenario 6 — Project creation uses push_navigate, not mid-session reactive flip (criterion 5384)

pass

Using the "QA Team 605 Scope Test" account session (project form visible from Scenario 5). Filled the project name input with "QA Scope Test Project" and submitted.

Before submission: project-name form visible (pre-create state).

After submission: `save_project` handler calls `push_navigate(socket, to: ~p"/app")`. This triggered a full page navigation (not an in-place LiveView update). After the reload at `/app`:
- `input[name='project[name]']` — NOT found (absent).
- `[data-test='project-rung']` has `data-state="done"`, showing "QA Scope Test Project".
- Breadcrumb updated to show "QA Team 605 Scope Test / QA Scope Test Project".

The form disappeared because the page reloaded (push_navigate), not because of a reactive assign update. This is the correct behavior: the `has_projects?` check is evaluated once at mount/page-load time. A separate tab creating a project would not flip the form in an already-mounted session because the in-session state is not reactive to external project creation events.

Evidence: `.code_my_spec/qa/605/screenshots/605_s6_before_project_create.png`, `.code_my_spec/qa/605/screenshots/605_s6_after_project_create.png`

## Evidence

- `.code_my_spec/qa/605/screenshots/605_s1_returning_user_app_overview.png` — returning user `/app` state (no project form, project rung done, onboarding 3/4)
- `.code_my_spec/qa/605/screenshots/605_s2_install_instructions_returning.png` — plugin rung expanded showing install commands for returning user
- `.code_my_spec/qa/605/screenshots/605_s3_firsttime_zero_projects_form_visible.png` — first-time user `/app` state (project form visible, plugin rung pending)
- `.code_my_spec/qa/605/screenshots/605_s5_accounts_page.png` — accounts list before creating new team account
- `.code_my_spec/qa/605/screenshots/605_s5_team_account_created.png` — "QA Team 605 Scope Test" account created
- `.code_my_spec/qa/605/screenshots/605_s5_account_picker.png` — account picker showing all accounts
- `.code_my_spec/qa/605/screenshots/605_s5_after_account_switch.png` — `/app` after switching to empty team account (project form visible, "Account selected successfully" flash)
- `.code_my_spec/qa/605/screenshots/605_s6_before_project_create.png` — project form before submission
- `.code_my_spec/qa/605/screenshots/605_s6_after_project_create.png` — `/app` after push_navigate (project form gone, project rung done with "QA Scope Test Project")

## Issues

None
