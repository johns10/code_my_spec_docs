# Qa Story Brief — Story 874: Analysis Freshness

## Tool

curl (`:hook` pipeline on `CodeMySpecLocalWeb`, port 4004) for the observable
surface under test, plus one Vibium/web step against the hosted Configuration
LiveView (port 4000) to set the analyzer mode this scenario needs.

This story has no LiveView surface of its own — it is the Stop hook's JSON
response. `POST /api/hooks/stop` is the `:hook`-pipeline example the QA plan's
tool table names explicitly, so curl is correct per the plan's own rule
("pick by pipeline, not by guess").

## Auth

- **Local hooks (4004):** none. `Plugs.LocalOnly` accepts loopback directly.
  Every hook curl needs `X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`
  so `WorkingDirScope` resolves the QA Fixture Project
  (`11111111-1111-4111-8111-111111111111`).
- **Hosted Configuration page (4000):** magic-link login as
  `qa@codemyspec.local` per `.code_my_spec/qa/plan.md` ("Server (Postgres,
  `:dev`)" section) — fill `user[email]` at `/users/log-in`, read the token
  from `/dev/mailbox`, rewrite the origin to `127.0.0.1:4000` before
  following it.
  - **Shared mailbox risk:** other QA agents are running concurrently against
    this same dev server and `/dev/mailbox` is shared. The newest link there
    may belong to another agent's session. Re-request your own link
    immediately before use and confirm the landed account is
    `qa@codemyspec.local` before trusting anything downstream of it.

## Seeds

Nothing to run. The QA fixture already exists (verified live via `psql`,
not by re-running `qa_seeds.exs` against the live dev server — see
`.code_my_spec/qa/plan.md`'s "only with the dev server stopped" note):

```
psql -qtA code_my_spec_dev -c "select id, local_path from projects where id='11111111-1111-4111-8111-111111111111';"
psql -qtA code_my_spec_dev -c "select email from users where email='qa@codemyspec.local';"
```

Both returned rows. `local_path` is
`/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` —
the QA sandbox project the plan requires for surface-mutating QA. It already
has `credo` vendored under `deps/`, which is why this story picked it over a
scratch directory: a real `mix credo` subprocess can run there without a
fresh `mix deps.get`.

**Known pre-existing defect, not part of this story:** `lib/qa_sandbox/broken.ex`
has an intentional syntax error (missing `end`s) that fails `mix compile` for
the whole sandbox. `StaticAnalysis.Pipeline` skips every other analyzer while
compile is broken (`skipped_for_compile_errors?`), so as long as this file is
in place **no real analyzer can ever run in the sandbox** — a story-874 test
needs credo to actually complete a run, not just enqueue one. Move it aside
for the test window and restore it byte-for-byte before finishing (see
"Setup Notes"). File this as its own `scope: qa` issue — it is sandbox
infrastructure rot, not a finding about story 874.

**Config precondition:** credo is currently `block_changed` on the fixture
project (`psql -qtA code_my_spec_dev -c "select credo from project_configurations where project_id='11111111-1111-4111-8111-111111111111';"`).
`block_changed` demotes a finding to advisory unless `FileEdits` has this
session's `session_id` attributed to the file — which a curl-driven session
never will. Set credo to `block_all` via the Configuration page before
testing (`http://127.0.0.1:4000/projects/11111111-1111-4111-8111-111111111111/configuration`),
and set it back to `block_changed` afterward — this is shared config other
concurrent QA agents may depend on defaulting correctly.

## What To Test

All three criteria hinge on one control loop against a single file,
`lib/qa_sandbox/freshness_check.ex` (new — do not reuse `broken.ex`, its
compile error would mask everything downstream of it):

1. **Baseline — get a real, current credo finding on record.**
   - Write `lib/qa_sandbox/freshness_check.ex` with a genuine "nesting too
     deep" violation (real credo, not simulated).
   - `curl -sS -X POST http://127.0.0.1:4004/api/hooks/stop -H "Content-Type: application/json" -H "X-Working-Dir: .../qa_sandbox" -d '{"session_id":"qa-874-probe"}'`
     — enqueues analysis; expect a pending/allow response, not a block yet
     (nothing has run against the new file).
   - `curl -sS -X POST http://127.0.0.1:4004/api/analysis/wait -H "X-Working-Dir: .../qa_sandbox"` —
     blocks until the real `mix credo` subprocess finishes. qa_sandbox is 3-4
     files, so this should be seconds, not the 200-590s the plan quotes for
     the framework's own multi-thousand-file sweep.
   - Stop again → **expect a block** naming the finding, with **no "stale"
     marker** — maps to 8202's premise-check half ("the finding must
     actually block first, or the scenario proves nothing").

2. **Criterion 8202 — untouched code still blocks.**
   - Stop a third time with no edits in between → **expect the same block,
     still with no "stale" marker.** This is the converse case 8202 exists
     to catch: a freshness rule permissive enough to always excuse a
     finding would pass 8201 by never blocking anything, so this asserts
     the finding survives when nothing has changed at all.

3. **Criteria 8197 + 8201 — corrected code is labelled stale, not silently
   re-handed as fresh work.**
   - Edit `freshness_check.ex` for real — flatten the nesting — and do
     **not** call `/api/analysis/wait` this time (the whole point is credo
     has not re-run yet).
   - Stop again → **expect it still blocks** (8201: a finding from before
     the edit blocks until the rerun lands — dropping it here would let the
     *other* three sources go silent too, since every source fingerprints
     `:implementation`), **and** the response now carries `"stale"` **and**
     wording matching `/do not re-?fix/i` (8197: the agent must be told this
     list predates its own edit, not just be blocked again).
   - Bonus sanity check (not a separate criterion, but closes the loop):
     `analysis/wait` again, then stop once more → expect an **allow** (credo
     is clean on the flattened file) — confirms the whole cycle actually
     resolves rather than wedging.

Record the literal response bodies (block/allow, presence/absence of
`"stale"`, presence/absence of the "do not re-fix" phrasing) for each of the
five stops above — that sequence *is* the evidence for all three criteria.

## Result Path

No result.md. Findings go through `create_issue` as they're found; the run
closes with one `submit_qa_result` call per the workflow doc.

## Setup Notes

- Restoration order matters and is why this brief calls it out explicitly
  rather than leaving it implicit: (1) rename `broken.ex` aside before step 1
  and confirm `mix compile` is clean in the sandbox, (2) run every scenario
  above, (3) delete/revert `freshness_check.ex`, (4) restore `broken.ex` to
  its exact original content and path, (5) set credo back to
  `block_changed` on the Configuration page. Leaving the sandbox in a
  different state than found is itself worth filing if it can't be
  cleanly reverted.
- The stale/"do not re-fix" text lives in
  `lib/code_my_spec/problems/problem_renderer.ex` (`stale_marker/4`,
  `stale_footer/5`) and is assembled by `lib/code_my_spec/validation.ex`
  (`check_blocking_problems/4`); `lib/code_my_spec/hooks/stop.ex` is the
  controller-facing decision wrapper `StopController` actually calls. Useful
  for interpreting an unexpected response, not something QA should need to
  read code to pass.
