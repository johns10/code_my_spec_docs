# Qa Story Brief

## Tool

MCP tools via `mcp__plugin_codemyspec_local__*` — this story's surface is the local MCP server registered on port 4004. All interactions are agent MCP tool calls, not browser or curl.

## Auth

No authentication required for the local MCP server (port 4004). The `LocalOnly` plug accepts all loopback connections. The `X-Working-Dir` header is injected automatically from `$PWD` by the plugin configuration. No explicit login steps needed.

## Seeds

Run the server QA seeds to ensure a project scope exists:

```
mix run priv/repo/qa_seeds.exs
```

This creates:
- User: `qa@codemyspec.local`, password: `qa-password-123!`
- Project: `QA Fixture Project` (id `11111111-1111-4111-8111-111111111111`)

For MCP mutation tests, target the QA sandbox project at:
`/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`

The `submit_qa_result` tool requires a valid `task_id` from an active `qa_complete` task. Use `mcp__plugin_codemyspec_local__start_task` to start a `qa_complete` task on a story in the sandbox project to obtain a valid `task_id`.

## What To Test

All scenarios use `mcp__plugin_codemyspec_local__submit_qa_result` and related tools. Each scenario sets up an active `qa_complete` task via `start_task` on the sandbox project.

- **Scenario 1 — Agent submits a completed QA pass with one tool call (AC 6440)**
  - Start a `qa_complete` task on a story in the sandbox project
  - Call `submit_qa_result` with `task_id`, `status: "pass"`, two structured scenarios, and one `issue_id`
  - Verify the response is not an error and contains "attempt_id"
  - Verify `qa_complete` is satisfied for the story

- **Scenario 2 — Submit with all required fields returns an attempt id (AC 6441)**
  - Start a `qa_complete` task
  - Call `submit_qa_result` with `task_id`, `status: "pass"`, one scenario, `issue_ids: []`
  - Verify the response contains "attempt_id" and is not an error

- **Scenario 3 — Submit without status is rejected at the tool boundary (AC 6442)**
  - Start a `qa_complete` task
  - Call `submit_qa_result` with `task_id` and scenarios but omit `status`
  - Verify the response is an error mentioning "status"
  - Call `list_qa_attempts` and verify no attempt was created with the test scenario name

- **Scenario 4 — Finding flows through create_issue then is referenced by id in submit (AC 6443)**
  - Start a `qa_complete` task
  - Call `create_issue` with title, severity, scope, story_id, description
  - Extract the issue id from the response
  - Call `submit_qa_result` with the issue id in `issue_ids`
  - Verify the issue appears in `list_issues` for the story
  - Verify the submit response acknowledges the linked issue_id

- **Scenario 5 — Submit succeeds when no brief file exists on disk (AC 6444)**
  - Start a `qa_complete` task on a story that has no `brief.md` on disk
  - Call `submit_qa_result` with `status: "pass"`
  - Verify success with no mention of "brief" in the response

- **Scenario 6 — Submit ignores any brief file that is present (AC 6445)**
  - Start a `qa_complete` task
  - Place a garbage `brief.md` at `.code_my_spec/qa/<story_id>/brief.md` in the sandbox
  - Call `submit_qa_result` with `status: "pass"`
  - Verify the response does not contain "garbage" or "malformed"

- **Scenario 7 — Resubmitting creates a new attempt and the latest wins (AC 6446)**
  - Start a `qa_complete` task
  - Submit with `status: "partial"` and scenario name "first_pass"
  - Submit again on the same task with `status: "pass"` and scenario name "second_pass"
  - Call `list_qa_attempts` and verify both scenario names appear
  - Verify `qa_complete` is satisfied (latest pass wins)

- **Scenario 8 — Structured scenarios are queryable individually after submit (AC 6447)**
  - Start a `qa_complete` task
  - Submit with three distinct scenarios (alpha_scenario, beta_scenario, gamma_scenario)
  - Call `list_qa_attempts` and verify all three names and observations appear

- **Scenario 9 — Submit with scenarios as a single string is rejected (AC 6448)**
  - Start a `qa_complete` task
  - Call `submit_qa_result` with `scenarios` as a plain string instead of a list
  - Verify the response is an error mentioning "scenarios"
  - Verify no attempt was recorded via `list_qa_attempts`

- **Scenario 10 — Status pass satisfies qa_complete (AC 6449)**
  - Start a `qa_complete` task
  - Submit with `status: "pass"`
  - Verify the story title appears in the satisfied `qa_complete` requirements list

- **Scenario 11 — Status partial leaves qa_complete unsatisfied (AC 6450)**
  - Start a `qa_complete` task
  - Submit with `status: "partial"` and observation "ran out of time"
  - Verify the attempt appears in `list_qa_attempts` with status "partial"
  - Verify the story does NOT appear in satisfied `qa_complete` requirements

- **Scenario 12 — Status fail leaves qa_complete unsatisfied (AC 6451)**
  - Start a `qa_complete` task
  - Submit with `status: "fail"` and observation "blocking defect"
  - Verify the attempt appears in `list_qa_attempts` with status "fail"
  - Verify the story does NOT appear in satisfied `qa_complete` requirements

## Result Path

.code_my_spec/qa/726/result.md

## Setup Notes

The `submit_qa_result` tool resolves `story_id` and `agent_id` by looking up the `task_id` in active sessions. The task must be started via `start_task` on a `qa_complete` requirement node before calling `submit_qa_result`. Use the sandbox project to avoid contaminating working project state.

The Anubis MCP server returns 202 for tool calls over plain curl — always use the `mcp__plugin_codemyspec_local__*` tools for this story's QA.
