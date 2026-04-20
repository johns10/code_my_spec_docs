# Stop Hook Contaminates Cross-Session Edits as "Changed Files"

## Problem

The stop hook's changed-files window is computed from filesystem vs. DB
mtime (or `Files.changed_since(task.started_at)` when an active task
exists), not from what **this session** actually edited. That pulls
in any file dirty on disk — including stale uncommitted WIP from
other Claude Code sessions, IDE saves, formatter runs, `git status`-
confusing noise — and treats all of it as in-scope for credo
`block_changed`, exunit `block_changed`, etc.

Concrete repro from today:

1. Session A commits work touching a handful of files under
   `lib/code_my_spec/agent_tasks/` and `test/spex/`.
2. The working tree has unrelated uncommitted edits in
   `lib/code_my_spec/components/component_repository.ex`,
   `lib/code_my_spec_web/live/content_live/pages/metric_flow.ex`,
   `test/code_my_spec/agent_tasks/qa_app_test.exs`, etc. from Session
   B's in-progress work.
3. Session A's stop hook fires.
4. `sync_changed` sees every dirty file. Credo on those files reports
   trailing whitespace / missing @moduledoc / nested-module aliases.
5. With `credo: block_changed`, all of them end up in
   `changed_file_paths` and block Session A's stop — even though
   Session A never touched any of them.

The agent has no way to fix what it didn't break, and the advisory/
blocking split is meaningless because the scope is wrong.

## Why it happens

`Validation.resolve_changed_files/3`:

- Active task (`started_at` set): `Files.changed_since(scope,
  task.started_at)` — every file whose DB `updated_at >= started_at`.
  Catches anything the FileWatcher or another session synced after
  `started_at`, not just this session's writes.
- No active task: `sync_result.changed_paths` — every file whose
  filesystem mtime > DB mtime. Catches every dirty file in the
  working tree, including ones this session never touched.

Neither branch knows which files **this session's transcript** wrote,
only which files are dirty relative to state stored outside the
session.

## Prior art

We solved the same class of bug in another context by parsing the
Claude Code transcript (the JSONL conversation log the harness writes)
for `Edit` / `Write` tool results — the authoritative record of what
this session actually touched. That's the correct scope for
`block_changed`: only files **this session's tool calls** modified.

## Proposed fix

1. On the stop hook request, accept the session's transcript path (or
   a pre-computed list of touched files from the harness).
2. Intersect the computed `changed_files` with that "session-touched"
   set. Anything in `changed_files` but not in the set is either
   (a) stale WIP from another session → demote to advisory, or
   (b) not in scope at all → exclude entirely.
3. The existing `block_changed` semantics stay — just with a
   `changed_file_paths` that's accurate to the session instead of
   accurate to the filesystem.

Fallback when no transcript available (e.g. freestyle CLI without
Claude Code): current behavior. Flag the session as "best-effort
scope" in logs.

## Related

- `.code_my_spec/issues/validation-pipeline-redesign/` — this is a
  gap on top of the pipeline redesign. The redesign's `block_changed`
  semantics are correct; the scope source is wrong.
- The compactness work in Story 554 made the blast radius smaller
  (response is capped), but the underlying scoping bug still forces
  the agent to react to problems it didn't create.
