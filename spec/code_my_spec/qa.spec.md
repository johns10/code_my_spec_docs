# CodeMySpec.Qa

Per-story QA workflow context. Owns the typed-event audit trail for QA
attempts on stories. Replaces the file-parsing evaluator in
`CodeMySpec.AgentTasks.QaStory` with DB-backed events submitted
through dedicated MCP tools.

## Type

context

## Stories

- **726** — *Agent submits QA outcomes through validated tool calls* (agent-surface lens)
- **727** — *Engineer trusts QA pass claims as audit-grade events* (engineer-audit lens)

Both stories tagged `epic:qa`. The BDD spex suite at
`test/spex/726_*` and `test/spex/727_*` is the behavioural
contract — this module is the public boundary that delegates to
sub-modules realising that contract.

## Public API

```elixir
@spec submit_qa_result(Scope.t(), map()) :: {:ok, QaAttempt.t()} | {:error, Ecto.Changeset.t()}
def submit_qa_result(scope, params)
```
Submit a QA outcome for an active `qa_complete` task. Creates an
immutable attempt row. Required params: `task_id`, `status`
(`:pass | :partial | :fail`), `scenarios` (non-empty list of
`%{name, status, observation}`). Optional: `issue_ids` (list of
issue UUIDs from prior `create_issue` calls). Multiple submissions
on the same task_id are allowed — each creates a new attempt; the
latest is canonical for `qa_complete?/2`. Only `status: :pass`
satisfies `qa_complete`.

```elixir
@spec list_qa_attempts(Scope.t(), story_id :: integer()) :: [QaAttempt.t()]
def list_qa_attempts(scope, story_id)
```
Returns the QA history for a story, most-recent first. Each entry
preloads `:invalidations` so the caller sees both the attempt and
any invalidation events with reason / engineer / timestamp.

```elixir
@spec invalidate_qa_attempt(Scope.t(), attempt_id :: String.t(), reason :: String.t()) :: {:ok, Invalidation.t()} | {:error, Ecto.Changeset.t() | atom()}
def invalidate_qa_attempt(scope, attempt_id, reason)
```
Engineer action — invalidates a prior passed attempt with a
non-empty `reason`. Audit-stamped with the engineer's user id and
the current UTC timestamp. The original attempt row is preserved;
the invalidation is recorded as a separate `Qa.Invalidation` row.
If no other valid pass remains on the story, `qa_complete?/2`
re-clamps.

```elixir
@spec qa_complete?(Scope.t(), story_id :: integer()) :: boolean()
def qa_complete?(scope, story_id)
```
True iff at least one attempt with `status: :pass` exists for the
story AND has not been invalidated. Filesystem state (legacy
`result_complete.md` files) is not consulted.

```elixir
@spec complete_check(Scope.t(), story :: map()) :: {boolean(), map()}
def complete_check(scope, story)
```
Requirement-checker adapter invoked by `RequirementCalculator` via
`check_type: :delegate` for the `qa_complete` requirement node.
Returns `{true, %{status: ...}}` or `{false, %{reason: ...}}`.
Wraps `qa_complete?/2` with the shape the calculator expects.

## Child Components

| Module | Type | Role |
|---|---|---|
| `CodeMySpec.Qa.QaAttempt` | schema | Immutable attempt row (uuid pk, embeds scenarios) |
| `CodeMySpec.Qa.Scenario` | schema (embedded) | Single tested scenario (name + status + observation) |
| `CodeMySpec.Qa.Invalidation` | schema | Audit event for engineer invalidation |
| `CodeMySpec.Qa.QaAttempts` | module | submit/list/complete? CRUD + queries |
| `CodeMySpec.Qa.Invalidations` | module | invalidate action |

MCP surface lives separately at `CodeMySpec.McpServers.Qa.Tools.{SubmitQaResult, ListQaAttempts, InvalidateQaAttempt}`.
LiveView surface lives at `CodeMySpecLocalWeb.QaHistoryComponent`.

## Migration from legacy file-parsing flow

Prior to this context, `qa_complete` was satisfied by the existence
of `.code_my_spec/qa/<story_id>/result_complete.md` on disk. That
mechanism was trivially bypassable (issue **bf3b7404**). The
requirement checker now delegates to `complete_check/2` (DB-driven);
filesystem residue is irrelevant.

Existing `result_complete.md` files from the legacy flow can be
seeded into the new schema with the one-off script at
`priv/repo/scripts/migrate_qa_attempts_from_files.exs`. Stories that
were previously passed under the legacy flow but not migrated will
revert to `qa_complete: unsatisfied` until properly resubmitted via
`submit_qa_result` — intentional per story 727's audit-grade
requirement.
