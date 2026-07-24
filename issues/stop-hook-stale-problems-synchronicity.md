# Stop-hook stale-problems: a synchronicity bug

**Status:** FIXED (2026-07-09) — superseded by the async Analysis run service.
The fix went further than the plan below: instead of Task.Supervisor +
yield-inside-the-request, the stop hook is now **fully async** — analyzers run
as supervised background jobs through `CodeMySpec.Analysis` (per-project
single-flight queue + run ledger keyed on input fingerprints), Problems
reconcile atomically (`Problems.reconcile_problems_for_source/4`, one
transaction) regardless of the HTTP connection's lifetime, and the stop
decision reads persisted Problems immediately. Stranded `:running` rows from a
dead server are failed at boot. `mix test`/`mix spex` from the agent are
rewritten (PreToolUse) into the same service, so model and system share one
run record. See stories 554/555/856/857.
**Related issues:** `af2711ff` (high, incoming), `5b3a05b6` (closed prematurely), `validation-pipeline-redesign`
**Severity:** high — makes the stop-hook evaluation (a flagship feature) unreliable; recurs constantly when dogfooding CodeMySpec on itself.

## Symptom

The Stop hook intermittently blocks with a list of ~39 "compiler" problems
(dead-clause / unused / "incompatible types" warnings) that **do not exist in
a clean compile**. Clearing them (`DELETE FROM problems WHERE source='compiler'`
+ `compile_warnings='dont_block'`) unblocks the agent, but they come back. The
result is a looping stop hook that blocks every stop on phantom problems and
makes `qa_complete` (and every other) task unsatisfiable.

## Root cause — it's a synchronicity bug, not a logic bug

`CodeMySpecLocalWeb.Hooks.StopController.run_and_decide/6` calls
`Validation.validate_stop/3` **synchronously, inline in the HTTP request** that
the hook fires via `curl --max-time 30` (see `CodeMySpec/hooks/hooks.json`).

`validate_stop` runs the full pipeline: `mix compile` (MIX_ENV=test) +
`mix test --stale` + `mix spex --stale` + problem reconciliation. On the large
dogfooded codebase this **routinely exceeds 30 s**.

The compiler reconciliation in `CodeMySpec.StaticAnalysis.Pipeline.compile/2`
runs in this order:

```
1. Compile.execute()                              # SLOW — the whole budget
2. convert diagnostics -> problems
3. clear_problems_for_source([source: "compiler"], :all)   # clear old
4. create_problems(...)                                     # insert new
```

When the 30 s curl aborts **during step 1**, the request handler is torn down
before steps 3–4 run. The previous compiler problems are never cleared, so they
are **stranded** in the DB. With `compile_warnings: :block`, those stranded rows
re-block the next stop — and the next compile is just as slow, so it never
recovers. The validation work is coupled to the HTTP connection's lifetime; a
timeout leaves the DB in a half-reconciled state.

(Why they look "stale/phantom": a clean cold compile emits 0 of them, but a
warm/incremental compile of recently-touched files re-emits them, and whichever
set was present when the abort happened is what sticks.)

## The fix (priority order)

**#1 and #2 are the actual fix; the rest is hardening.**

1. **Decouple validation from the request.** Run `validate_stop` in a
   `Task.Supervisor` task so the compile + reconcile **always complete and
   persist**, regardless of whether curl is still listening. This alone kills
   the stranded-problems bug.

2. **Await with a sub-budget timeout.** In `StopController`, `Task.yield(task,
   ~25_000)` (under the 30 s curl):
   - completes in time → return the real block/allow decision;
   - times out → return a soft **allow** ("validation still running, results
     apply next stop") and **do not kill the task** — it finishes and reconciles
     for the next stop. No hard-block-on-timeout, no stale rows.

3. **Atomic reconcile.** Wrap `clear_problems_for_source(:all)` +
   `create_problems` in a single `Repo.transaction` so it is all-or-nothing.

4. **More headroom + lighter gate.** Bump `--max-time` in `hooks.json` to ~90 s,
   and consider making `test --stale` / `spex --stale` advisory/async — `compile`
   is the real blocking signal; the test suites don't need to gate every stop.

5. **Dogfood amplifier.** The server validates its own large codebase in
   MIX_ENV=test, contending with the running server's `_build`. Give validation
   its own `MIX_BUILD_PATH` (or a cached manifest) so it stops competing and runs
   faster.

## Files

- `lib/code_my_spec_local_web/controllers/hooks/stop_controller.ex` — `run_and_decide/6` (task-decouple + yield-with-timeout)
- `lib/code_my_spec/static_analysis/pipeline.ex` — `compile/2` (transactional reconcile)
- `CodeMySpec/hooks/hooks.json` — Stop/SubagentStop `--max-time`

## Temporary recovery (until fixed)

```
sqlite3 ~/.codemyspec/cli_dev.db "DELETE FROM problems WHERE source='compiler';"
sqlite3 ~/.codemyspec/cli_dev.db "UPDATE project_configurations SET compile_warnings='dont_block' WHERE project_id=(SELECT id FROM projects WHERE name='Code My Spec');"
```

## Testing notes

- Add a spex that simulates the timeout: a slow/aborted `validate_stop` must
  leave the Problems table reconciled (not stranded) once the task completes.
- Implement from a **fresh session** — patching the stop hook from inside a
  misbehaving stop hook fights itself.
