# Qa Story Brief

Story 712: Local-first content publishing — CLI parses, validates, uploads to user-owned S3, triggers client

## Tool

web

## Auth

Log in via Vibium browser tools at `http://127.0.0.1:4000/users/log-in` using the password form:
- Email: `qa@codemyspec.local`
- Password: `qa-password-123!`

Use the password form (the second form on the login page). The scope selector
`form[action="/users/log-in"] input[name='user[email]']` disambiguates from
the magic-link form.

After login, navigate to `/app` to confirm authentication and verify an active
account and project are in scope before testing the content admin routes.

## Seeds

Run base QA seeds:

```
mix run priv/repo/qa_seeds.exs
```

This creates the QA user, account, and project (id `11111111-1111-4111-8111-111111111111`).

No story-specific content admin seeds are needed — the "Sync from Git" button
can be triggered from the UI, but requires a `docs_repo` configured on the
active project. Absence of `docs_repo` is itself a testable error path.

## What To Test

The testable surface for this story is the hosted `ContentAdminLive` UI at
`http://127.0.0.1:4000/app/content_admin`, which is in the
`require_active_project` live session on the hosted Phoenix endpoint (port 4000).

The story's local-first CLI pipeline (S3 upload, image ingest, CF purge,
manifest publish, pull trigger) has no corresponding route in the local web
router (port 4003/4004) and no CLI command surface to exercise via these
tools — those capabilities are out of scope for this QA pass and will be
noted as implementation gaps.

### Scenario 1: Admin LiveView loads and shows empty state

- Navigate to `http://127.0.0.1:4000/app/content_admin`
- Confirm the page renders the ContentAdmin header
- Confirm status badge counts (Published / Errors) are visible
- Confirm the empty state message "No content_admin synced yet" appears when no records exist
- Confirm type and status filter dropdowns are present
- Capture screenshot

### Scenario 2: Auth gate — unauthenticated redirect

- Without a session, GET `http://127.0.0.1:4000/app/content_admin`
- Confirm redirect to `/users/log-in` (302 or LiveView redirect)
- Capture screenshot of redirected page

### Scenario 3: Sync from Git button — no docs_repo configured

- While logged in on `/app/content_admin`, click "Sync from Git"
- Confirm flash error message: "Project has no docs repository configured"
  (this maps to the `:error, :no_docs_repo` branch in `ContentSync.sync_to_content_admin/1`)
- Capture screenshot of the error state

### Scenario 4: Push to Client button — no client config

- While on `/app/content_admin`, click "Push to Client"
- Confirm an error modal appears (the push-error-modal dialog)
- Confirm the modal shows "Missing Client Configuration" error type and a message
  about configuring Client API URL and Deploy Key
- Confirm the modal can be closed via the X button
- Capture screenshot of the error modal

### Scenario 5: Type and status filter UI interaction

- On `/app/content_admin`, interact with the "Type" filter dropdown
- Select "Blog" from the filter — confirm the filter is applied (list may be empty, that is OK)
- Select "All Types" to clear — confirm filter clears
- Interact with the "Status" filter — select "Error"
- Confirm the "Clear Filters" button appears when a filter is active
- Click "Clear Filters" — confirm it resets both filters
- Capture screenshot

### Scenario 6: Individual content show route — non-existent item

- Navigate to `http://127.0.0.1:4000/app/content_admin/99999999`
- Confirm the app raises an error or redirects (not a blank page crash)
- Capture screenshot

### Scenario 7: Local port 4003 — no content admin route

- Navigate to `http://127.0.0.1:4003/admin/content`
- Confirm a 404 / no-route error (this route is not in the local web router)
- This confirms the acceptance criterion "Admin LiveView renders parse status
  without hitting the SaaS" is NOT yet implemented on the local port
- Capture screenshot as evidence of the gap

## Setup Notes

The acceptance criteria reference several capabilities that require infrastructure
not present in the current implementation:

- S3/R2 bucket configuration, image upload, Cloudflare cache purge — no
  corresponding code paths found in the hosted or local web routers
- Local CLI commands for content sync/publish — the local web router
  (`CodeMySpecLocalWeb.Router`) has no content admin or content publish routes
- "Admin LiveView renders parse status without hitting the SaaS" — the local
  port (4003) has no `/admin/content` route; this criterion is unmet
- Manifest JSON + S3 blob write + HTTP pull trigger — not present in the
  content sync pipeline reviewed (`ContentSync.push_to_client/1` POSTs
  directly to `/api/content/sync`, not a manifest-based pull flow)

These gaps should be documented as issues in the result.

## Result Path

`.code_my_spec/qa/712/result.md`
