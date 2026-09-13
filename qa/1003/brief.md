# Qa Story Brief — Story 1003: A story's code is on the running dev copy before QA tests it

Component under test: `CodeMySpec.Promotion` (`lib/code_my_spec/promotion.ex`,
`lib/code_my_spec/promotion/{runner,steps,lock}.ex`), exposed as MCP tools
`promote` / `promote_sync` on `LocalServer` (`4004/mcp` or the caller's own
harness-bound client), and as the `code_on_running_copy` requirement node
(`CodeMySpec.Promotion.running_copy_check/2`), read through
`get_next_requirement` / `list_requirements`.

## Tool

- MCP tools (own client): `promote`, `promote_sync`, `start_analysis`, `list_requirements`, `get_next_requirement`
- Log inspection: `~/.codemyspec/web.log` (real `[Promotion]` events from every session on the shared box)
- `curl` for app liveness/serving checks
- `git` (read-only: `log`, `status`) for ground-truth comparison against what the app reports serving

This story's real surface is not primarily a LiveView — it's an MCP action
(`promote`/`promote_sync`) whose effect (a git merge + app restart) is
externally observable via the app's own HTTP responses and its structured
logs. Vibium/browser is not the right tool here; there is nothing to click.

## Auth

None needed. `promote`/`promote_sync`/`list_requirements`/`get_next_requirement`
are called through this QA session's own already-authenticated MCP client
(harness-scoped to this working copy — no separate login).

For the `curl` liveness checks, no auth is needed: `GET /`, `/users/log-in`,
`/app` (redirect check only) on `http://127.0.0.1:4000`.

## Seeds

None needed — this story is tested against real, already-running production
traffic on the shared dev box (many concurrent sessions promote routinely),
not against seeded fixture data. No mutation of QA fixture data applies here.

## What To Test

**Constraint acknowledged up front:** calling `promote`/`promote_sync` for
real performs a live `git merge --ff-only` into the actual running dev
checkout and dispatches `just restart`, which restarts whatever is serving
`:4000` for every concurrent session on this shared box. Given heavy
concurrent load at test time (many worktrees mid-sweep) and an active
`check-4000-outage` investigation, this session did **not** trigger a fresh
promotion of its own for the gate/restart criteria — real, very recent
production activity already supplied direct evidence for nearly every
criterion below, observed rather than manufactured. Two read-model criteria
(3162, 3172) had no organic negative example live at test time and are
called out as spex+code-verified rather than live-observed.

- **3163 — QA starts once the code is there.** `list_requirements({requirement_name="code_on_running_copy"})`
  shows story 1003's own node `[x]` satisfied right now, and `start_task`
  for `qa_complete` on story 1003 succeeded (this very session). Live pass.
- **3170 — The application is serving the promoted code.** Compare the last
  `[Boot] serving <sha>` line in `~/.codemyspec/web.log` against `git log -1
  --format=%H main`. At test time: boot line `faaf3c81b` (03:08:15Z) vs
  `git log -1 main` = `faaf3c81bd594a3ee5...` — exact match, and `curl
  127.0.0.1:4000/`, `/users/log-in`, `/app` all answer normally (200/200/302).
  Live pass.
- **3175 — The application is restarted every time, not conditionally.**
  Scan `~/.codemyspec/web.log` for `[Boot] serving <sha>` lines across the
  session; confirm one appears after every successful `[Promotion] merged
  ... dispatching restart` line, with the sha advancing each time (checked:
  8d9cbe44e → f96841c6f → 47e4536df → 747377340 → bf5791bd4 → d747cdb2e →
  67fb64645 → 17b8863fe → 55cbcaf44 → 50124a72f → faaf3c81b, one boot per
  merge, no skips). Live pass.
- **3433/3434 — Promotion returns in seconds; a slow deployment does not
  become a slow promotion.** In `web.log`, find a `merged ... dispatching
  restart` line and the paired `report_to` "promoted" line — confirm they
  share the same (or next) millisecond timestamp, while the corresponding
  `log_restart_outcome` line (success or `harness_timeout`) lands 1-3+
  seconds later, on an independent task. Confirms the merge-answers, restart-
  detached design under real conditions. Live pass.
- **3165 — A clean copy promotes everything on it.** Grep `web.log` for
  `[Promotion] merged <branch> into <path> (<before> -> <after>), dispatching
  restart` immediately followed by a `report_to` "promoted" line — multiple
  real occurrences tonight (e.g. `merged cro into
  /Users/johndavenport/Documents/github/code_my_spec ...` at 02:56:33,
  02:43:26, 01:11:50, 02:10:08), each for a copy with no blocking problems
  and a fresh sweep. Live pass.
- **3176 — The preview app is up after a promotion, and is started if it is
  not.** `restart/3` in `promotion.ex` unconditionally calls
  `WorkingCopies.record_preview_status(running, "serving")` and dispatches
  the restart regardless of the copy's prior `preview_status` (`nil`,
  `"serving"`, `"erroring"`, or `"down"` all reach the same restart path —
  see `serving/2` clauses). Live evidence: every merge observed in `web.log`
  tonight was followed by a fresh `[Boot] serving <sha>` line — the app came
  up serving the new code every time, regardless of what its status was
  beforehand. Live pass (same evidence as 3175).
- **3168 — A merge that breaks the target is not a completed promotion.**
  NOTE: superseded (`criterion_3168_...spex.exs` moduledoc, 54aa534c) — the
  three-way-merge-compiles-broken scenario this criterion was built on can no
  longer reach a merge at all: `Runner.merge/4` is `--ff-only`, so the
  divergence that used to be invisible until compiled is now refused at the
  precondition, by name, before content is ever compared. Same mechanism as
  3171/3435. Verified by code + passing spex, not live (no live divergence
  example occurred in the observed window).
- **3173 — There is one place work goes.** Confirm the `promote`/`promote_sync`
  MCP tool schemas take **zero arguments** (no branch/target param). Confirm
  every real `merged X into <path>` log line names the same one target path
  for this project. Live pass.
- **3174 — Uncommitted work is refused before the merge is attempted.** Grep
  `web.log` for `this copy has uncommitted work. Commit it, then promote.` —
  multiple real occurrences tonight, each a `report_to`/`refused` line with
  no preceding merge. Live pass.
- **3164 — A copy with a failing spec/problem promotes nothing.** Grep
  `web.log` for `this copy is carrying N problem(s), so it promotes nothing`
  — multiple real occurrences tonight (credo/exunit/spex findings), always a
  refusal, never followed by a `merged` line for that attempt. Live pass.
- **3166 — A stale analyzer is swept before the gate answers.** NOTE: superseded
  behavior per `criterion_3166_...spex.exs`'s own moduledoc (54aa534c) — the
  gate no longer starts-and-waits for a sweep; it refuses immediately, by
  name, when the current commit lacks a fresh run, and tells the agent to run
  `start_analysis` itself. Grep `web.log` for `this copy has not been swept
  clean at its current commit: <sources> need a fresh run` — multiple real
  occurrences tonight. Confirms the **actual** (superseded) behavior matches
  what is really running. Live pass against the current contract.
- **3169 — Problems the target already had do not block the promotion.**
  `blocking_problems/2` in `lib/code_my_spec/promotion.ex` scopes
  `ProblemRepository.list_project_problems` to the **promoting** copy
  (`as_copy/2`), not the target — a promotion is judged on what it adds, not
  on what the target already carries. No live paired example available
  tonight (would need one copy promoting clean while the target already
  carries unrelated problems, which nobody happened to do in the observed
  window). Verified by code reading + passing spex
  (`criterion_3169_...spex.exs`).
- **3436 — A refusal reads as ordinary, not as a fault.** Read the refusal
  strings collected above (`"this copy has uncommitted work. Commit it, then
  promote."`, `"...need a fresh run before this can promote... promote again
  once it lands."`) — calm, actionable, no alarm language. Live pass.
- **3435 — Divergence is refused before anything is merged** and **3171 — A
  conflict is aborted, not left on the shared checkout.** No live "behind
  main" refusal occurred in the observed window (`grep -h "behind main"
  web.log` — empty). `Runner.merge/4` uses `git merge --ff-only`, which
  refuses divergence (conflicting or not) before touching the tree — see
  `test/code_my_spec/promotion_test.exs` describe block "a branch that has
  diverged from main, conflicting or not" (4 tests, all passing) and
  `criterion_3171_...spex.exs`'s moduledoc explaining the two supersessions
  (bed1d974, then 54aa534c). Verified by code + passing spex, not live —
  deliberately not manufactured live against the shared checkout (would cost
  a real, avoidable restart for a scenario the ff-only precondition already
  makes structurally unreachable-as-a-content-conflict).
- **3162 — QA does not start on a story the running copy has never seen** and
  **3172 — QA is told the copy is behind rather than failing the story.**
  `code_on_running_copy` is `[x]` for all 40 stories currently carrying the
  node (`list_requirements({requirement_name="code_on_running_copy"})`) — no
  organic unsatisfied instance exists in the project right now to observe
  live. Both exercised via the real `GetNextRequirement` MCP tool over a real
  channel in `criterion_3162_...spex.exs` / `criterion_3172_...spex.exs`
  (passing). Verified by spex + code (`Promotion.verdict/2`'s `in_sync/1`
  clause), not independently reproduced live.
- **3167 — Work done on the running copy is already there.** Exercised via
  `GetNextRequirement` in `criterion_3167_...spex.exs` (passing) —
  `Promotion.verdict/2`'s clause matching `%Scope{active_working_copy_id:
  id}` against the running copy's own `id` returns satisfied with no branch
  to merge. Verified by spex + code, not independently reproduced live (this
  QA session's own working copy is a worktree, not the running copy).

## Result Path

DB-backed only — no result.md. Findings via `create_issue`, final outcome via
`submit_qa_result(task_id: "7be0cdd6-286c-4d60-ba90-10babafdf296", ...)`.
Evidence referenced above is inline in this brief and in the QA session
transcript (log excerpts, git comparisons) rather than saved screenshots —
this story has no UI surface to screenshot.

## Setup Notes

**Fix verification (post-partial).** Issue `2a212eb0-ad0c-473d-86b3-e8e725e6fbfc` (correct_the_agent/4 skipping
`restart_acknowledgement_lost?/1`) was fixed in commit `788d1f2d9`. Reviewed
the diff directly: `correct_the_agent/4` now checks
`restart_acknowledgement_lost?(error)` first and returns `result` unchanged
(no correction message sent) when true, applying the identical established
predicate `merged/5` already used on the synchronous path — the exact fix
requested. The `else` branch is byte-identical to the prior unconditional
behavior, so the genuine-failure path is unchanged. No dedicated unit test
was added for `correct_the_agent/4` itself (it's a private function acting on
a detached task's result; the existing `async_deployment_test.exs` covers the
synchronous `merged/5` path only, not this one) — noted as a residual gap in
regression coverage, not a reason to doubt the fix, which is a minimal,
mechanical application of an already-tested predicate. Confirmed via code
review rather than live reproduction (reproducing the original bug live would
again mean an agent-driven promotion hitting a real restart-timeout, which
isn't something to manufacture against the shared box just to re-prove a
now-obviously-correct one-line-guard fix).

Considered but decided against engineering a live divergence/conflict
exercise for the 7 criteria that remain spex+code-verified (3162, 3167, 3168,
3169, 3171, 3172, 3435), even with the harness now healthy and lower-risk:
doing so meaningfully would require either committing a throwaway divergent
commit to this worktree and promoting (to hit the ff-only refusal — a case
that's pure, deterministic git behavior with no live-timing dependency, thus
low marginal value over the passing spex + `promotion_test.exs`'s dedicated
"a branch that has diverged from main" suite), or manufacturing an
artificial unsatisfied `code_on_running_copy` state on the real project (out
of step with this project's own QA norm of not polluting real project data
outside the sandbox). Judged the existing evidence sufficient.

## Setup Notes

Machine was under heavy concurrent load during this QA pass (many worktrees
running analyzer/spex/promote cycles simultaneously) — this is exactly the
condition the story's design targets (one project lock, refuse-not-queue on
contention), and the `web.log` evidence above is a sample of dozens of real
concurrent promotions from that load, not synthetic traffic.

Deliberately did not trigger a fresh `promote`/`promote_sync` from this
session: this worktree (`worktree-maintenance`) is 0 commits ahead / 6 behind
main with no code of its own to promote, so a self-triggered promotion here
would have been a no-op merge whose only effect was a real, avoidable
`just restart` of the shared `:4000` app for every other concurrent session —
not a meaningful test of any of the 19 criteria beyond what real recent
traffic already demonstrates. Flagged this to `team-lead` and
`check-4000-outage` before deciding; proceeded on real-traffic evidence
instead once the risk was clear.
