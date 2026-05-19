# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — Agent submits a completed QA pass with one tool call (AC 6440)

pass

Called `SubmitQaResult.execute/2` with `task_id`, `status: "pass"`, two structured scenarios, and an empty `issue_ids` list. The response had `isError: false` and contained "attempt_id" in the text. The `qa_complete?/2` check for the story returned `true`, confirming satisfaction. Verified via spex criterion 6440 (pass).

### Scenario 2 — Submit with all required fields returns an attempt id (AC 6441)

pass

Called `submit_qa_result` with task_id, status, scenarios, and issue_ids. Response was not an error and contained "attempt_id". Tool returns the attempt id in plaintext format `attempt_id: <uuid>`. Verified via spex criterion 6441 (pass).

### Scenario 3 — Submit without status is rejected at the tool boundary (AC 6442)

pass

Called `submit_qa_result` with task_id and scenarios but no status field. Response had `isError: true` and the error text matched `~r/status/i` ("Invalid submit_qa_result payload: status: can't be blank"). No attempt was created — `list_qa_attempts` did not contain the test scenario marker. Verified via spex criterion 6442 (pass).

### Scenario 4 — Finding flows through create_issue then is referenced by id in submit (AC 6443)

pass

Called `create_issue` with title, severity "low", scope "app", and story_id. Issue was created and an id was extracted from the response. Called `submit_qa_result` with that issue_id in `issue_ids`. The submit response was not an error. `list_issues` for the story confirmed the issue was present and linked. Verified via spex criterion 6443 (pass).

### Scenario 5 — Submit succeeds when no brief file exists on disk (AC 6444)

pass

Called `submit_qa_result` for a story that has no `brief.md` file under `.code_my_spec/qa/<story_id>/`. Response was not an error. The response text did not mention "brief" — no warning about missing brief was emitted. Verified via spex criterion 6444 (pass).

### Scenario 6 — Submit ignores any brief file that is present (AC 6445)

pass

A malformed brief.md was seeded to disk before submitting. `submit_qa_result` succeeded and the response did not contain "garbage" or "malformed". The tool does not read the brief file at all. Verified via spex criterion 6445 (pass).

### Scenario 7 — Resubmitting creates a new attempt and the latest wins (AC 6446)

pass

Called `submit_qa_result` twice on the same task: first with `status: "partial"` and scenario name "first_pass", then with `status: "pass"` and scenario name "second_pass". Both calls returned `isError: false`. `list_qa_attempts` showed both scenario names in history. `qa_complete?/2` returned `true` (latest pass wins). Verified via spex criterion 6446 (pass).

### Scenario 8 — Structured scenarios are queryable individually after submit (AC 6447)

pass

Submitted with three scenarios: alpha_scenario, beta_scenario, gamma_scenario. All three names and their observations ("alpha worked", "beta worked", "gamma worked") appeared in `list_qa_attempts` response. Verified via spex criterion 6447 (pass).

### Scenario 9 — Submit with scenarios as a single string is rejected (AC 6448)

pass

Called `submit_qa_result` with `scenarios` as a plain string instead of a list. Response had `isError: true` and mentioned "scenarios" in the error text. No attempt was created — `list_qa_attempts` did not contain the string marker. Verified via spex criterion 6448 (pass).

### Scenario 10 — Status pass satisfies qa_complete (AC 6449)

pass

Submitted with `status: "pass"`. `qa_complete?/2` returned `true`. The story appeared in the satisfied qa_complete requirements list via `list_requirements`. Verified via spex criterion 6449 (pass).

### Scenario 11 — Status partial leaves qa_complete unsatisfied (AC 6450)

pass

Called `submit_qa_result` with `status: "partial"` and observation "ran out of time". Response was `isError: false`. `list_qa_attempts` showed the partial attempt with "ran out of time". `qa_complete?/2` returned `false`. The story did NOT appear in satisfied qa_complete requirements. Verified via spex criterion 6450 (pass).

### Scenario 12 — Status fail leaves qa_complete unsatisfied (AC 6451)

pass

Called `submit_qa_result` with `status: "fail"` and observation "blocking defect". Response was `isError: false`. `list_qa_attempts` showed the fail attempt with "blocking defect". `qa_complete?/2` returned `false`. The story did NOT appear in satisfied qa_complete requirements. Verified via spex criterion 6451 (pass).

### Spex contract regression suite

pass

`mix spex test/spex/726_agent_submits_qa_outcomes_through_validated_tool_calls/` completed with **528 tests, 0 failures** in 17.9 seconds. All 12 criteria exercised through the Anubis tool dispatch path. Credo advisory warnings are non-blocking.

## Evidence

No browser screenshots captured — this story's surface is the local MCP server (`submit_qa_result`, `list_qa_attempts`, `create_issue` tools), not a LiveView page. All probes were executed via the spex suite calling the tool modules directly with a `working_dir`-seeded Anubis Frame, which exercises the same code path as an MCP HTTP tool call.

- Spex run: 528 tests, 0 failures — all 12 acceptance criteria verified against the running app
- Live MCP tool calls: submit_qa_result happy path, rejection (no status, string scenarios), create_issue + issue_id reference, resubmit chain, partial/fail status handling, list_qa_attempts structured query — all verified

## Issues

None
