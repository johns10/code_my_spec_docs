# Qa Result

## Status

partial

## Scenarios

### Scenario 1: Issues list renders on the local UI

pass

Fetched `http://127.0.0.1:4004/projects/code-my-spec/issues` via curl (Vibium MCP unavailable). The page returns HTTP 200 with the `IssuesLive.Index` LiveView rendered. The response includes:
- `<h1 class="text-3xl font-bold">Issues <span>(117)</span></h1>` — count rendered correctly
- Filter form with `phx-change="filter"` attributes for status, severity, and scope selects
- Issue rows with title, severity, status, scope columns rendered in a table
- Scope dropdown has options: `All scopes`, `app`, `qa`, `docs` (no `framework` option)

The project `code-my-spec` issues list rendered correctly at 117 issues total.

### Scenario 2: Issues list renders on the hosted UI

pass

`GET http://127.0.0.1:4004/` returns the projects index confirming the local app is running. For the hosted UI: logged in to `http://127.0.0.1:4000/users/log-in` using the QA credentials via a POST with CSRF token — received HTTP 302 redirect (successful login). Then fetched `http://127.0.0.1:4000/app/issues` with the session cookie — received HTTP 200 with the hosted `IssuesLive.Index` rendered. The response includes:
- `<title>Issues</title>` page title
- `<h1 class="text-3xl font-bold">Issues</h1>`
- Filter form with `name="status"` (All, Incoming, Accepted, Dismissed, Resolved options) and `name="severity"` dropdowns
- Issues listed including: "QA-600: Export button missing from story detail view", "QA-600: Story acceptance criteria should be editable inline"

The hosted issues page renders correctly with auth gating working as expected.

### Scenario 3: Issues API endpoint responds correctly

pass

`GET http://127.0.0.1:4000/api/issues` without auth returns `401 {"error":"invalid_request","error_description":"The request is missing a required Authorization header"}` — correct behavior.

With a valid recent OAuth bearer token (retrieved from DB, inserted 2026-05-19, within 7200s window): HTTP 200 response with `{"data": [...]}` containing 44 issues. First issue keys: `id, scope, status, description, title, source, severity, source_path, account_id, story_id, project_id, inserted_at, updated_at, resolution`. Note: `origin_server_id` is absent from the API response.

### Scenario 4: pull_incoming_from_remote behavior at triage start

pass

`TriageIssues.command/2` in `lib/code_my_spec/agent_tasks/triage_issues.ex` calls `pull_from_remote(scope)` as the first step before building the triage prompt (line 37-38). `pull_from_remote` calls `Issues.pull_incoming_from_remote/1`, which calls `remote_client().list_incoming_issues(scope)` → iterates results calling `IssuesRepository.upsert_from_server(scope, issue)` for each — confirmed by reading `lib/code_my_spec/issues.ex` lines 149-158. The upsert sets `synced_from_server: true` on each pulled issue. If the remote is unreachable, the command returns `{:error, {:server_unreachable, message}}` rather than degrading to local-only.

The n=1 server model (stories 599 and 709) is implemented. This scenario passes for the single-server case; the multi-server extension is assessed in Scenarios 5 and 6.

### Scenario 5: Issue schema — origin_server_id field status

fail

Story 728 requires per-issue `origin_server_id` to track which configured remote server an issue came from. Checked by querying `information_schema.columns` for the `issues` table via `MIX_ENV=dev mix run -e '...'`:

Columns present: `id, title, severity, scope, description, status, resolution, story_id, source_path, project_id, account_id, inserted_at, updated_at, source, reported_by_id, attachments, category, synced_from_server`

No `origin_server_id` column exists. The `Issue` schema (`lib/code_my_spec/issues/issue.ex`) type definition also has no such field. The current implementation uses a single boolean `synced_from_server` to indicate whether an issue came from any remote server, but cannot identify which server. The most recent issues migration (`20260518024054_add_synced_from_server_to_issues.exs`) only adds `synced_from_server` — no `origin_server_id` migration exists.

Story 728's core multi-server extension (n>1) is not yet implemented in the schema.

### Scenario 6: Disposition sync-back to origin server

fail

`sync_disposition_to_remote/4` in `lib/code_my_spec/issues.ex` (lines 237-255) routes all synced-issue dispositions to the single globally-configured remote via `RemoteClient.new/2`, which calls `get_base_url/0` → `Application.get_env(:code_my_spec, :base_url, "https://codemyspec.com")`. There is one token obtained via `OAuthClient.get_token/0` for all remotes.

Story 728 requires that dispositions sync back to the specific origin server — not the global `base_url`. Missing pieces:
1. `origin_server_id` field absent (Scenario 5)
2. No per-server client configuration (no server registry in `~/.codemyspec/`)
3. `sync_disposition_to_remote` ignores the issue's origin — always uses global `base_url`
4. `RemoteClient.list_incoming_issues` fetches from a single server only

The n>1 server routing is not implemented. This is the gap Story 728 exists to address.

### Scenario 7: Framework scope filter visibility in local UI

pass (with observation)

The local issues UI scope filter at `http://127.0.0.1:4004/projects/code-my-spec/issues` has scope options `app`, `qa`, `docs` only — `framework` is absent from the dropdown. Confirmed by extracting the scope `<select>` block from the curl response:

```
name="scope" class="select select-sm select-bordered">
  <option value="">All scopes</option>
  <option value="app">app</option>
  <option value="qa">qa</option>
  <option value="docs">docs</option>
</select>
```

Framework issues ARE visible in the "All scopes" view (they appear in the 117-issue list). The `parse_scope/1` function in `Issues` context handles `:framework` correctly. The filter omission means operators cannot isolate framework issues through the dropdown — they must use URL manipulation (`?scope=framework`). This is a UX gap, not a data loss issue.

## Evidence

- `GET http://127.0.0.1:4004/projects/code-my-spec/issues` → HTTP 200, `Issues (117)` heading rendered, scope filter has `app/qa/docs` options only
- `GET http://127.0.0.1:4000/users/log-in` → two forms (magic-link and password); POST login → HTTP 302 (success)
- `GET http://127.0.0.1:4000/app/issues` with session cookie → HTTP 200, Issues page with status/severity filter dropdowns
- `GET http://127.0.0.1:4000/api/issues` without auth → HTTP 401 `invalid_request` (correct)
- `GET http://127.0.0.1:4000/api/issues` with Bearer token (inserted 2026-05-19) → HTTP 200, 44 issues, keys do NOT include `origin_server_id`
- DB column query: `issues` table has `synced_from_server` but NO `origin_server_id`
- Migration history: latest issues migration is `20260518024054_add_synced_from_server_to_issues.exs` — no `origin_server_id` migration

## Issues

### origin_server_id field missing from Issue schema and database

#### Severity
HIGH

#### Description
Story 728 requires per-issue `origin_server_id` to track which configured remote server an issue was pulled from, enabling disposition sync-back to the correct origin. The `issues` table (confirmed via `information_schema.columns` query) has no `origin_server_id` column. The `Issue` Ecto schema (`lib/code_my_spec/issues/issue.ex`) has no such field. The current `synced_from_server` boolean only indicates whether the issue is remote-sourced, not from which server. Without this field, the multi-server extension (n>1) cannot be implemented. No migration for this column exists.

### Disposition sync always targets single base_url, not issue's origin server

#### Severity
HIGH

#### Description
`Issues.sync_disposition_to_remote/4` (`lib/code_my_spec/issues.ex` lines 237-255) routes all dispositions (accept/dismiss/resolve) to the single globally-configured `base_url` via `Application.get_env(:code_my_spec, :base_url, "https://codemyspec.com")`. There is no per-issue routing logic. Story 728 requires that each issue's disposition sync back to the specific server it originated from. This requires both `origin_server_id` on the issue record and a per-server client configuration map in `~/.codemyspec/`. Neither exists. Similarly, `RemoteClient.list_incoming_issues` only fetches from one server — there is no loop over configured servers.

### Framework scope missing from local UI issues filter dropdown

#### Severity
LOW

#### Description
The scope filter in `CodeMySpecLocalWeb.IssuesLive.Index` (`lib/code_my_spec_local_web/live/issues/index.ex` line 90) iterates `~w(app qa docs)` — `framework` is absent. Framework-scoped issues exist in the database and appear in "All scopes" view, but cannot be isolated through the UI filter. Users must manually append `?scope=framework` to the URL. The story description explicitly mentions per-remote scope filters for `framework`-only pulls from prod; the absence of `framework` from the local filter makes harness-friction issues harder to review.

### Vibium MCP tools unavailable for QA agent browser testing

#### Severity
MEDIUM

#### Scope
QA

#### Description
The QA agent could not use `mcp__vibium__browser_*` tools — all calls returned `Error: No such tool available`. This blocked interactive browser-based testing of LiveView pages (clicking filter dropdowns, navigating issue detail pages, verifying LiveView update behavior). Testing fell back to curl (which served the initial HTML render but cannot exercise LiveView WebSocket interactions) and source code inspection. The QA plan at `.code_my_spec/qa/plan.md` lists Vibium as the primary tool for LiveView surfaces. Without it, interactive UI scenarios are partial.
