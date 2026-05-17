# Qa Story Brief

## Tool

web (Vibium MCP browser tools — all routes are LiveView on the `:browser` pipeline at port 4000)

## Auth

Password login via the hosted app at `http://127.0.0.1:4000/users/log-in`.

The page renders two stacked forms. Scope to the password form to avoid filling the magic-link form:
- Email field: `form[action="/users/log-in"] input[name='user[email]']`
- Password field: `form[action="/users/log-in"] input[name='user[password]']`

Credentials (created by the seed script):
- Email: `qa@codemyspec.local`
- Password: `qa-password-123!`

After logging in you must select an active account. The QA account slug is `qa-account`. Navigate to `http://127.0.0.1:4000/app` after login and set the active account if prompted, or navigate directly to `http://127.0.0.1:4000/app/accounts` to switch to `qa-account`.

## Seeds

Run once before testing:

```
cd /Users/johndavenport/Documents/github/code_my_spec && mix run priv/repo/qa_seeds.exs
```

This creates:
- User `qa@codemyspec.local` / `qa-password-123!`
- Account `qa-account`
- Project `QA Fixture Project` (id `11111111-1111-4111-8111-111111111111`)

No additional story-specific seeds are needed — tests create their own projects via the UI.

## What To Test

### Scenario 1 — Index lists projects (criterion 6079)

- Navigate to `http://127.0.0.1:4000/users/log-in` and authenticate with QA credentials
- Set active account to `qa-account` if not already set
- Navigate to `http://127.0.0.1:4000/app/projects`
- Assert the page renders a "Projects" heading
- Assert "QA Fixture Project" appears in the list (created by seeds)
- Screenshot the index

### Scenario 2 — Valid new-project creates it (criterion 6080)

- Navigate to `http://127.0.0.1:4000/app/projects/new`
- Assert the form renders with heading "New Project" and form id `#project-form`
- Fill the Name field with a unique name (e.g. `Browser QA Project`)
- Submit the form (click "Save Project")
- Expect redirect to `/app/projects`
- Assert "Project created successfully" flash appears
- Assert "Browser QA Project" appears in the index list
- Screenshot the index with the success flash

### Scenario 3 — Empty name shows validation error (criterion 6081)

- Navigate to `http://127.0.0.1:4000/app/projects/new`
- Submit the form with the Name field left blank
- Expect the form to re-render (stay on `/app/projects/new`)
- Assert "New Project" heading is still visible (form not navigated away)
- Assert a "can't be blank" error message appears on the form
- Screenshot the validation error state

### Scenario 4 — Lowercase module_name shows format error (criterion 6082)

- Navigate to `http://127.0.0.1:4000/app/projects/new`
- Fill Name with "ok"
- Fill Module Name with "lowercase_mod" (lowercase, starts with lowercase)
- Submit the form
- Expect the form to re-render
- Assert "must be a valid Elixir module name" error appears
- Screenshot the error state

### Scenario 5 — Edit persists changes (criterion 6083)

- Navigate to `http://127.0.0.1:4000/app/projects`
- Find the "QA Fixture Project" row and click its Edit link (or navigate to `/app/projects/11111111-1111-4111-8111-111111111111/edit`)
- Change the Name field to "QA Fixture Project Renamed"
- Submit (click "Save Project")
- Expect redirect to `/app/projects`
- Assert "Project updated successfully" flash
- Assert "QA Fixture Project Renamed" appears in the list
- Navigate to the project show page (`/app/projects/11111111-1111-4111-8111-111111111111`)
- Assert "QA Fixture Project Renamed" appears there too
- Screenshot each state

### Scenario 6 — Delete removes project from index (criterion 6084)

- Create a project to delete (use the UI from Scenario 2, or any existing project other than the fixture)
- Navigate to `http://127.0.0.1:4000/app/projects`
- Locate the row for the project to delete and click "Delete"
- Accept the confirm dialog
- Assert the row disappears from the list
- Navigate back to `/app/projects` fresh
- Assert the deleted project is no longer listed
- Screenshot the index after deletion

## Setup Notes

The show page at `/app/projects/:id` uses the project's UUID as the path parameter. The QA Fixture Project UUID is `11111111-1111-4111-8111-111111111111`. After edit, restore the name to "QA Fixture Project" or use a throwaway project to avoid state bleed across runs.

The Delete link in the table uses `data-confirm="Are you sure?"` — Vibium should handle the browser dialog automatically. If the confirm dialog blocks, use `browser_press` with Enter to accept it.

Screenshots should be saved with the naming convention `4000_62_<scenario>.png` and will be written to `~/Pictures/Vibium/`. Copy them to `.code_my_spec/qa/62/screenshots/` at the end of the run.

## Result Path

`.code_my_spec/qa/62/result.md`
