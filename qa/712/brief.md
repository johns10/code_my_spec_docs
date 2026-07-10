# Qa Story Brief

Story 712: Local-first content publishing — CLI parses, validates, uploads to user-owned S3, triggers client

## Tool

web (Vibium MCP browser tools for LiveView at `http://localhost:4004`) + curl for the consumer pull API at `https://dev.codemyspec.com`

## Auth

Local web (port 4004) requires no authentication — `LocalOnly` plug accepts all loopback requests directly. Navigate to `http://localhost:4004/projects/code-my-spec/content`.

The consumer pull API at `https://dev.codemyspec.com/api/content/pull` requires `Authorization: Bearer <deploy_key>`. The deploy key is stored encrypted in the project config (visible in the admin UI under "Source & publishing settings" after expanding the `<details>` element).

## Seeds

No seed scripts needed. The project "Code My Spec" is already configured with 116 posts synced and published:
- `content_source_path`: `.code_my_spec/content`
- `client_api_url`: `https://dev.codemyspec.com`
- `content_bucket`: `content.codemyspec.com`
- `image_bucket`: `images.codemyspec.com`
- `images_host`: `https://images.codemyspec.com`

## Setup Notes

The "Source & publishing settings" section lives inside a `<details>` collapsible at the top of the page. Click its `<summary>` to expand it before interacting with `[data-test='content-source-form']` or `[data-test='content-settings-form']`.

## What To Test

### Scenario 1: Admin LiveView renders parse status without SaaS (AC: Admin LiveView renders parse status without hitting the SaaS)
- Navigate to `http://localhost:4004/projects/code-my-spec/content`
- Verify the page loads and shows data from the local snapshot (not a remote call)
- Verify `[data-test='last-sync-at']` renders a timestamp
- Verify `[data-test='sync-button']` is present
- Verify `[data-test='publish-button']` is present
- Verify `[data-test^='content-row-']` elements are present with `data-parse-status` attributes
- Capture screenshot of the full page

### Scenario 2: Sync runs end-to-end on plain folder (AC: Sam syncs a plain non-Git folder and the pipeline runs end-to-end; One malformed frontmatter doesn't abort the sync)
- Click `[data-test='sync-button']`
- Wait for sync to complete
- Verify success/error summary text (e.g. "116 success, 0 error")
- Verify no git clone/fetch/pull errors appear
- Capture screenshot of post-sync state

### Scenario 3: Per-row data attributes and detail page (AC: Admin LiveView renders parse status without hitting the SaaS)
- From the content list, verify at least one row has `data-parse-status='success'`
- Click a "View" link to the detail page
- Verify whether `[data-test='processed-content-<slug>']` renders (or file issue if page crashes)
- Capture screenshot

### Scenario 4: Publish button — clean snapshot publishes (AC: Publish writes manifest + blob to user's content bucket; Client gets pull trigger)
- With a clean snapshot (no parse errors), click `[data-test='publish-button']`
- Wait for publish to complete
- Verify a publish toast/summary appears showing counts
- Verify no `[data-test='publish-error']` appears
- If a `[data-test='publish-sync-id']` element appears, capture it as evidence the client was triggered
- Capture screenshot

### Scenario 5: Consumer pull API — auth and contract (AC: Client gets pull trigger and fetches the manifest from S3)
- Test `POST https://dev.codemyspec.com/api/content/pull` without auth — expect 401 or 400
- Test with invalid bearer — expect 401
- Test without `manifest_url` param (valid bearer if available) — expect 400
- Capture curl responses as evidence

### Scenario 6: Published consumer content routes (AC: Client gets pull trigger and fetches manifest from S3)
- `curl -s -o /dev/null -w "%{http_code}" https://dev.codemyspec.com/blog/about` — expect 200
- `curl -s -o /dev/null -w "%{http_code}" https://dev.codemyspec.com/blog/nonexistent-slug-xyz` — expect 404
- Capture responses

## Result Path

`.code_my_spec/qa/712/`
