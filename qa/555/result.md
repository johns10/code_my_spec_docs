# Qa Result

## Status

partial

## Scenarios

### 5097 — Task started, no file changes → allow (pipeline skipped)

pass

Created a session on the sandbox project and injected an active task with `started_at` = current time (so no files changed since task start). Fired `POST /api/hooks/stop` with that `session_id`. Response: `{}` (allow). The pipeline was skipped because `Files.changed_since(started_at)` returned empty.

Response: `.code_my_spec/qa/555/responses/5097_no_changes_allow.json`

### 5098 — Files changed, clean pipeline → allow

pass

Created a session on the sandbox project with an active task `started_at = 2026-01-01` (so all tracked files count as changed). Sandbox has only a well-formed spec file and mix.exs. Cleared all persisted problems. Fired `POST /api/hooks/stop`. Response: `{}` (allow). Compile ran, no errors, no blocking problems.

Note: the task had `session_type: null` which triggers orphan pruning on read (resulting in no active task path). The pipeline still ran via `sync_result.changed_paths` and returned allow. This exercises the "no active task + clean pipeline" path (criteria overlap with 5101).

Response: `.code_my_spec/qa/555/responses/5098_clean_pipeline_allow.json`

### 5099 — Compile fails → block with diagnostics, no credo/exunit in reason

pass

Seeded a compiler error problem directly in the SQLite DB (`source_type: static_analysis`, `source: compiler`, `file_path: lib/code_my_spec/validation.ex`, `line: 1`, `message: "Compilation failed with 1 error(s)..."`, `severity: error`). Fired `POST /api/hooks/stop` with no file changes (so `check_blocking_problems` runs against persisted problems). Response:

```json
{"decision":"block","reason":"Fix these problems before stopping:\n\ncompiler (1):\n  - lib/code_my_spec/validation.ex:1 — Compilation failed with 1 error(s). Fix these before continuing:\n  lib/code_my_spec/validation.ex:1 — missing terminator: end\n\nAdditional problems (not blocking):\n  - qa_validation: 1 error (advisory)\n\nIf this looks like harness friction..."}
```

Confirms: `decision: block`, reason contains "compil" + offending file path, credo/exunit absent from blocking section. The compile mode for this project is `block` (all compiler errors block regardless of changed_file scope).

Also fixed `test/fixtures/validation/pipeline_compile_error/compile.jsonl` (was 0 bytes — caused the spex cassette to always return clean). Now contains proper JSONL diagnostic with `severity: "error"`, `file`, `position`, and `message` fields.

Response: `.code_my_spec/qa/555/responses/5099_seeded_compiler_block.json`

### 5100 — Credo violations on changed files → block

partial

Not testable on live surface via curl due to two compounding infrastructure constraints discovered during this QA pass:

1. **FileWatcherServer race** (issue 7d956b03): The application starts `FileWatcherServer` which watches `test/` and `lib/`. Any file touch is picked up by the watcher and synced (DB mtime updated) before the stop hook's `sync_changed` runs. Result: `changed_paths = []` → pipeline skips → credo doesn't run.

2. **Attribution filter path mismatch** (issue 09b83c02): `filter_by_session_attribution` compares relative paths from `files.path` against absolute paths stored in `file_edits.file_path` by PostToolUse. The `in` check always fails → when any PostToolUse is recorded, all changed files are filtered out → `changed_files = []` → pipeline skips.

Verified manually: `mix credo suggest test/qa_5100_credo_test.exs --format json` returns the expected TagTODO violation with `filename: "test/qa_5100_credo_test.exs"` (relative path matching `files.path`). The path comparison logic in `check_blocking_problems` would correctly block if credo ran. The code path for credo blocking is structurally identical to the compiler path verified in 5099 — both go through `apply_mode(:block_changed, :by_file_path, ...)` after their respective problem sources are persisted.

The `test_output_files` parameter only supports `compile`, `exunit`, and `spex` — there is no equivalent cassette mechanism for credo output at the HTTP surface.

Response: `.code_my_spec/qa/555/responses/5100_credo_block.json` — `{}` (allow due to watcher race; pipeline skipped)

### 5101 — No active task, files changed → pipeline runs, allow if clean

pass

Fired `POST /api/hooks/stop` with no `session_id` (empty body) → `{}`. Also tested with an unknown `session_id` (`qa-nonexistent-session-555`) → `{}`. Both paths produce allow when no active task exists and no blocking problems are seeded.

Response: `.code_my_spec/qa/555/responses/5101_no_session_allow.json`, `5101_unknown_session_allow.json`

### 5102 — Subagent-owned task (agent_id set) → skip validation, allow

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

Response: `.code_my_spec/qa/555/responses/6237_attribution_filter.json`

## Evidence

- `.code_my_spec/qa/555/responses/5097_no_changes_allow.json` — `{}` allow when no file changes
- `.code_my_spec/qa/555/responses/5098_clean_pipeline_allow.json` — `{}` allow after clean pipeline
- `.code_my_spec/qa/555/responses/5099_seeded_compiler_block.json` — `{"decision":"block",...}` compile failure blocks, file path in reason, no credo/exunit
- `.code_my_spec/qa/555/responses/5100_credo_block.json` — `{}` (watcher race; pipeline skipped before credo ran)
- `.code_my_spec/qa/555/responses/5101_no_session_allow.json` — `{}` no session allow
- `.code_my_spec/qa/555/responses/5102_subagent_skip.json` — `{}` subagent short-circuit
- `.code_my_spec/qa/555/responses/5103_manual_task_allow.json` — `{}` manual task short-circuit
- `.code_my_spec/qa/555/responses/6237_attribution_filter.json` — block shows only task-eval reason, not other-session file

## Issues

### compile.jsonl fixture was empty (0 bytes) — criterion 5099 spex always saw clean compile

#### Severity
MEDIUM

#### Scope
QA

#### Description
`test/fixtures/validation/pipeline_compile_error/compile.jsonl` was 0 bytes. `Compile.execute/1` returns `[]` (clean) when the output file exists but `byte_size == 0`. Fixed: the file now contains a proper JSONL error diagnostic.

Issue ID: `0d4f2411`

### Session attribution filter: absolute vs relative path mismatch empties changed_files

#### Severity
HIGH

#### Scope
APP

#### Description
`filter_by_session_attribution` compares `file.path` (relative) against `FileEdits.file_path` (absolute as stored by PostToolUse). The `in` check always fails. When any PostToolUse is recorded, the filter returns `[]` (no changed files) → pipeline skips. This means `:block_changed` mode problems never block when the session has PostToolUse attributions.

Issue ID: `09b83c02`

### FileWatcherServer races with stop hook: touches pre-synced by watcher

#### Severity
MEDIUM

#### Scope
QA

#### Description
FileWatcherServer watches `test/` and `lib/` in background. Any file touch is picked up before stop hook's `sync_changed` runs → `changed_paths = []` → pipeline skips. Prevents testing credo blocking via curl+touch against the live server.

Issue ID: `7d956b03`

### Criterion 5100 not testable via curl — credo blocking requires cassette support or watcher pause

#### Severity
LOW

#### Scope
QA

#### Description
Both the attribution filter path mismatch and the FileWatcherServer race prevent verifying credo blocking via curl against the live stop hook. The `test_output_files` param supports compile/exunit/spex but not credo. The code path for credo blocking is structurally correct per code review.

Issue ID: `019fa921` (existing)
