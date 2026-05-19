# Qa Story Brief

## Tool

web (Vibium MCP browser tools for LiveView surfaces at port 4004 and 4000)
curl for API endpoints at port 4000

## Auth

Local UI (port 4004): No authentication required. `LocalOnly` plug accepts loopback IP directly.

Hosted UI (port 4000): Log in at `http://127.0.0.1:4000/users/log-in` using the QA seed credentials:
- Email: `qa@codemyspec.local`
- Password: `qa-password-123!`

Use the password form (the bottom form on the login page) — scope selector: `form[action="/users/log-in"] input[name='user[email]']`.

## Seeds

Run QA seeds to set up the hosted user and project:

```
mix run priv/repo/qa_seeds.exs
```

For the local CLI project:

```
NO_SERVER=true MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs
```

Note: The CLI seed may fail due to pending migrations in dev_cli. If so, confirm the QA Fixture Project (`11111111-1111-4111-8111-111111111111`) exists in the local app by visiting `http://127.0.0.1:4004/`.

## What To Test

Story 728 extends the Issues context to support multi-server issue pulling (from prod/remote server) at triage start, with per-issue `origin_server_id` tracking and synchronous disposition sync-back to the origin server. The implementation lives in `CodeMySpec.Issues` and related modules.

This story has no acceptance criteria and no BDD specs. QA is an exploratory assessment of the current implementation state against the story's described intent.

### Scenario 1: Issues list renders on the local UI

- Navigate to `http://127.0.0.1:4004/`
- Find a project in the list (should include QA Fixture Project if seeds ran)
- Navigate to `http://127.0.0.1:4004/projects/qa-fixture-project/issues` (or the slug for the QA project)
- Expected: Issues index page loads, shows "Issues (N)" heading, filter dropdowns for status/severity/scope
- Capture screenshot

### Scenario 2: Issues list renders on the hosted UI

- Navigate to `http://127.0.0.1:4000/users/log-in` and log in with QA credentials
- Navigate to `http://127.0.0.1:4000/app/issues`
- Expected: Issues list page renders with filter dropdowns for status and severity
- Capture screenshot

### Scenario 3: Issues API endpoint responds correctly

- Test the hosted API issues endpoint with a bearer token (if available) or via Vibium session
- `curl -s http://127.0.0.1:4000/api/issues` with appropriate headers
- Expected: 200 response with `data` array of issues

### Scenario 4: pull_incoming_from_remote behavior at triage start

- Using the MCP tool surface: call `start_task` for a `triage_issues` task if one exists in the sandbox project
- Alternatively, verify via source code inspection that `TriageIssues.command/2` calls `Issues.pull_incoming_from_remote/1` before building the prompt
- Expected: The triage command pulls server-side incoming issues into local DB before prompting. Currently implemented in `TriageIssues.command/2` → `Issues.pull_incoming_from_remote/1` → `RemoteClient.list_incoming_issues/2`

### Scenario 5: Issue schema — origin_server_id field status

- Inspect the `Issue` schema (`lib/code_my_spec/issues/issue.ex`) and database schema
- Check whether `origin_server_id` field exists on the `issues` table
- Expected per story description: each pulled issue should have `origin_server_id` to track its origin server
- Check actual state: does the schema have this field?

### Scenario 6: Disposition sync-back to origin server

- Review `Issues.sync_disposition_to_remote/4` in `lib/code_my_spec/issues.ex`
- Check: does `accept_issue/dismiss_issue/resolve_issue` route the sync back to the issue's `origin_server_id` server, or does it always use the configured `base_url`?
- Expected per story: per-issue `origin_server_id` drives disposition sync target
- Check actual: `RemoteClient` uses `Application.get_env(:code_my_spec, :base_url, "https://codemyspec.com")` globally — single server only

### Scenario 7: synced_from_server flag behavior in local issues list

- Navigate to `http://127.0.0.1:4004/projects/<project-slug>/issues`
- Filter by scope if possible (the filter includes app/qa/docs but not framework)
- Expected: issues pulled from remote server should be tagged with `synced_from_server: true`
- Observe whether framework-scoped issues appear or are filtered out

## Setup Notes

Story 728 depends on stories 599 (triage-start server pull) and 709 (synchronous disposition sync-back). The `pull_incoming_from_remote/1` function and `sync_disposition_to_remote/4` are already implemented in `Issues` context, addressing the n=1 server model from those dependency stories. Story 728 extends this to n>1 servers with per-issue `origin_server_id` tracking and per-remote OAuth tokens.

The `Issue` schema currently has `synced_from_server: boolean` but no `origin_server_id` field, indicating story 728's multi-server extension is not yet fully implemented.

The scope filter dropdown in the local UI (`index.ex`) only shows `app`, `qa`, `docs` — not `framework`. This may be intentional or a gap.

## Result Path

`.code_my_spec/qa/728/result.md`
