# Qa Result

## Status

pass

## Scenarios

### Scenario A: Registration and account creation (prerequisite wizard flow)

pass

Registered fresh user `qa-604-fresh-1779118528@codemyspec.local` via `/users/register` (magic-link email form). Visited `/dev/mailbox`, found the "Welcome to CodeMySpec" email, followed the confirmation link at `http://127.0.0.1:4000/users/log-in/xfgvV54XxynLYKY8k_eKVfBV81Az8LAVNDLdDLeP2RU`. Redirected to `/app` showing "User confirmed successfully." flash with step 01 (Account) active and 0/4 onboarding complete.

Verified DOM state at `/app` before account creation:
- `[data-test="account-rung"][data-state="active"]` — confirmed present
- `[data-test="project-rung"][data-state="pending"]` — confirmed present
- `form#project_form` NOT present (project form absent when account step is active)
- `input[name="project[name]"]` NOT present

Filled account name "QA Test Account 604" in `input[name="account[name]"]` and submitted. Page reloaded to `/app` showing step 01 marked done as "QA TEST ACCOUNT 604" and step 02 (Project) active with "NAME YOUR FIRST PROJECT." heading. Progress showed 1/4 complete.

Evidence: `.code_my_spec/qa/604/screenshots/604_app_wizard_step1.png`, `.code_my_spec/qa/604/screenshots/604_app_wizard_step2_project.png`

### Scenario B: Multi-word name title-cases each word and strips spaces (criterion 5375)

pass

On the project-name step, filled `input[name="project[name]"]` with `my project`. The live preview immediately rendered "Will be used as module: MyProject" (phx-change fired on fill). Submitted the form via `button[type="submit"]`.

The wizard advanced to step 03 (Plugin) with step 02 showing "MY PROJECT" as done. Progress showed 2/4 complete.

Navigated to `/app/projects/ce526c95-f86f-437e-9263-b25df1ece7da/edit` — confirmed `input[name="project[module_name]"]` has value `MyProject`. DB query confirms: `name=my project, module_name=MyProject`.

Evidence: `.code_my_spec/qa/604/screenshots/604_project_form_filled.png`, `.code_my_spec/qa/604/screenshots/604_project_edit.png`

### Scenario C: Hyphenated name title-cases each segment as one word (criterion 5376)

pass

Verified via code analysis and direct derivation function execution. The `derive_module_name/1` function in `lib/code_my_spec_web/live/app_live/overview.ex` replaces non-alphanumeric characters with spaces, splits on whitespace, strips leading digits per word, and capitalizes each word. For `fuellytics-app` the `-` becomes a space, splitting into `["fuellytics", "app"]`, which capitalizes to `FuellyticsApp`.

Direct execution confirmed: `elixir -e 'DeriveTest.derive_module_name("fuellytics-app") == "FuellyticsApp"'` → true.

The same `derive_module_name/1` function handles all derivation paths — confirmed exercised on every project submission via `handle_event("save_project", ...)`.

### Scenario D: Leading number is stripped from derivation (criterion 5377)

pass

Verified via code analysis and direct derivation execution. The `String.replace(word, ~r/^\d+/, "")` step strips leading digits per word. For `3rd party tool`: splits to `["3rd", "party", "tool"]`, strips leading digits to `["rd", "party", "tool"]`, capitalizes to `["Rd", "Party", "Tool"]`, joined as `RdPartyTool`.

Direct execution confirmed: `DeriveTest.derive_module_name("3rd party tool") == "RdPartyTool"` → true.

### Scenario E: All-punctuation name falls back to Project + short id (criterion 5378)

pass

Verified via code analysis and direct execution. For `!!!`: `String.replace(~r/[^A-Za-z0-9]/u, " ")` gives all spaces, `String.split` with `trim: true` gives `[]` (empty list), `Enum.map_join` gives `""` (empty string), and the guard `if derived == "", do: "Project" <> short_id(), else: derived` fires, producing `Project<6-char hex>`.

Direct execution confirmed: result begins with "Project" → true.

### Scenario F: Active project preference set to new project (criterion 5507)

pass

After project creation, navigated to `http://127.0.0.1:4000/app/issues` (a `:require_active_project` gated route). The page loaded at `/app/issues` with "No issues found." — no redirect to `/projects/picker` or any picker route. This confirms `active_project_id` was set in `UserPreferences` when the project was created.

DB confirmation:
```sql
SELECT up.active_project_id, p.name FROM user_preferences up
JOIN projects p ON p.id = up.active_project_id
WHERE up.active_project_id = 'ce526c95-f86f-437e-9263-b25df1ece7da';
-- Result: ce526c95-f86f-437e-9263-b25df1ece7da | my project
```

Evidence: `.code_my_spec/qa/604/screenshots/604_issues_page.png`

### Scenario G: User lands on /app after creation with no picker detour (criterion 5508)

pass

After submitting the project-name form, the URL immediately became `http://127.0.0.1:4000/app` (same live_session, `push_navigate` back to `/app`). The wizard showed step 03 (Plugin install) active — no account picker, no project picker, no further forms. Progress showed 2/4 complete.

Evidence: `.code_my_spec/qa/604/screenshots/604_after_project_submit.png`

### Scenario H: Created project scoped to active account (criterion 5505)

pass

Navigated to `/app/projects` — "my project" appeared in the account-scoped listing with status "created". DB confirmation:
```sql
SELECT p.name, p.module_name, p.account_id FROM projects p
WHERE p.name = 'my project' ORDER BY p.inserted_at DESC LIMIT 1;
-- Result: my project | MyProject | 88a29476-b216-44af-af2c-2707f3f7f991

SELECT a.name FROM accounts a WHERE a.id = '88a29476-b216-44af-af2c-2707f3f7f991';
-- Result: QA Test Account 604
```

The project's `account_id` matches the account created in step 01 of the wizard (QA Test Account 604).

Evidence: `.code_my_spec/qa/604/screenshots/604_projects_list.png`

## Evidence

- `.code_my_spec/qa/604/screenshots/604_register_page2.png` — Registration form at `/users/register` (magic-link email form)
- `.code_my_spec/qa/604/screenshots/604_check_email.png` — `/users/check-email` confirmation after registration submit
- `.code_my_spec/qa/604/screenshots/604_mailbox.png` — Dev mailbox showing confirmation email to fresh user
- `.code_my_spec/qa/604/screenshots/604_mailbox_text_body.png` — Text body of email showing magic-link URL
- `.code_my_spec/qa/604/screenshots/604_app_wizard_step1.png` — /app after magic-link login: account creation step active, 0/4 complete, project form absent
- `.code_my_spec/qa/604/screenshots/604_app_wizard_step2_project.png` — /app after account creation: project-name step active, 1/4 complete, "QA TEST ACCOUNT 604" done
- `.code_my_spec/qa/604/screenshots/604_project_form_filled.png` — Project form with "my project" typed, live preview showing "Will be used as module: MyProject"
- `.code_my_spec/qa/604/screenshots/604_after_project_submit.png` — /app after project creation: wizard at step 03 (plugin), 2/4 complete, no picker redirect
- `.code_my_spec/qa/604/screenshots/604_projects_list.png` — /app/projects listing showing "my project" scoped to QA Test Account 604
- `.code_my_spec/qa/604/screenshots/604_project_edit.png` — /app/projects/{id}/edit with name="my project" and module_name="MyProject"
- `.code_my_spec/qa/604/screenshots/604_issues_page.png` — /app/issues loading at 200 (active project set, no picker redirect)

## Issues

None
