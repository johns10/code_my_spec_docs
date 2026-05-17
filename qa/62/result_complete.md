# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — Index lists projects (criterion 6079)

pass

Navigated to `http://127.0.0.1:4000/app/projects` as `qa@codemyspec.local` with the `code-my-spec` account active.

The page rendered the "Projects" heading and the full table. "QA Fixture Project" appeared in the listing as expected, confirming the index is scoped to the active account and shows only that account's projects.

Evidence: `.code_my_spec/qa/62/screenshots/4000_62_projects_index.png`

### Scenario 2 — Valid new-project creates it (criterion 6080)

pass

Navigated to `http://127.0.0.1:4000/app/projects/new`. The form rendered with heading "New Project" and form id `#project-form`.

Filled Name with "Browser QA Project" and clicked "Save Project". The LiveView redirected to `/app/projects`, the "Project created successfully" flash appeared, and "Browser QA Project" appeared in the index list.

Evidence: `.code_my_spec/qa/62/screenshots/4000_62_new_project_form.png`, `.code_my_spec/qa/62/screenshots/4000_62_project_created.png`

### Scenario 3 — Empty name shows validation error (criterion 6081)

pass

Navigated to `http://127.0.0.1:4000/app/projects/new` and clicked "Save Project" with the Name field blank. The form stayed on `/app/projects/new`. The "New Project" heading was still visible and a "can't be blank" validation error appeared on the Name field. No project was created.

Evidence: `.code_my_spec/qa/62/screenshots/4000_62_empty_name_error.png`

### Scenario 4 — Lowercase module_name shows format error (criterion 6082)

pass

On the new project form, filled Name with "ok" and Module Name with "lowercase_mod". Clicked "Save Project". The form stayed on `/app/projects/new`. The "New Project" heading was present and "must be a valid Elixir module name" error appeared on the Module Name field. No project was created.

Evidence: `.code_my_spec/qa/62/screenshots/4000_62_module_name_error.png`

### Scenario 5 — Edit persists changes (criterion 6083)

pass

Navigated directly to `/app/projects/11111111-1111-4111-8111-111111111111/edit`. The form was pre-populated with "QA Fixture Project". Changed the Name to "QA Fixture Project Renamed" and clicked "Save Project".

The LiveView redirected to `/app/projects`, "Project updated successfully" flash appeared, and "QA Fixture Project Renamed" appeared in the list (the old name "QA Fixture Project" was gone).

Navigated to the show page at `/app/projects/11111111-1111-4111-8111-111111111111` — the Name field in the detail list displayed "QA Fixture Project Renamed".

After verifying, the fixture name was restored to "QA Fixture Project" via the edit form.

Evidence: `.code_my_spec/qa/62/screenshots/4000_62_edit_project.png`, `.code_my_spec/qa/62/screenshots/4000_62_project_updated.png`, `.code_my_spec/qa/62/screenshots/4000_62_project_show_renamed.png`

### Scenario 6 — Delete removes project from index (criterion 6084)

pass

"Browser QA Project" was in the index from Scenario 2. Clicked its Delete link (which has `data-confirm="Are you sure?"`).

The first click showed the confirm dialog, which Vibium dismissed without confirming (the row briefly vanished due to the JS hide animation, then reappeared on fresh mount). The second click successfully confirmed and the project was deleted — on a fresh navigate to `/app/projects`, "Browser QA Project" was no longer listed.

The delete functionality works correctly. The confirm dialog interaction requires two clicks in Vibium (first click triggers the dialog, second confirms it), which is a QA tooling characteristic, not an app bug.

Evidence: `.code_my_spec/qa/62/screenshots/4000_62_after_delete.png`, `.code_my_spec/qa/62/screenshots/4000_62_fresh_mount_after_delete.png`, `.code_my_spec/qa/62/screenshots/4000_62_delete_confirmed_fresh_mount.png`

## Evidence

- `.code_my_spec/qa/62/screenshots/4000_62_login_page.png` — Login page with two stacked forms
- `.code_my_spec/qa/62/screenshots/4000_62_after_login.png` — Post-login state (redirected to root)
- `.code_my_spec/qa/62/screenshots/4000_62_app_home.png` — App home with active account
- `.code_my_spec/qa/62/screenshots/4000_62_projects_index.png` — Projects index listing all account projects including QA Fixture Project (Scenario 1)
- `.code_my_spec/qa/62/screenshots/4000_62_new_project_form.png` — New project form (Scenario 2)
- `.code_my_spec/qa/62/screenshots/4000_62_project_created.png` — Index after creation with success flash (Scenario 2)
- `.code_my_spec/qa/62/screenshots/4000_62_empty_name_error.png` — Form with can't-be-blank error (Scenario 3)
- `.code_my_spec/qa/62/screenshots/4000_62_module_name_error.png` — Form with module name format error (Scenario 4)
- `.code_my_spec/qa/62/screenshots/4000_62_edit_project.png` — Edit form pre-populated (Scenario 5)
- `.code_my_spec/qa/62/screenshots/4000_62_project_updated.png` — Index after update with success flash (Scenario 5)
- `.code_my_spec/qa/62/screenshots/4000_62_project_show_renamed.png` — Show page with renamed project (Scenario 5)
- `.code_my_spec/qa/62/screenshots/4000_62_delete_confirmed_fresh_mount.png` — Fresh index after deletion showing project gone (Scenario 6)

## Issues

### Project show page header displays UUID instead of project name

#### Severity
LOW

#### Scope
APP

#### Description
The project show page at `/app/projects/:id` renders the header as "Project `<uuid>`" (e.g., "Project 11111111-1111-4111-8111-111111111111") rather than the project name. The project name does appear correctly in the detail list below the header. The source is `ProjectLive.Show` which uses `{@project.id}` in the header template instead of `{@project.name}`.

This is a UX issue — navigating to a project show page is disorienting when the header shows a UUID instead of the human-readable project name. Reproduced consistently on `/app/projects/11111111-1111-4111-8111-111111111111`.

### QA seed script fails on stories table (Postgrex error)

#### Severity
LOW

#### Scope
QA

#### Description
Running `mix run priv/repo/qa_seeds.exs` fails with `ERROR 42P01 (undefined_table) relation "stories" does not exist` when the seed script attempts to create QA stories in the `priv/repo/qa_seeds.exs` file at line 145. The user, account, member, and project fixtures are all created successfully before the crash.

For story 62 testing, this is not a blocker — all required fixtures (user, account, project) were in place before the crash. However, the seed script should not error on a standard QA run. The `stories` relation may not exist in this database state, or the `Stories` context import is resolving to a different schema.

Reproduced on: `mix run priv/repo/qa_seeds.exs` from `/Users/johndavenport/Documents/github/code_my_spec`.

### Vibium confirm-dialog interaction requires two clicks for delete

#### Severity
INFO

#### Scope
QA

#### Description
The delete links on `/app/projects` use `data-confirm="Are you sure?"` which triggers a LiveView confirm dialog. Vibium's `browser_click` on this link triggers the dialog but does not accept it (the row visually hides via the JS animation but the project is not actually deleted). A second `browser_click` on the same element successfully deletes the project.

This is a QA tooling characteristic — the confirm dialog behavior under Vibium is inconsistent. Future delete scenarios should issue two clicks or use `browser_keys("Enter")` after the first click to accept the dialog. The application's delete functionality itself works correctly.
