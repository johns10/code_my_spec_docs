# Analysis and validation

How analyzer runs (compiler, credo, exunit, spex) are requested, executed,
reconciled into Problems and turned into promote decisions — the
design behind `lib/code_my_spec/analysis*`, `compile.ex`, `tests.ex`,
`static_analysis/`, `problems/`, `validation*`, the stop and pre-tool-use
hooks, and QA attempts. Code comments point here by section name.

| Module | Role |
|---|---|
| `Analysis` | The run service: admits, dispatches (local or harness) and awaits runs; settles orphans; harness fs transport. |
| `Analysis.Runners` | Executes a source locally, or converts a harness `analysis_result` (`from_raw/2`) into a result. |
| `Analysis.Reconciler` | The single write path for run results: Problems, ledger row, events. |
| `Analysis.RunsRepository` | The `analysis_runs` ledger, scoped per working copy. |
| `Analysis.HarnessRegistry` | Which working copies have a connected harness, keyed to its channel process. |
| `Compile`, `Tests`, `StaticAnalysis.CredoRun` | Run one tool and parse what it reported. |
| `StaticAnalysis.Pipeline` | In-process analyzers for a task's role. |
| `Problems.ProblemRepository` | Problems rows: reconcile per source, cleanup. |
| `Problems.ProblemRenderer` | Problem text for task feedback and `list_problems`. |
| `Validation` | What a stop does first: file sync and the in-process validators. Never refuses. |
| `Validation.Blocking` | The one definition of "may block" and "enforceable", read by promotion. |
| `Hooks.Stop`, `Hooks.PreToolUse` | Claude Code hook entry points. |
| `Qa.QaAttempts` | QA attempt records. |

## Where a run executes

- Analysis is explicit: `start_analysis`, ready-for-QA certification and
  promotion. A stop never starts, waits on or reports a run.
- `Analysis.remote_executor/1` answers from `HarnessRegistry`: the harness
  channel holding the scope's working copy, or `:none`. The pid is both "can a
  run happen" and where it is sent, so a run is never queued for a harness that
  has gone.
- **Locally**: the per-copy `ProjectServer` (`server_key/1`: `{:harness, copy}`
  or `{:project, id}`), serialised; `:inline` mode (test env) runs in the
  caller.
- **Remotely**: the row is opened here first, then `{:run_analysis, ...}` is
  sent to the channel; the result returns through `record_remote_result/2` →
  `Runners.from_raw/2` → Reconciler, the same conversion a local run uses. A
  request the harness never answers stays traceable and is failed when its
  channel closes.
- A busy source is sent anyway: the harness serialises (one task at a time)
  and holds at most two entries per source, executing and queued, tying further
  requests onto the queued one. Once two full rows are open, a new request
  joins the newest row instead of opening a third. Dropping a request for a
  busy source left a run answering about the pre-commit tree.
- A tied run's result carries `tied_to`; only the primary reconciles
  (`Reconciler.finish_tied/3` closes the rest), or every problem is written
  twice. A partial run a full request tied onto ran the whole suite and is
  reconciled as full.
- Compile-error skip: every non-compiler source is failed
  `:skipped_compile_errors` while compile errors stand
  (`Execution.skip_for_compile_errors?/2`), decided before sending for remote
  runs.
- `await_run/4` subscribes to `analysis:<project_id>` before dispatching and
  matches on the run id, never the source. Its deadline (31 min) exceeds the
  harness's own 30-minute kill, so a killed run reports as that failure.
- Path-like args make a run `:partial`: output only, Problems untouched, never
  fresh (`latest_full_run/2` ignores it).

## Orphaned runs

- `fail_in_flight/3` (channel down or join) and `fail_stranded_runs/0` (boot)
  close `:running` rows as orphans (`stats.orphaned`), sparing what the harness
  claims at join. The requester is not told then: its transport is the harness
  that just went away.
- `resume_orphaned/2` on the next join, oldest first: claimed → reopened;
  answer owed (`agent_id` recorded by `start_analysis`, or waiters) → rerun
  with the same requester; killed 3 times → reported failed; otherwise left
  closed. An analyzer's own failure is never an orphan.

## In-flight state

- `in_flight_state/1` is `{:running, sources}`, `:idle` or `:untracked`. A
  local project with no `Analysis.Registry` entry is untracked: nothing would
  know if a run were in flight, which must not read as idle.
- A harness-served copy is tracked by definition: `:running` ledger rows are
  the record, and the channel lifecycle closes stranded ones.
- `await_all/2` returns `:timeout`, distinct from `:ok`.

## Harness registry

- A unique-key `Registry` keyed by working copy id; the value is
  `{instance, root}` and the registered process is the channel, so entries die
  with it. Started by `CodeMySpecWeb.Application`; its own leaf boundary.
- Registration from the same instance and root takes the slot back (evicting
  the old channel and waiting for its `:DOWN`): a client-side channel can die
  while the socket stays open, leaving an entry nothing would release.
- Same instance, different root is `:id_collision`: one daemon serves several
  copies, and evicting there made two siblings evict each other in a loop.
- A different instance, or an unknown one, is `:already_registered`: two
  harnesses on one `_build` corrupt it.
- `register_verb/2` / `supports?/2` let a caller avoid sending a push an older
  harness would never answer. `host_holder/1` picks any connected copy with a
  root as the machine to create a sibling worktree on.

## Harness filesystem requests

- `Analysis.harness_fs_request/4` is the `ExecutionContexts.HarnessTransport`
  implementation; it is declared in `Environments` (a leaf) to avoid a cycle.
- Each failure has its own tag, because the fixes differ:
  `:harness_not_registered` (rejoin), `:harness_timeout` (accepted, never
  answered; carries `limit_ms`), `:harness_gone` (died; carries `down`, no
  limit), `:harness_self_call` (wiring bug here), `:harness_registry_down`.
- `{:shutdown, :draining}` from an op that restarts the application is
  success; `Promotion.restart_acknowledgement_lost?/1` decides it.
- A harness's own `/health` saying connected is about its socket, not about
  whether the server can address it.

## Runner results

- `Runners.run/4` executes locally; `Runners.from_raw/2` converts a harness
  result, and `run/4` goes through it too, so both paths read a diagnostic the
  same way.
- Problems come back without `project_id`; the Reconciler stamps it and
  resolves `component_id` from Files.
- `partition` (the test database the suite opened) is sent only by exunit and
  spex and stored once in `stats["partition"]`.
- `output` is the tool's own text (`.code_my_spec/rules/analysis_output_fidelity.md`);
  `format_problem_lines/1` is a fallback for a harness that sends none. Capped
  at 100,000 bytes on a character boundary (a split multibyte character makes
  Postgres refuse the row).
- `error_excerpt/1` takes the last line starting `** (`, else the last three
  lines; it lands in `stats["error"]`, truncated to 500.

## A run that saw nothing is not clean

- A `:completed` run with zero problems means "looked, and it is clean", and
  the Reconciler replaces a source's Problems wholesale. So a run that could
  not look must fail.
- Compiler: `diagnostics_available == false` fails with
  `{:compile_diagnostics_unavailable, exit}` — keyed on availability, because
  `mix compile --return-errors` exits 0 on a compile error.
- exunit: `execution_status: "error"` or exactly `stats: %{"tests" => 0}`
  fails with `{:test_suite_did_not_run, exit, excerpt}`.
- spex: nonzero exit with no failures fails with
  `{:spex_suite_did_not_run, exit, excerpt}` (`Spex.parse_jsonl/1` answers
  `{:ok, []}` for a missing file).
- A payload with no `diagnostics` key raises; unknown shapes get
  `{:unreadable_result, source}`. `apply_remote_result` fails the run on a
  raise rather than leaving it open.
- `CredoRun`, `Analyzers.Credo` and `Analyzers.Sobelow` return an error, never
  `{:ok, []}`, on output they cannot parse.

## Never drop diagnostics

- Whatever the analyzer reports is recorded; no heuristic filters it.
- A missing-module message is real: spec-first spex against unbuilt code
  produce exactly that, and discarding it kept a source's Problems from ever
  clearing.

## Spex failure location

- A spex failure belongs to its spec or to no file, never to the library frame
  that raised it.
- Preference: the first stacktrace frame whose file ends `_spex.exs` (file and
  line from that frame); `error.file` if it is a spec; the declared
  `spec_file` with line `nil`; else `{nil, nil}`. Never pair a spec path with
  another frame's line.

## Run ledger

- Runs are inserted `:running` and finished once; finished runs are pruned to
  the newest 20 per `{project, source}`.
- Queries are scoped to the working copy through `scope_to_harness/2`. A nil
  copy means no filter, right only for reporting; writers handle nil
  explicitly (`fail_running/3` → `{:ok, []}`, `running_full_runs/2` → `[]`).
- `latest_completed_run/2` decides a source's findings, so a failed run cannot
  displace a good result; `latest_full_run/2` includes failures, for reporting.
  Anything describing an answer (age, commit) reads `Analysis.latest_answer/2`.
- `running_since/1` gives start time per source; `wait_on_running_at_commit/4`
  adds an agent to a matching run's `requested_by["waiters"]`.

## Reporting runs

- The Reconciler emits `[:code_my_spec, :analysis, :run_reconciled]` (task
  re-evaluation in `AgentTasks.RunReconciled`, the phone push in
  `Notifications.AnalysisPush`) and `:run_reported` (agents, via
  `Agents.AnalysisReport`). Events because Analysis sits below those contexts.
- `:run_reported` fires only when the run found a signature the previous
  completed run did not, or when an agent requested or waits on it. Every stop
  re-enqueuing credo once made an unchanged finding announce itself each turn,
  livelocking a main agent.
- A requested run always answers, even unchanged or clean: signatures
  (`file:line criterion`) omit the error, so a spex sweep failing the same
  criteria for a new reason looked unchanged and its asker waited forever.
- Every path that fails a run ends in `Reconciler.announce_failed/2`.
- A Claude Code session is not told: problems gate at promotion, and an agent
  that wants them asks `list_problems`.

## Compile

- `mix compile --return-errors` with `DIAGNOSTICS_OUTPUT` pointing at a temp
  file the `:diagnostics` compiler writes; `force: true` adds `--force`
  (incremental compile reports only what it recompiled).
- The generated path is read through the environment, since the child writes
  it where it runs; an injected `:output_file` is a fixture on the host.
- A nonzero exit with no diagnostics file is transient unless a line starts
  `** (CompileError)`, `** (SyntaxError)`, `** (TokenMissingError)`,
  `== Compilation error in file` or `error:`.
- Unsatisfied deps are checked first and reported as a problem telling the
  agent to run `mix deps.get`; they never heal on their own.

## Problem file paths are relative

- Problem paths are relative to the working copy root. Compiler `file` and
  `source` are relativized against `env.cwd`.
- `clear_problems_for_missing_files/2` deletes any Problem whose path is not in
  the relative file list, so an absolute path vanishes on the next sync.
- `Reconciler.patch_file_path/1` warns on an absolute path rather than
  rejecting it: a rejection would roll back the source's other findings. A nil
  path becomes `"unknown"` (kept by cleanup; cleared by the next full compiler
  reconcile).

## Test databases

- The exunit analyzer never shares the agent's test database: a caller-set
  `MIX_TEST_PARTITION` is kept, else `_<basename(cwd)>_analyzer`. Never a
  constant (`config/test.exs` uses the partition for its per-worktree name).
- Never created or migrated from code; a missing database surfaces as the
  child's own error.
- Env is built with `merge_clean_env/1`: the OTP scrub unsets `MIX_ENV`, and
  ecto tasks do not force the test env.

## Scan all, clear all

- Every in-process analyzer scans the whole project (`files_for_analyzer/3`
  returns `nil`) and clears its source with `:all`. Clearing keyed on files a
  result names cleared nothing when a partial scan came back clean.
- The config mode decides what blocks (`apply_mode` in Validation), not what is
  scanned.
- A role that an analyzer files findings against must schedule it (`bdd_spec`
  and `test` carry `:credo`). Config gates only role-derived analyzers;
  task-declared ones are never filtered.

## Problems

- Problems are scoped per working copy. No working copy means the project's
  default one on both read (`WorkingCopies.default_id/1`) and write
  (`ensure_default/1`), never every copy.
- `reconcile_problems_for_source/4` clears one source over a file scope and
  inserts the new set in one transaction, so the old set stays readable until
  the new one lands. No lock: tied runs are handled at their cause.

## Validation and blocking

- Problems gate at promotion only (John, 2026-10-18). A stop never refuses over
  them, the stop menu mentions the count as information, and no tool call is
  annotated with them. Stop-time blocking (per-source modes, attribution,
  demotion, the stop response) was removed then, with its criteria.
- `Validation.validate_stop/3` still runs at every stop: `FileSync.sync_changed`,
  `ComponentSync`, then the in-process validators, which record Problems. It
  always answers `{:ok, _}`. No project → nothing to do; `cwd: nil` or
  `{:cannot_scan, _}` → the harness holding the copy, or nothing.
- `ProjectConfiguration` keeps two switches (`qa_validation`, `architecture`;
  only `:off` is checked, legacy block modes read as on) and
  `advisory_findings`, which decides whether `:info` findings block promotion.
- `Validation.Blocking` is a leaf read by Promotion and `Agents.Menu`: one
  definition of "may block" and "enforceable".

## Spex story attribution

- Every located red spex blocks, whatever its story's latch: analysis runs only
  at certify and promote. A spex finding with no location (nil or "unknown")
  is advisory.
- Assignment does not exempt a finding. `story_assignment` (`:mine`,
  `:unassigned`, `{:elsewhere, label}`) and `specs_ready_stamp` are
  orientation only.
- `Blocking.story_id_for/4`: criterion `spec_path` → `files.story_id` → the
  directory name parsed as a story number → the directory's common story. A
  number matching no story is nil, never a story that happens to hold that id;
  a directory spanning several stories is nil.

## Changed files

- What a stop's in-process validators read. Local: the agent's recorded edits
  (`FileEdits` by `agent_id`) if any, else `Files.changed_since(task.started_at)`
  (or the scan's changed paths with no task), narrowed to the session's
  PostToolUse edits, relativized against cwd.
- Remote with a task: `changed_files_for_task/3`, nothing consumed. Remote
  without a task: the session's recorded paths, consumed after use. The
  agent-only ledger is never consumed.
- A session with zero recorded edits: over 25 dirty files → empty set (likely
  a rebase); `Session.git_rewrite_at` at or after task start → empty set;
  otherwise the dirty set is kept.

## Stop hook

- `Hooks.Stop.decide/2` never refuses over problems. Allow is the default; a
  missing or unknown `session_id` logs a warning (except before `init_project`).
- Order: a live subagent task exempts the parent (task `:active`, has an
  `agent_id`, agent in `Session.active_subagents/2` by heartbeat TTL — a task
  row alone outlives a killed subagent) → stuck threshold → manual task allows
  → `Validation.validate_stop/3` → task evaluation.
- A refusal comes from the active task's evaluation (its requirement is not
  met; problems never fail a task, `ProblemFeedback.combine/2`) or from the
  loop: continuous mode after a valid evaluation blocks with `Menu.render/4`
  while `Work.actionable/3` is non-empty. Nothing actionable → allow with a
  retrospective.
- Stuck detection counts repeated evaluation feedback. At 5, a continuous
  session is switched off, notified and given a retrospective; a
  non-continuous one gets an allow saying nothing was fixed.
- A refusal's reason is capped at 4096 bytes, menu and framework-issue footer
  budgeted first. A refusal's menu never carries the tap-out offer.

## Routing analysis commands

- `Hooks.PreToolUse.decide/4` rewrites a Bash `mix test`/`spex`/`compile`/
  `credo` into one plain `curl` to the analysis service (timeout 600s). The
  caller states `served_by`: `:local` → `POST /api/analysis/run` with
  `X-Harness-Id`; `:harness` → `POST /api/harnesses/<id>/analysis/run`. No
  filesystem path goes on the wire.
- test/spex are routed per segment through `CommandShape`, keeping redirects
  and pipes; a segment after `cd` only when the directory is inside the copy.
  compile/credo only as a whole simple command.
- Passed through unrouted: shell metacharacters in args, an env prefix other
  than `MIX_ENV=test`, unbalanced quotes, `$` or backticks in args, a
  subagent's nested checkout.
- A failing run answers 422 with the tool's output; `--fail-with-body` exits
  nonzero like `mix test`. No `sh -c` (auto mode refuses it).
- An unroutable test command logs why; it never returns the silent `%{}` of
  "not a test command". `route_command/4` is shared with the in-app agent bash
  tool.
- `mcp__plugin_codemyspec_*` tools get `session_id` and `agent_id` merged into
  their input.

## Subagent git

- A subagent (non-empty `agent_id`) may run only read-only git subcommands:
  `log show diff status blame rev-parse describe shortlog whatchanged`. The
  danger is mutation, and the stop hook's own advice (`git log -1 -- <path>`)
  must stay runnable.
- Every git in a compound command must be read-only; an unparseable `git` is
  denied; global options (`-C`, `-c`, `--no-pager`, `-P`, `--git-dir=`,
  `--work-tree=`) are skipped to find the subcommand.

## Lessons

- **A run that could not look must fail, never answer `{:ok, []}`.** An empty
  completed run clears every Problem of its source and certifies it.
- **Exit status is not "it compiled".** `--return-errors` exits 0 on errors.
- **Never filter diagnostics on a heuristic.** A missing-module message is a
  real spec-first failure.
- **A spex failure goes to its spec or to no file.** The raising library frame
  loses the story link and blocks the wrong person.
- **Read files the child wrote through the environment.** A host read misses,
  and the miss parses as clean.
- **Scope ledger queries to the working copy, and handle nil in writers.** An
  unscoped sweep killed every other checkout's runs.
- **Scan and clear over the same set**, or stale findings stay or real ones go.
- **A request for work must never be dropped because the work is busy.** Queue
  it; "don't run two at once" is not "forget a second was wanted".
- **A reply to a question the agent asked always arrives.** Dedup unsolicited
  repeats only; silence to an asker is a hang.
- **Never answer success for a wait that gave up.** `:timeout` and `:ok` read
  the same once made a running queue look complete.
- **Absent information is not good news.** Untracked is not idle.
- **One tag per failure cause.** A single `:harness_unreachable` sent readers
  after registration problems that were not there, and a death read as a
  timeout.
- **Identity checks need both halves.** Same instance is not same checkout; one
  daemon serves several.
- **Don't hash rendered text for repeat detection**: relative ages change every
  stop.
- **An empty ledger means "no edits recorded", not "no edits made"**, and disk
  never widens attribution.
- **Consume a ledger only after every read of it has been acted on.**
- **Resolve directory names through story numbers**, so a mismatch lands in the
  loud nil branch.
- **Let the caller state which router answers**; inferring it from `cwd` sent
  proxied copies to a 404.
- **Never rewrite part of a shell command**; swallowed redirects vanish
  silently.
- **Gate subagent git on mutation, not on the tool.**
- **A gate that stops blocking must say so.**
- **A repeated block needs an escape whether or not a loop is running.**
- **Ask liveness of the thing that expires** (heartbeats), not task rows.
- **Fix duplicate writes at their cause, not with locks**: advisory locks
  exhausted the pool; tie-aware delivery fixed it.
- **"No working copy" must mean the same on read and write**, or one checkout
  deletes another's findings.
- **A signal on every tool call must be cheap, quiet and actionable**, or it
  becomes wallpaper and gets switched off.
- **Name the remedy when one exists** (stale deps → `mix deps.get`).
