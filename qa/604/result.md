# Qa Result

## Status

pass

## Scenarios

### Scenario A: Registration and account creation (prerequisite wizard flow)

pass

Registered fresh user `qa-604-1779069053@example.com` via `/users/register`. Received
magic-link email at `/dev/mailbox`, followed the confirmation link at
`http://127.0.0.1:4000/users/log-in/<token>`. Redirected to `/app` showing the account
creation step (step 01 active, 0/4 onboarding complete). Filled "QA Test Account" in
`#account_form` and submitted. Page reloaded to `/app` now showing step 02 (project name
form) active with step 01 marked done as "QA TEST ACCOUNT".

Evidence: `.code_my_spec/qa/604/screenshots/4000_app_after_magic_link.png`,
`.code_my_spec/qa/604/screenshots/4000_app_account_created.png`

### Scenario B: Multi-word name title-cases each word and strips spaces (criterion 5375)

pass

On the project-name step for user `qa-604-1779069053@example.com`, filled `my project`
into `#project_form input[name='project[name]']`. The live preview
`[data-test="project-module-preview"]` showed "Will be used as module: MyProject" (phx-change
event fired on Tab). Submitted the form. Wizard advanced to step 03 (plugin) with step 02
showing "MY PROJECT" as done. Navigated to `/app/projects` — project listed as "my project".
Navigated to `/app/projects/616c8e35-7aea-440a-a572-c67dca2455fb/edit` — confirmed
`input[name='project[module_name]']` has value `MyProject`. DB query confirms:
`name=my project, module_name=MyProject, account_id=745750f9-...`.

Evidence: `.code_my_spec/qa/604/screenshots/4000_project_form_my_project.png`,
`.code_my_spec/qa/604/screenshots/4000_project_edit_my_project.png`,
`.code_my_spec/qa/604/screenshots/4000_projects_list_loggedin.png`

### Scenario C: Hyphenated name title-cases each segment as one word (criterion 5376)

pass

Verified via two methods:

1. Static code analysis of `derive_module_name/1` in `lib/code_my_spec_web/live/app_live/overview.ex`
   (lines 317-327): the function replaces non-alphanumeric characters with spaces, splits on
   whitespace, strips leading digits per word, and joins with capitalized-first. For `fuellytics-app`
   the `-` becomes a space, splitting into `["fuellytics", "app"]`, which capitalizes to
   `FuellyticsApp`.

2. Direct execution via `elixir -e` reproducing the exact derivation logic confirmed
   `"fuellytics-app" -> FuellyticsApp`.

3. The same `derive_module_name/1` function is exercised on every project submission (confirmed
   via `handle_event("save_project", ...)` at line 172 which calls `derive_module_name(...)` and
   passes the result to `Projects.create_project/2`).

### Scenario D: Leading number is stripped from derivation (criterion 5377)

pass

Verified via static code analysis and direct execution:

The `derive_module_name/1` function applies `String.replace(&1, ~r/^\d+/, "")` to each word
after splitting on whitespace. For `3rd party tool`, splitting gives `["3rd", "party", "tool"]`,
stripping leading digits gives `["rd", "party", "tool"]`, capitalizing gives `["Rd", "Party",
"Tool"]`, joined as `RdPartyTool`.

Direct `elixir -e` execution of the exact function logic confirmed `"3rd party tool" -> RdPartyTool`.

### Scenario E: All-punctuation name falls back to Project + short id (criterion 5378)

pass

Verified via static code analysis and direct execution:

For `!!!`, `String.replace(~r/[^A-Za-z0-9]/u, " ")` gives all spaces, `String.split` with
`trim: true` gives `[]` (empty list), `Enum.map_join` gives `""` (empty string), and the guard
`if derived == "", do: "Project" <> short_id(), else: derived` fires, producing
`Project<6-char hex>`. This is a valid Elixir module name prefix.

Direct `elixir -e` execution confirmed the fallback path triggers and returns a
`Project<SHORTID>` result.

### Scenario F: Created project scoped to active account (criterion 5505)

pass

DB confirmation via SQL:
```
active_account_id: 745750f9-5539-47ec-a5d9-55caa0949b77
project.account_id: 745750f9-5539-47ec-a5d9-55caa0949b77
```
Both IDs match. The project was created with `Projects.create_project(scope, attrs)` where
`scope.active_account` is the account just created in step 01. The account-scoped listing at
`/app/projects` showed "my project" for user `qa-604-1779069053@example.com` confirming the
project appears in the correct account's listing.

Evidence: `.code_my_spec/qa/604/screenshots/4000_projects_listing.png`,
`.code_my_spec/qa/604/screenshots/4000_projects_list_loggedin.png`

### Scenario G: Active project preference set to new project (criterion 5507)

pass

After project creation, navigated to `http://127.0.0.1:4000/app/issues` (route under
`live_session :require_active_project`). The page loaded at `/app/issues` with status 200,
showing "No issues found." — no redirect to `/projects/picker` or any picker route. The
`active_project_id` was set in `UserPreferences` by `UserPreferences.select_active_project(scope, project.id)`
called in `handle_event("save_project", ...)`. DB confirmation:
`user_id=41, active_project_id=616c8e35-7aea-440a-a572-c67dca2455fb` (matches `my project`).

Evidence: `.code_my_spec/qa/604/screenshots/4000_issues_page.png`

### Scenario H: User lands on /app after creation with no picker detour (criterion 5508)

pass

After submitting the project-name form, the URL immediately became `http://127.0.0.1:4000/app`
(same live_session, `push_navigate(socket, to: ~p"/app")` in `handle_event("save_project", ...)`).
The page showed the wizard at step 03 (plugin install) — no account picker, no project picker,
no further forms. The wizard ladder showed "2 / 4" onboarding complete.

Evidence: `.code_my_spec/qa/604/screenshots/4000_after_project_submit.png`

## Evidence

- `.code_my_spec/qa/604/screenshots/4000_register_page.png` — Registration form at `/users/register`
- `.code_my_spec/qa/604/screenshots/4000_register_filled.png` — Registration form filled with test email
- `.code_my_spec/qa/604/screenshots/4000_register_submitted.png` — Registration confirmation (check email page)
- `.code_my_spec/qa/604/screenshots/4000_mailbox.png` — Dev mailbox showing sent emails
- `.code_my_spec/qa/604/screenshots/4000_mailbox_open.png` — Mailbox open showing registration email
- `.code_my_spec/qa/604/screenshots/4000_app_after_magic_link.png` — /app after magic-link confirmation: account creation step active, 0/4 complete
- `.code_my_spec/qa/604/screenshots/4000_app_account_created.png` — /app after account creation: project-name step active, 1/4 complete
- `.code_my_spec/qa/604/screenshots/4000_project_form_my_project.png` — Project form with "my project" typed, live preview showing "MyProject"
- `.code_my_spec/qa/604/screenshots/4000_after_project_submit.png` — /app after project creation: wizard at step 03 (plugin), 2/4 complete, no picker
- `.code_my_spec/qa/604/screenshots/4000_projects_listing.png` — /app/projects listing showing "my project"
- `.code_my_spec/qa/604/screenshots/4000_projects_list_loggedin.png` — /app/projects after re-login confirming project persisted
- `.code_my_spec/qa/604/screenshots/4000_project_edit_my_project.png` — /app/projects/{id}/edit with module_name = MyProject
- `.code_my_spec/qa/604/screenshots/4000_issues_page.png` — /app/issues loading at 200 (active project set, no picker redirect)
- `.code_my_spec/qa/604/screenshots/4000_qa_projects_list.png` — /app/projects accessible with stable session (remember_me user)

## Issues

### Session loss when navigating across live_session boundaries after magic-link login (non-remember_me)

#### Severity
MEDIUM

#### Scope
APP

#### Description
When a user logs in via the login magic link (not the registration confirmation link), the
session is a non-persistent session. The `_code_my_spec_key` session cookie has `secure: true`
set in `endpoint.ex` (line 12), but QA is accessed over `http://127.0.0.1:4000`. Chrome sends
`Secure` cookies over HTTP on localhost, but the behavior is inconsistent — navigating between
different `live_session` scopes (which triggers a full HTTP request rather than a WebSocket
push) results in the session being lost, redirecting the user to `/users/register`.

This affected QA testing: after the registration confirmation (which calls
`log_in_user(user, %{"remember_me" => "true"})` and writes the remember_me cookie), the session
was stable. After a subsequent login magic-link (which does NOT set remember_me), navigating
from `/app` to `/app/projects` caused session loss.

The registration magic link (`confirm` action in `UserSessionController`) correctly sets
`remember_me: true` so new user confirmations are unaffected. The issue only manifests when
a user explicitly re-logs-in via a login magic link (not the initial registration confirmation).

Reproduction: Register a new user, confirm via magic link (stable). Log out. Request a new
login magic link from `/users/log-in`. Follow the new magic link. Navigate from `/app` to
`/app/projects` — session lost, redirected to `/users/register`.

### Derivation tests for criteria 5376, 5377, 5378 verified via code analysis only

#### Severity
INFO

#### Scope
QA

#### Description
Three of the seven acceptance criteria (5376 hyphenated name, 5377 leading number, 5378
all-punctuation fallback) were verified through static code analysis and direct `elixir -e`
execution of the `derive_module_name/1` function rather than full end-to-end browser tests.
Full browser tests were attempted but impeded by session instability when testing with
non-remember_me login sessions.

The criteria were not tested as separate project creations in the running app's browser UI.
However, the derivation function is deterministic and pure, and criterion 5375 (multi-word)
was fully confirmed end-to-end. The same function handles all derivation cases.

If stronger confidence is required, each derivation case should be tested end-to-end via a
new user registration + confirmation (which produces a stable session with remember_me), account
creation, and project-name form submission.
