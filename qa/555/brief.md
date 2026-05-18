# Qa Story Brief

## Tool

curl (against `http://127.0.0.1:4004/api/hooks/stop` and
`/api/hooks/post-tool-use`)

## Auth

None — local app uses `LocalOnly` plug and `WorkingDirScope`.
Required header: `X-Working-Dir:
/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`
on every request so the QA Fixture Project scope resolves.

## Seeds

`MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs` once if the
sandbox project isn't already in the local CLI DB. The local app
must be running on port 4004 (verify with `curl
http://127.0.0.1:4004/health` → `{"status":"ok"}`).

## What To Test

For each criterion, drive the agent surface
(`POST /api/hooks/post-tool-use` to register edits, then `POST
/api/hooks/stop` to observe the decision) and assert the response
shape:

- `{}` = allow
- `{"decision":"block","reason":"..."}` = block

Probe matrix:

- **5097 — task started + no changes → allow, pipeline skipped:**
  start a task via MCP (`start_task`) with a sandbox session_id,
  do NOT register any post-tool-use events, POST `/stop` → expect
  `{}` and no analyzer activity in `server.log`.
- **5098 — files changed + clean → allow:** stage a clean fixture
  file in the sandbox `lib/`, POST `post-tool-use` with that file
  path, POST `/stop` → expect `{}`.
- **5099 — compile fail → block with diagnostics:** stage a
  malformed `.ex` file (e.g. `defmodule Bad do x end`), POST
  `post-tool-use`, POST `/stop` → expect `block` with compiler
  output in `reason`.
- **5100 — credo violations → block:** stage a file with a credo
  violation (e.g. unused alias), POST `post-tool-use`, POST
  `/stop` → expect `block` with credo problems in `reason`.
- **5101 — no active task + files changed → pipeline runs,
  allow:** without starting a task, POST `post-tool-use` for a
  clean file, POST `/stop` → expect `{}` and analyzers running
  in `server.log`.
- **5102 — subagent task → skip validation:** start a task via
  MCP with `agent_id` set (signals subagent), POST `/stop` →
  expect `{}` immediately, no analyzers in log.
- **5103 — manual validation task → skip:** start a task whose
  module has `validation_type: :manual`, POST `/stop` → expect
  `{}` with no validation or task-eval activity.
- **6237 — cross-session attribution filter:** simulate two
  sessions writing different files; POST `/stop` for session A
  → expect session B's file's problems to NOT be in the block
  decision.

Disconfirmation probes (always run these):

- Empty body POST `/stop` → observe response shape
- Missing `session_id` → observe response shape
- Unknown session_id (no task) → observe response shape
- `post-tool-use` for a non-existent file → observe whether
  it's accepted or rejected

## Result Path

.code_my_spec/qa/555/result.md

## Setup Notes

The spex layer (`mix spex test/spex/555_*/`) drives the same
controllers in-process via Phoenix `conn`; spex passing confirms
the contract is implemented but does NOT confirm the running app
behaves the same under real HTTP. Run `mix spex` first as a
contract sanity check, then probe the running surface with curl
to validate the deployment.
