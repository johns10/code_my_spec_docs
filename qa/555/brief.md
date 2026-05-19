# Qa Story Brief

## Tool

curl (against `http://127.0.0.1:4004/api/hooks/stop`,
`/api/hooks/session-start`, `/api/hooks/subagent-start`,
`/api/hooks/post-tool-use`)

## Auth

None — local app uses `LocalOnly` plug and `WorkingDirScope`.
Required header: `X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec`
on every request so the working project scope resolves.

Verify app is running: `curl http://127.0.0.1:4004/health` → `{"status":"ok"}`

## Seeds

No special seeds required. The app is running against the dev Postgres DB.
The working project is the CodeMySpec repo itself at
`/Users/johndavenport/Documents/github/code_my_spec`.

Fixture files for pipeline output injection are already in the source tree:
- `test/fixtures/validation/pipeline_clean_run/compile.jsonl` — empty (clean compile)
- `test/fixtures/validation/pipeline_clean_run/exunit.json` — zero failures
- `test/fixtures/validation/pipeline_compile_error/compile.jsonl` — one error diagnostic

## What To Test

For each criterion, drive the agent surface. The stop hook is at
`POST http://127.0.0.1:4004/api/hooks/stop`. Response shapes:

- `{}` = allow the stop
- `{"decision":"block","reason":"..."}` = block

Probe matrix:

- **5097 — task started + no files changed → allow, pipeline skipped:**
  Register a session via `POST /api/hooks/session-start` with unique session_id.
  Start a task via MCP `start_task`. Do NOT write any files after task start.
  POST `/api/hooks/stop` with that session_id → expect `{}`.

- **5098 — files changed + clean pipeline → allow:**
  Fire the stop hook with no session_id, pass `test_output_files` pointing at
  clean fixtures (empty compile.jsonl + zero-failure exunit.json) → expect `{}`.

- **5099 — compile errors → block with diagnostics:**
  Fire the stop hook with `test_output_files` pointing at the compile-error
  fixture (compile.jsonl with one error diagnostic on `lib/example_context.ex`).
  Expect `{"decision":"block"}` with `"reason"` containing "compil" and the
  offending file path. Credo and exunit must NOT appear in the reason.

- **5101 — no active task + files changed → pipeline runs, clean allow:**
  Fire the stop hook without a session_id, with clean `test_output_files` →
  expect `{}` (task eval skipped, no blocking problems).

- **5102 — subagent-owned task → short-circuit allow:**
  Register a session, register a sub-agent via `POST /api/hooks/subagent-start`,
  start a task via MCP `start_task` with that agent_id to claim it.
  POST `/api/hooks/stop` for the parent session → expect `{}`.

- **5103 — manual validation task → short-circuit allow:**
  Register a session via `POST /api/hooks/session-start`.
  Start a `qa_integration_plan` task (validation_type: :manual) via MCP `start_task`.
  POST `/api/hooks/stop` for that session → expect `{}`.

- **6237 — cross-session attribution filter:**
  Register a session, fire `POST /api/hooks/post-tool-use` to attribute a clean
  file write to session A. Write a bogus spec file to disk without attribution.
  POST `/api/hooks/stop` for session A with clean `test_output_files` → expect
  `{}` (other-session file's problems filtered out).

Disconfirmation probes (always run):
- POST `/stop` with empty body → observe response shape (expect `{}` if no scope)
- POST `/stop` with unknown session_id → observe response shape
- POST `/stop` with missing `session_id` field → observe response shape

## Result Path

.code_my_spec/qa/555/

## Setup Notes

The stop hook endpoint lives on the local web endpoint (port 4004), in the
`:hook` pipeline (LocalOnly + WorkingDir + WorkingDirScope). No session cookie
or CSRF token needed — just the `X-Working-Dir` header and JSON body.

Session IDs must be unique per test scenario to avoid cross-test contamination
with active task state from prior runs.
