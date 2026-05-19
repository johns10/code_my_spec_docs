# Qa Story Brief

## Tool

`mcp__plugin_codemyspec_local__*` MCP tools for all issue lifecycle operations (create, list, get, accept, dismiss, resolve). No browser required — the surface is the Issues MCP server.

## Auth

No browser auth needed. MCP tool calls are scoped to the sandbox project via the `X-Working-Dir` header resolved to `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`. The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) maps to this path.

All MCP tool calls in this session target the sandbox project automatically via the plugin session scope.

## Seeds

No seed scripts needed for this story. The MCP tools themselves create the required test data (issues). Use `[QA-TEST]` prefix in all issue titles for easy cleanup.

## What To Test

### SC1 — Full issue lifecycle: create → list → get → accept → resolve (criterion 6214)

1. Call `create_issue` with `title: "[QA-TEST] Loading spinner flickers on dashboard"`, `severity: "medium"`, `scope: "app"`, `description: "Spinner re-mounts twice when navigating to the dashboard."`
2. Assert: response contains the title and an issue ID matching pattern `ID: <uuid>`
3. Call `list_issues` with no filters
4. Assert: response includes the created issue's title and ID
5. Call `get_issue` with the issue_id from step 1
6. Assert: response echoes title and ID
7. Call `accept_issue` with `issue_id`, `category: "bug"`
8. Assert: response contains "accepted" and "bug"
9. Call `resolve_issue` with `issue_id`, `resolution: "Re-enabled save button after key changes; covered by a test."`
10. Assert: response contains "resolved"
11. Call `get_issue` again with the issue_id
12. Assert: response shows status "resolved" and the resolution text

### SC2 — Framework-scoped issues route remotely, not locally (criterion 6215)

1. Call `create_issue` with `title: "[QA-TEST] Framework friction test"`, `severity: "high"`, `scope: "framework"`, `description: "Testing framework issue routing."`
2. Assert: response returns success with an issue ID (framework issues route to server stub)
3. Call `list_issues` with no filters
4. Assert: the framework issue does NOT appear in local list (framework issues are server-side only)
5. Call `list_issues` with `status: "incoming"` or `scope: "framework"`
6. Assert: `scope: "framework"` filter returns an error (invalid for local surface)

### SC3 — Default scope is :app when omitted (criterion 6218)

1. Call `create_issue` with `title: "[QA-TEST] Default scope test"`, `severity: "low"`, `description: "Testing default scope behavior."` (no scope field)
2. Assert: response succeeds with an issue ID
3. Call `get_issue` with the returned ID
4. Assert: response shows `scope: app`
5. Call `list_issues` with `scope: "app"`
6. Assert: the issue appears in the list
7. Call `list_issues` with `scope: "qa"`
8. Assert: the issue does NOT appear

### SC4 — Dismiss with a reason succeeds (additional validation)

1. Call `create_issue` with `title: "[QA-TEST] Dismiss test issue"`, `severity: "medium"`, `scope: "app"`, `description: "This issue will be dismissed."`
2. Call `dismiss_issue` with `issue_id`, `reason: "Duplicate of another issue; not a real bug."`
3. Assert: response contains "dismissed"
4. Call `get_issue` and verify status is "dismissed"

### SC5 — Dismiss without a reason fails validation

1. Call `dismiss_issue` with a valid `issue_id` from a previously created issue and an empty or missing `reason`
2. Assert: response indicates a validation error (mentions "reason", "required", "blank", or similar)

### SC6 — Server-origin sync-back (criterion 6471, 6472, 6473)

These criteria require `Fixtures.seed_server_incoming_issue/2`, `Fixtures.sync_server_issues_to_local/1`, and `Fixtures.simulate_server_unreachable/1` — in-process test fixtures not accessible via MCP tools. These scenarios are only exercisable via the spex test suite. QA verifies via `mix test` output.

Note: Criteria 6471, 6472, 6473 are marked RED in the spex files (not yet implemented). QA records their test status from spex run.

## Setup Notes

The sandbox project at `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` is the target for all MCP tool calls. This avoids contaminating the main CodeMySpec project's issue list.

Framework issues (scope: framework) route to the server; in dev the server client may be a stub. The `list_issues` response does not include framework-scoped issues — this is by design.

After QA, dismiss or resolve all `[QA-TEST]` issues to keep the sandbox clean.

## Result Path

.code_my_spec/qa/709/result.md
