# Qa Result

Story 712: Local-first content publishing — CLI parses, validates, uploads to user-owned S3, triggers client

## Status

partial

## Scenarios

### Scenario 1: Admin LiveView loads and shows empty state

pass

Navigated to `http://127.0.0.1:4000/app/content_admin` as the QA user (`qa@codemyspec.local`).
The page rendered the ContentAdmin LiveView with the expected header "ContentAdmin", action buttons
("Sync from Git" and "Push to Client"), status badges showing "0 Published" and "0 Errors",
type and status filter dropdowns, and the empty state message "No content_admin synced yet."
All expected UI elements confirmed present via curl HTML inspection.

Evidence: `.code_my_spec/qa/712/screenshots/content_admin_index.html`

### Scenario 2: Auth gate — unauthenticated redirect

pass

GET `http://127.0.0.1:4000/app/content_admin` without a session cookie returned HTTP 302 redirect
to `http://127.0.0.1:4000/users/log-in`. Auth gating is correctly enforced on the
`require_active_project` live session. The login page rendered correctly with both
magic-link and password forms.

Evidence: `.code_my_spec/qa/712/screenshots/login_redirect.html`

### Scenario 3: Sync from Git button — no docs_repo configured

partial

Verified via code inspection and project data that the QA fixture project (`11111111-1111-4111-8111-111111111111`)
has `docs_repo: nil`. The `ContentSync.sync_to_content_admin/1` function returns `{:error, :no_docs_repo}`
when `docs_repo` is nil or empty, and the LiveView handler maps this to the flash error
"Project has no docs repository configured". This code path is correctly implemented and
would display the error on button click.

Could not directly trigger the LiveView event via curl (browser session required for LiveView
phx-click events). Vibium MCP browser tools were unavailable in this session.

### Scenario 4: Push to Client button — no client config

partial

Verified via code inspection that the QA fixture project has `client_api_url: nil` and `deploy_key: nil`.
The `ContentSync.push_to_client/1` function returns `{:error, :no_client_config}` and the LiveView
handler displays an error modal with type "Missing Client Configuration" and instructions to configure
the Client API URL and Deploy Key in Project Settings.

The `assign_push_error/4` helper and the `push-error-modal` dialog component are correctly implemented
in the source. Could not trigger the phx-click event directly via curl.

### Scenario 5: Type and status filter UI interaction

pass

Verified that all filter dropdown options are present in the rendered HTML:
- Type filter: "All Types", "Blog", "Page", "Landing" 
- Status filter: "All Status", "Success", "Error", "Pending"
- "Clear Filters" button renders conditionally (`:if={@filter_type || @filter_status}`)
- Filter events (`filter-type`, `filter-status`, `clear-filters`) are implemented in the LiveView

LiveView event-driven interactions (phx-change, phx-click) could not be exercised without Vibium.

### Scenario 6: Individual content show route — non-existent item

fail

GET `http://127.0.0.1:4000/app/content_admin/99999999` (authenticated) returned HTTP 404.
The page title in the response was `Ecto.NoResultsError at GET /app/content_admin/99999999`.
The `ContentAdmin.get_content!/2` function raises `Ecto.NoResultsError` which surfaces as an
unhandled exception rather than a friendly error page or redirect. In a production app this
would expose an error detail page to users.

### Scenario 7: Local port 4003 — no content admin route

fail

GET `http://127.0.0.1:4003/admin/content` returned HTTP 404 ("Not Found"). The local web
router (`CodeMySpecLocalWeb.Router`) has no content admin route. The acceptance criterion
"Admin LiveView renders parse status without hitting the SaaS" is not implemented. The local
LiveView admin surface described in the story description as `:4003/admin/content` does not exist.

### Scenario 8: Story-level gap assessment — CLI publishing pipeline

fail

Reviewed all acceptance criteria against the codebase. The following criteria are NOT implemented:

- "Sam syncs a plain non-Git folder and the pipeline runs end-to-end" — `sync_to_content_admin` only
  supports Git repos via `docs_repo`. No plain-folder sync path exists.
- "Images upload to the user's S3 image bucket on sync" — no image upload code in ContentSync.
- "Markdown image URLs rewrite to CDN host before persistence" — no URL rewriting in the sync pipeline.
- "Replaced hero image goes live immediately via CF purge" — no Cloudflare cache purge code found.
- "Publish writes manifest + blob to user's content bucket" — `push_to_client` POSTs content
  directly to `/api/content/sync` on the client; no S3 manifest write, no `content_blob_url`,
  no `content_blob_hash` (sha256).
- "Client gets pull trigger and fetches the manifest from S3" — the push flow is a direct POST,
  not a manifest-based pull trigger to `/api/content/pull`.

Implemented criteria:
- "One malformed frontmatter doesn't abort the sync" — parse_status per-record with `{:ok, attrs_list}`
  continuing past errors is implemented in `Sync.process_directory/1`.
- "Admin LiveView renders parse status" — the hosted `ContentAdminLive` shows parse_status badges.
- "Publish aborts when parse errors remain" — `verify_no_validation_errors/1` blocks push when error count > 0.

## Evidence

- `.code_my_spec/qa/712/screenshots/content_admin_index.html` — HTML snapshot of the ContentAdmin
  index page showing empty state, status badges, filter dropdowns, and action buttons
- `.code_my_spec/qa/712/screenshots/login_redirect.html` — HTML snapshot of the login page
  that unauthenticated requests are redirected to

## Issues

### ContentAdminLive.Show raises Ecto.NoResultsError for unknown IDs

#### Severity
LOW

#### Scope
APP

#### Description
Visiting `http://127.0.0.1:4000/app/content_admin/99999999` as an authenticated user returns a 404
page with `Ecto.NoResultsError at GET /app/content_admin/99999999` as the page title. The
`ContentAdmin.get_content!/2` function raises on missing records. A user-friendly redirect to the
index with a flash message would be more appropriate. Reproduced with any non-existent integer ID.

### Local port (4003) has no content admin route

#### Severity
HIGH

#### Scope
APP

#### Description
The story acceptance criterion "Admin LiveView renders parse status without hitting the SaaS" and
the story description reference `:4003/admin/content` as the local admin surface. No such route
exists in `CodeMySpecLocalWeb.Router`. The local web app (port 4003/4004) has no content admin
LiveView. Users must use the hosted SaaS UI at port 4000 to view parse status, which contradicts
the local-first design intent of this story.

### S3 image upload and CDN image URL rewrite not implemented

#### Severity
HIGH

#### Scope
APP

#### Description
Three acceptance criteria require image upload and URL rewriting:
- "Images upload to the user's S3 image bucket on sync"
- "Markdown image URLs rewrite to CDN host before persistence"
- "Replaced hero image goes live immediately via CF purge"

No image upload code, URL rewriting, or Cloudflare cache purge is present in `ContentSync` or
any module called by it. The sync pipeline (`Sync.process_directory/1`) parses markdown and
YAML frontmatter but does not process embedded images.

### Manifest-based publish and S3 content blob not implemented

#### Severity
HIGH

#### Scope
APP

#### Description
The acceptance criteria require:
- "Publish writes manifest + blob to user's content bucket" with fields `version`, `generated_at`,
  `content_blob_url`, `content_blob_hash` (sha256), optional `counts` per content_type
- "Client gets pull trigger and fetches the manifest from S3" via `POST /api/content/pull`

The actual `push_to_client/1` implementation POSTs the full content payload directly to
`/api/content/sync` on the client appliance. There is no S3 write, no manifest JSON, no
`content_blob_url` or `content_blob_hash`, and the client endpoint is `/api/content/sync`
not `/api/content/pull`. The manifest-based pull architecture described in the story is not
implemented.

### Plain non-Git folder sync not implemented

#### Severity
MEDIUM

#### Scope
APP

#### Description
Acceptance criterion: "Sam syncs a plain non-Git folder and the pipeline runs end-to-end."
The `sync_to_content_admin/1` function requires a `docs_repo` Git URL on the project and clones
via Git. No `sync_directory_to_content_admin/2` is exposed from the LiveView — only `sync_to_content_admin/1`
which requires Git. A public method exists (`CodeMySpec.ContentSync.sync_directory_to_content_admin/2`)
but it is not wired into the UI or CLI surface described in the story.

### Vibium MCP browser tools unavailable

#### Severity
MEDIUM

#### Scope
QA

#### Description
The `mcp__vibium__browser_*` tools were not available in this QA session. As a result, interactive
LiveView scenarios (phx-click button presses for "Sync from Git" and "Push to Client", filter
interactions, and modal open/close flows) could not be exercised end-to-end in the browser.
Testing fell back to curl HTML inspection and code review. Scenarios 3 and 4 were verified
through code analysis only, not live button interaction.
