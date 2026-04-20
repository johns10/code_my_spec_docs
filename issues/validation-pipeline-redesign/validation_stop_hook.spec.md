# Feature: Stop Hook Validation Pipeline

The stop hook is Claude's exit gate. When Claude tries to stop, we sync files,
compile, run analyzers, run tests, check for blocking problems, then decide
whether to let it leave or send it back to fix things.

Two layers with clear responsibilities:
- **Validation** writes to DB (sync, compile, analyze, test)
- **TaskEvaluator** reads from DB (requirement satisfaction check)

## Scenario: No files changed during task

This is the fast path. Claude read some files, thought about it, decided to stop.
Nothing to validate.

  Given a session with an active task started 5 minutes ago
  And no files have been modified since the task started
  When the stop hook fires
  Then file sync runs (safety net)
  And no compilation happens
  And no analyzers run
  And no tests run
  And the stop is allowed

## Scenario: Implementation file changed, compilation passes, tests pass

The happy path through the full pipeline.

  Given a session with an active ComponentCode task
  And the agent modified `lib/accounts/user.ex` during the task
  When the stop hook fires
  Then sync_changed picks up the file
  And compilation runs and passes
  And analyzers resolve to [:credo, :exunit_stale] (role-derived from implementation file)
  And credo runs on the changed file
  And `mix test --stale` runs
  And test problems are persisted to the DB
  And the task evaluator checks requirement satisfaction
  And the stop is allowed

## Scenario: Compiler errors block the stop

Compiler errors are the hardest gate. Nothing else runs.

  Given a session with an active task
  And the agent introduced a syntax error in `lib/accounts/user.ex`
  When the stop hook fires
  Then compilation runs and fails with errors
  And no analyzers run
  And no tests run
  And the stop is blocked with "Fix compiler errors"

## Scenario: Credo problems on changed files block the stop

  Given a session with an active task
  And the agent modified `lib/accounts/user.ex` with a credo violation
  When the stop hook fires
  Then compilation passes
  And credo runs and finds problems on the changed file
  And the stop is blocked with the credo problems listed

## Scenario: Test failures on touched components block the stop

  Given a session with an active ComponentCode task for the Accounts.User component
  And `mix test --stale` produces 3 failures in that component's tests
  When the stop hook fires
  Then the test failures are persisted as exunit problems
  And the failures are on the same component the task is working on
  And the stop is blocked with the test failures listed

## Scenario: Test failures on OTHER components are advisory, not blocking

  Given a session with an active ComponentCode task for the Accounts.User component
  And `mix test --stale` produces failures only in the Sessions component
  When the stop hook fires
  Then the test failures are persisted as exunit problems
  But the failures are on a different component than the task
  And the stop is allowed
  And a warning is logged about test failures on other components

## Scenario: No active task but files changed on disk

Claude was working outside of a task (no start_task called). We still need to
catch broken code.

  Given a session with no active task
  And the FileWatcher has seen changes to `lib/accounts/user.ex`
  And the FileWatcher updated the file record metadata but NOT mtime
  When the stop hook fires
  Then sync_changed sees the file as dirty (mtime still stale)
  And compilation runs
  And analyzers run based on the file's role
  And tests run if :exunit_stale resolves
  But task evaluation is skipped (no task to evaluate)
  And the stop is allowed

## Scenario: Active subagent task skips everything

The main agent is orchestrating subagents. When the main agent tries to stop,
we don't validate — the subagents are still working.

  Given a session with an active subagent task
  When the stop hook fires for the main agent
  Then no validation runs
  And no task evaluation runs
  And the stop is allowed immediately

## Scenario: Manual validation task skips evaluation

Some tasks are validated by humans, not by the pipeline.

  Given a session with an active task that has validation_type: :manual
  When the stop hook fires
  Then no validation runs
  And no task evaluation runs
  And the stop is allowed

## Scenario: Continuous mode blocks with next-task instruction

  Given a session in continuous mode (state.continuous = true)
  And the active task passes validation and evaluation
  And there are more actionable requirements in the graph
  When the stop hook fires
  Then validation passes
  And evaluation passes (task completed)
  And the stop is blocked with "Call get_next_requirement"


# Feature: Analyzer Resolution

Analyzers are resolved by merging two sources: what the changed files demand
(role-derived) and what the task module declares (task-declared). They augment
each other, not replace.

## Scenario: Role-derived analyzers from implementation files

  Given changed files with roles [:implementation, :test]
  And no task module analyzers/0 callback
  When analyzers are resolved
  Then the result is [:credo, :exunit_stale] (from @role_analyzers)

## Scenario: Task module analyzers augment role-derived

  Given changed files with role [:implementation] (gives [:credo, :exunit_stale])
  And the task module is ComponentCode which declares analyzers/0 = [:exunit_stale]
  When analyzers are resolved
  Then the result is [:credo, :exunit_stale] (merged and deduped)

## Scenario: Spec files trigger spec validation

  Given changed files with role [:spec]
  When analyzers are resolved
  Then the result includes :validate_spec
  And the spec file is validated against the document schema

## Scenario: BDD spec files do NOT trigger spex execution

Spex is slow. It only runs when the task explicitly asks for it.

  Given changed files with role [:bdd_spec]
  And the task module does NOT declare :spex_stale in analyzers/0
  When analyzers are resolved
  Then :validate_bdd is in the list (syntax check only)
  But :spex_stale is NOT in the list
  And `mix spex --stale` does NOT run

## Scenario: WriteBddSpecs task triggers spex execution

  Given changed files with role [:bdd_spec]
  And the task module is WriteBddSpecs which declares analyzers/0 = [:spex_stale]
  When analyzers are resolved
  Then :spex_stale IS in the list (from task-declared)
  And `mix spex --stale` runs


# Feature: FileWatcher and Sync Coordination

The FileWatcher keeps the requirements graph fresh in real-time.
The stop hook sync_changed does the authoritative mtime-based sync.
They must not step on each other.

## Scenario: FileWatcher updates metadata without consuming the change

  Given the FileWatcher detects a change to `lib/accounts/user.ex`
  When the FileWatcher processes the event
  Then it upserts the file record with correct role, component_id, story_id, valid
  But it does NOT update the mtime field
  And the file's updated_at IS refreshed
  So that sync_changed will still see filesystem mtime > db mtime

## Scenario: sync_changed picks up FileWatcher-processed files

  Given the FileWatcher already processed `lib/accounts/user.ex`
  And the file's db mtime is stale (FileWatcher didn't set it)
  When sync_changed runs during the stop hook
  Then it sees filesystem mtime > db mtime
  And it upserts the file with the correct mtime
  And it returns the file in changed_paths

## Scenario: sync_changed finds nothing when no files changed

  Given the FileWatcher has NOT seen any changes
  And no files have been modified on disk
  When sync_changed runs
  Then it reports 0 changed files
  And the validation pipeline skips everything


# Feature: Problem Persistence Scoping

Problems are persisted per-source, scoped to changed files for analyzers
and project-wide for compilation and tests.

## Scenario: Compiler problems are cleared project-wide

Mix compile gives us the complete picture for the whole project.

  Given existing compiler problems from a previous run
  When compilation runs (even if only 1 file changed)
  Then ALL old compiler problems are cleared (source: "compiler", scope: :all)
  And only the current compilation's diagnostics are persisted

## Scenario: Credo problems are cleared only for changed files

  Given existing credo problems on files A, B, and C
  And only file A changed
  When credo runs
  Then credo problems for file A are cleared and replaced
  But credo problems for files B and C are preserved

## Scenario: Test problems are cleared project-wide

mix test --stale handles its own dependency tracking, so we clear all
test problems and persist the current run's failures.

  Given existing exunit problems from a previous run
  When mix test --stale runs
  Then ALL old exunit problems are cleared (source: "exunit", scope: :all)
  And only the current run's failures are persisted

## Scenario: Analyzers that ran but found nothing still clear old problems

  Given existing credo problems on file A from a previous run
  And file A changed and credo runs but finds no issues
  When problems are persisted
  Then old credo problems for file A are cleared
  And no new problems are inserted
  And the requirement calculator now sees file A as clean


# Feature: Stop Response Compactness

The stop hook response goes straight into the agent's context window.
When the stop is blocked, every byte we emit is a byte the agent can't
spend on the fix. The response must be compact, scoped to what the
agent can act on, and hard-capped in size.

## Scenario: Advisory problems are summarized, not enumerated, when the stop is blocked

  Given a stop where credo finds 2 violations on changed files (blocking)
  And mix test --stale finds 45 failures on untouched components (advisory, block_changed demoted)
  When the response is formatted
  Then the blocking section enumerates both credo violations
  And the advisory section is a single summary line per source: "exunit: 45 failures on untouched scope (advisory)"
  And no individual advisory problem details appear in the response

## Scenario: Advisory problems do not appear when the stop is allowed

  Given a stop where the only problems are advisory (e.g. block_changed demoted everything)
  When the response is formatted
  Then the response is the allow signal (an empty map, %{})
  And the advisory problems are logged server-side
  And the agent receives no advisory text in its context

## Scenario: Blocking problem messages are compacted to one line

  Given an exunit failure whose message includes a stacktrace and left/right assertion dump
  When the problem is rendered into the blocking response
  Then the line is "file_path:line — first line of message, truncated to ~200 chars"
  And the stacktrace is stripped
  And the left/right dump is stripped

## Scenario: Per-source truncation caps problem enumeration

  Given 50 credo violations all on changed files (blocking)
  When the response is formatted
  Then the first N per source are listed (current cap: 10)
  And a footer says "... 40 more credo problems"
  And the agent is directed to use get_issue for details

## Scenario: Total response size is capped

  Given blocking problems whose formatted length would exceed 4 KB
  When the response is formatted
  Then later problems are truncated
  And a tail footer is appended: "... N more problems omitted (response size limit)"
  And the response body is under 4 KB

## Scenario: A single blocking problem is never further truncated

  Given one blocking credo violation with a 300-char message
  When the response is formatted
  Then the message is truncated to ~200 chars
  And the single problem fits under the size cap
  And no overflow footer is appended (nothing was omitted)
