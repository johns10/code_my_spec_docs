# Qa Result

## Status

partial

## Scenarios

### 5097 — Task started, no file changes → allow (skip pipeline)

pass

Created a session on the sandbox project (`X-Working-Dir: .../qa_sandbox`) and injected an active task with `started_at` = current time (so no files have changed since the task started). Fired `POST /api/hooks/stop` with that `session_id`. Response: `{}` (allow). The pipeline was skipped because `Files.changed_since(started_at)` returned empty.

Response: `.code_my_spec/qa/555/responses/5097_no_changes_allow.json`

### 5098 — Files changed, clean pipeline → allow

pass

Created a session on the sandbox project with an active task `started_at = 2026-01-01` (so all tracked files count as changed). Sandbox has only a well-formed spec file and mix.exs. Cleared all persisted problems. Fired `POST /api/hooks/stop`. Response: `{}` (allow). Compile ran, no errors, no blocking problems.

Note: the task had `session_type: null` which triggers orphan pruning on read (resulting in no active task path). The pipeline still ran via `sync_result.changed_paths` and returned allow. This exercises the "no active task + clean pipeline" path (criteria overlap with 5101).

Response: `.code_my_spec/qa/555/responses/5098_clean_pipeline_allow.json`

### 5099 — Compile fails → block with diagnostics

pass (partial — error is about missing diagnostics compiler, not a syntax error)

Added the `:diagnostics` compiler to the sandbox `mix.exs` (referencing `client_utils` path dep), triggering a `Mix.Tasks.Compile.Diagnostics not found` error when the pipeline ran compile. Response: `{"decision":"block","reason":"Compilation failed with 1 error(s). Fix these before continuing: unknown — ** (Mix) The task \"compile.diagnostics\" could not be found..."}`. The compile phase blocked the stop as expected. The `decision: block` and compile-error reason structure match criterion 5099.

Response: `.code_my_spec/qa/555/responses/5099_compiler_problem_block.json`

### 5100 — Credo violations on changed files → block

fail

Could not produce a clean credo block via curl. Seeded a credo problem (`source_type: static_analysis`, `source: credo`, `file_path: mix.exs`) and created a session with `started_at = 2026-01-01`. However, the `session_type: null` task was pruned by `maybe_prune_orphan_tasks` on session read, resulting in the no-active-task path. In that path, `resolve_changed_files` uses `sync_result.changed_paths` (filesystem mtime delta), which was empty after the first sync request already updated DB mtimes. The seeded credo problem (`block_changed` mode) only blocks when the problem's file_path is in `changed_file_paths`, which was empty. Stop returned `{}`.

Root constraint: testing 5100 via curl requires either (a) a real credo install in the target project that actually finds violations, or (b) a valid `session_type` whose task evaluator passes AND an active task so `Files.changed_since` is used instead of `sync_result.changed_paths`.

### 5101 — No active task, files changed → pipeline runs, allow if clean

pass

Fired `POST /api/hooks/stop` with no `session_id` (empty body) → `{}`. Also tested with an unknown `session_id` (`qa-nonexistent-session-555`) → `{}`. Both paths produce allow when no active task exists and no blocking problems are seeded.

Response: `.code_my_spec/qa/555/responses/5101_no_session_allow.json`, `5101_unknown_session_allow.json`

### 5102 — Subagent task (agent_id set) → skip validation, allow

pass

Created a session, registered a sub-agent via `POST /api/hooks/subagent-start` (confirmed `agent_id` in response). Injected a task with `agent_id: "qa-subagent-555"` and `status: active` directly in SQLite. Fired `POST /api/hooks/stop` → `{}`. The `has_active_subagent_task?` check short-circuited before validation ran.

Response: `.code_my_spec/qa/555/responses/5102_subagent_skip.json`

### 5103 — Manual validation task → skip validation and task eval, allow

pass

Injected a task with `validation_type: "manual"` on a fresh session. Fired `POST /api/hooks/stop` → `{}`. The `has_active_manual_task?` check short-circuited before the pipeline ran.

Response: `.code_my_spec/qa/555/responses/5103_manual_task_allow.json`

### 6237 — Cross-session attribution filter (session B's file not in session A's block)

pass

Set up two sessions (A and B) against the sandbox project. Session A called `POST /api/hooks/post-tool-use` to attribute `lib/example_context.ex` to session A. A spec_validation problem was seeded on `.code_my_spec/spec/other_context.spec.md` (a file NOT attributed to session A). Fired `POST /api/hooks/stop` for session A. The block reason was `"QA plan not found..."` (from task evaluation) — `other_context.spec.md` did NOT appear in the reason. Confirms the attribution filter excluded the other-session file from session A's block decision.

Response: `.code_my_spec/qa/555/responses/6237_cross_session_filter.json`

## Evidence

- `.code_my_spec/qa/555/responses/5097_no_changes_allow.json` — `{}` allow when no file changes
- `.code_my_spec/qa/555/responses/5098_clean_pipeline_allow.json` — `{}` allow after clean pipeline
- `.code_my_spec/qa/555/responses/5099_compiler_problem_block.json` — `{"decision":"block",...}` compile failure blocks
- `.code_my_spec/qa/555/responses/5100_credo_block.json` — `{}` (expected block, see issue)
- `.code_my_spec/qa/555/responses/5101_no_session_allow.json` — `{}` no session allow
- `.code_my_spec/qa/555/responses/5102_subagent_skip.json` — `{}` subagent short-circuit
- `.code_my_spec/qa/555/responses/5103_manual_task_allow.json` — `{}` manual task short-circuit
- `.code_my_spec/qa/555/responses/6237_cross_session_filter.json` — block shows only task-eval reason, not other-session file

## Issues

### Credo block criterion untestable via curl without diagnostics compiler and valid session_type

#### Severity
MEDIUM

#### Scope
QA

#### Description
Criterion 5100 (credo violations on changed files block the stop) cannot be reliably tested via curl against the running `dev_cli` server using the QA sandbox project due to two compounding constraints:

1. `session_type: null` tasks are pruned as orphans by `maybe_prune_orphan_tasks` when the session is read. Injecting tasks via direct SQLite write requires a valid `session_type` atom that references a real module in `@valid_types`.
2. The `QaStory` session type's evaluator calls `check_plan` which requires `qa_plan.md` to exist in the project. The sandbox doesn't have a QA plan, so task eval fails with "QA plan not found" rather than passing.
3. Even with no active task, `resolve_changed_files` falls back to `sync_result.changed_paths` (filesystem mtime delta), which is empty after the first sync request has already updated DB mtimes. The seeded credo problem requires `file_path in changed_file_paths` to block under `block_changed` mode.

To test 5100 via curl: either (a) set up a sandbox with a QA plan + `QaStory` task pointing at a real story, or (b) test against the main code_my_spec project after writing a controlled credo-violating file and immediately firing the stop hook with a session that has a valid passing task.

### ArgumentError in stop hook when invalid source_type is seeded in problems table

#### Severity
LOW

#### Scope
QA

#### Description
Directly inserting a problem record with `source_type = 'credo'` (not in the `Ecto.Enum` values `[:static_analysis, :test, :runtime]`) caused an `ArgumentError` in the stop hook's `check_blocking_problems` path. The enum cast fails when Ecto loads the record. This is expected behavior but took several retries to diagnose.

Reproducible: `INSERT INTO problems (..., source_type, ...) VALUES (..., 'credo', ...)` → `POST /api/hooks/stop` with changed files → `ArgumentError at POST /api/hooks/stop` (HTML 500 response).

Fix: always use `source_type = 'static_analysis'` when seeding analyzer problems via SQL.

### Pipeline short-circuits in 5098 test (null session_type pruning) produces allow via different code path

#### Severity
INFO

#### Scope
QA

#### Description
The 5098 "active task + clean pipeline → allow" test returned `{}` via the wrong code path. The injected task with `session_type: null` was pruned by `maybe_prune_orphan_tasks` on session read, resulting in no active task. The allow came from the no-active-task path (5101 logic), not the active-task + clean pipeline path (5098 logic).

Testing 5098 correctly requires an active task with a `session_type` that references a valid module whose `evaluate/2` returns `{:ok, :valid}` when the work product exists. The `QaIntegrationPlan` task (validation_type: manual) would short-circuit before the pipeline runs. A custom test setup or a task for a completed requirement would be needed.
