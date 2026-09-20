# Qa Story Brief

Story 1005 — Work appearing on the graph reaches the agent who can do it.
Component under test: `CodeMySpec.Agents` (`lib/code_my_spec/agents/work.ex` is
the actual admission logic; `agents.ex` wraps it; `graph_watcher.ex` is the
trigger; `stop_decision.ex` is the turn-boundary reconsideration path).

## Tool

script (MCP code-mode, via `run_script`/`qa_as_agent.sh`) + curl (`/dev/state`,
`/dev/faults`) + direct psql reads against `code_my_spec_dev`.

No browser work: the vibium MCP server failed to connect this session
("Connection closed" / cached retry). This story's surface is agent-to-agent
admission, not a LiveView, so the loss did not block execution — noted here
per the harness prompt's instruction to say so rather than go quiet.

## Auth

No login needed. All calls go through the local harness proxy on `:4004`,
carrying `X-Harness-Id` for the target checkout and `X-Agent-Id` to act as one
of the fixture's durable agents:

    QA_WORKTREE=/Users/johndavenport/Documents/github/math_test_project \
      .code_my_spec/qa/scripts/qa_as_agent.sh <agent-id> <tool> '<json-args>'

`QA_WORKTREE` overrides the script's default (this worktree) to route at
math_test_project's own `.cms_harness.json` — its harness id is
`56f5bf62-9cf8-400d-abcd-6c796afd3437`, same as its working-copy id. Its
harness proxies through this box's single shared `cms harness` daemon on
:4004, confirmed connected/onboarded/watching via `curl -s
localhost:4004/health | grep math_test_project`.

Direct DB reads use `psql -d code_my_spec_dev` (dev Postgres, this box).

Dev-only diagnostic routes on the main app (port 4000, no auth needed,
`:dev_routes`):

    GET  /dev/state?project_id=<id>      — graph watcher status, executor liveness
    GET  /dev/faults                     — what's injected
    POST /dev/faults {"key":..,"fault":..}   — inject (used: graph_recompute_fails)
    DELETE /dev/faults {"key":..,"fault":..} — clear

## Seeds

    mix cms.seed priv/repo/qa_wake_seed.exs

Project `d7f466a1-591e-4f36-8319-42633f59411e` ("Math Test Project"), working
copy `56f5bf62-9cf8-400d-abcd-6c796afd3437`, four canonical continuous agents:

| role    | id                                     |
|---------|----------------------------------------|
| coding  | `25d67c11-f590-4e8e-a00d-6d3fb6bf08eb` |
| coding  | `59596b8a-1a5d-44b8-8f38-9bf1b570442d` |
| product | `e9dce99a-9512-457d-b613-3baa49c387a7` |
| main    | `4e98e2a8-f674-4a10-9592-a1468e4b64ac` |

**Critical, and not obvious from the seed's own output**: `record_running_on_copy/3`
reaps any row on this copy claiming `:running` with no live engine behind it —
and it does so within **seconds**, not "about a minute" as the plan's prose
suggests. Measured this session: agents flip back to `:stopped` before a cold
`mix cms.seed` re-invocation can even finish booting. The only way to get a
usable window is to flip the four rows to `running` (and clear
`turn_started_at`/`work_request_id`) with a **direct `UPDATE`** against the
live `code_my_spec_dev` DB immediately before firing a trigger, in the same
shell chain, with no gap:

    psql -d code_my_spec_dev -c "update agents set status='running', turn_started_at=NULL, work_request_id=NULL, work_requested_at=NULL where project_id='d7f466a1-591e-4f36-8319-42633f59411e' and continuous=true;"

Do this immediately before every trigger, not once at the start of the
session. This is a known, tracked race (issue `726766b0`), not something to
re-file.

**Baseline eligibility, at fixture-steady-state**: `get_next_requirement` as
each of the four agents shows `coding` and `main` have **zero** actionable
work; `product` has exactly one — `personas_complete` (project-level). This
asymmetry is what makes the role-scoping tests clean: any trigger that offers
a turn to `product` but not `coding`/`main` is real per-role delegation, not
coincidence.

**Triggering a real graph observation.** `write_project_file` does *not*
announce to `GraphInputs` (confirmed: `last_recompute` did not move after a
file write through it) — it's a raw devops-artifact write, not a
component-sync trigger. Use `create_story` instead (`stories.ex` announces on
create); a `ready_for_dev: false` throwaway story is enough to fire a real
`GraphInputs` event and a real watcher pass without adding anything
actionable of its own. **Delete every throwaway story you create** — this
fixture is shared across every story's QA pass, and stories with no cleanup
create the same kind of test cruft the sandbox-isolation rule exists to
prevent, only harder to notice because the project itself is disposable.

Wait ~3s after the trigger for the 2s debounce before reading results.

## What To Test

All scenarios below were driven against the live app (dev server on :4000 +
the shared harness on :4004), reading outcomes from `agents` rows,
`conversation_messages`, and `/dev/state` — not from `mix spex`.

- **3554 (no staffing/starting)** — `select count(*) from agents where
  project_id=...` before and after every trigger in this session (6 triggers
  total). **Result: 5 throughout, no change.** A graph change never created or
  started a new agent process.

- **3555 (no eligible work → no turn) / 3569 (successful recompute delegates
  per-agent eligibility) / 3552 (role scoping)** — flip all 4 agents running,
  create a throwaway story, wait, read `/dev/state` (`last_recompute` should
  advance) and `conversation_messages` counts per role. **Result:**
  `last_recompute` advanced from `06:41:35Z` to `07:10:00Z`; `product`
  (eligible: `personas_complete`) got exactly one new message; `coding` (0
  actionable) and `main` (0 actionable) got none. Repeated a second time
  (`07:10:57Z`) with the same split. Role-scoping is real and per-agent, live.

- **3553/3567 (eligible work requests one unassigned turn, no requirement
  preselected)** — read the new message's exact content via psql. **Result:**
  `"Eligible work is available. Use list_requirements or get_next_requirement
  to inspect it, then choose work with start_task. No task has been selected
  or assigned for you."` — verbatim `Work.@prompt`, no story/requirement name
  embedded. Exactly one such message per successful admission.

- **3570 (previously observed eligible work can still request a later
  turn)** — fired three independent triggers across the session; `product`
  (whose `personas_complete` item stays open the whole time, since nothing
  claims it) got a fresh offer on **every** one (126 → 127 → 129 messages).
  Not deduped, not suppressed.

- **3557 (failed recompute makes no turn request) + recovery** —
  `POST /dev/faults {"key":"<project_id>","fault":"graph_recompute_fails"}`,
  flip agents running, fire a trigger. **Result:** `last_recompute` did **not**
  advance, `recompute_pending` flipped to `true`, and `product`'s message
  count stayed flat (127 → 127) — no turn requested from the failed pass.
  Cleared the fault, re-flipped agents, and the very next pass applied the
  still-queued observation: `last_recompute` advanced and `product` got its
  offer (127 → 128) — the pending observation wasn't lost, just deferred.

- **3568 (busy agents reject graph signals without queueing messages)** —
  simulated a mid-turn agent by setting `product.turn_started_at = now()`
  directly (no live provider to hold a real turn open — see Setup Notes), then
  fired a trigger. **Result:** recompute happened (`last_recompute` advanced),
  but `product`'s message count did not move (128 → 128) and
  `work_request_id` was never touched. No message of any delivery state
  (checked `conversation_messages.delivery` — all pre-existing rows, none
  new) was queued for it while busy. Confirms `runnable_state?`'s guard order:
  a busy agent never reaches `reserve/2` or `record_sent_to_agent/2` at all.

- **3556 (mid-turn work waits for the turn boundary, reconsidered after)** —
  continuation of the above: cleared `turn_started_at` back to `nil`
  (simulating the turn ending) and fired one more trigger. **Result:**
  `product` got its offer again immediately (128 → 129). The observable half
  of this criterion — ineligible-while-busy, eligible-again-once-idle — is
  live-verified. The "does not interrupt an in-flight turn" half has no
  in-flight turn to interrupt without a live engine/held provider; that half
  stays spex-covered (3556's own spex file uses `HeldProvider.hold()` for
  exactly this reason).

- **3554 revisited across all of the above** — no agent row count ever
  changed across 6 trigger events, including the fault-injection and
  busy-agent scenarios.

### Not independently exercised live — spex-only, with reasons

- **3558/3572 (racing graph + turn-end events admit only one turn)** — the
  guard is a `SELECT ... FOR UPDATE` + conditional stamp inside
  `Agents.Work.reserve/2` (`lib/code_my_spec/agents/work.ex:86-114`). Proving
  the race needs two events landing while a reservation is genuinely in
  flight, which needs a held request (the spex use
  `CmsHarnessTest.HeldProvider.hold/0`). Nothing on this box holds a real
  model request open. Verified by code reading, not exercised live.

- **3559/3571 (losing a claim race creates no retry churn)** — the *release*
  half of this is what actually happened, repeatedly and live: every
  admission attempt this session ended with `work_request_id` back to `nil`
  within the 3s check window, because `Transport.impl().request_work_turn`
  fails immediately (this copy's executor reports zero live engine
  processes — `/dev/state`'s `working_copies[].agents` is `[]` for every
  copy, confirmed) and `Work.release/3` clears the stamp on that failure path.
  Zero stuck reservations across 6 attempts is real evidence the release path
  works, but it is not the criterion's actual scenario — that's specifically
  about a `get_next_requirement`/`start_task` claim losing a race to another
  claimant on work that then vanishes, which needs a second live claimant.
  Not reproduced; noted as the documented, already-known limitation (an agent
  with no live harness process fails every dispatch and releases immediately
  — that is the release mechanism working, not the race this criterion is
  about).

- **3552's cross-working-copy half** ("only its assigned coding agent", where
  a *second* checkout's coding agent must not be notified) — this fixture has
  one connected, onboarded checkout. Confirming cross-copy isolation would
  need standing up a second onboarded harness, which is out of scope for a QA
  pass (provisioning infrastructure, not testing it). The `WHERE
  working_copy_id = ...` scoping in `Work.consider_project/2` and
  `graph_work?/2` is read from source; the copy-scoping half of 3552 stays
  spex-covered (the spex's own `second` checkout scenario exercises exactly
  this).

- **3560/3573 (product triage doesn't suppress/still allows coding work)** —
  this fixture's `coding` role currently has zero actionable items (nothing
  is `three_amigos_complete` + `component_linked` + `bdd_specs_exist`), and
  getting real coding-actionable work onto this copy means progressing the
  fixture's pipeline for real (a full Three Amigos session + component link),
  which is a permanent, one-way mutation of a fixture shared across every
  story's QA pass — too expensive and too risky to do inside this pass.
  `Work.graph_work?/2` computes `Requirements.actionable_for_role(scope,
  agent.role)` per role from disjoint queries, so a product-role item
  structurally cannot appear in a coding-role agent's actionable set — read
  from source, not exercised live.

## Result Path

No `result.md` — findings went through `create_issue`, and the run closed
with one `submit_qa_result` call naming the task id above.

## Setup Notes

- The "busy agent" and "turn boundary" scenarios simulate `turn_started_at`
  via a direct `UPDATE` rather than a real turn, because nothing on this box
  holds a live model request open (no `HeldProvider`-equivalent outside
  spex). This tests the exact guard clause in `Work.runnable_state?/1`
  (`is_nil(agent.turn_started_at)`), which is the thing both criteria are
  actually about, but readers should know the "turn" itself was not real —
  no engine was ever mid-response.
- Every throwaway story created during this pass (`QA-1005 throwaway probe`,
  `probe 2`, `fault-injected probe`, `busy-agent probe`, `post-turn
  reconsider probe` — ids 1040–1044) was deleted before the pass ended. A
  harmless append-then-revert touch to `math_test_project/.formatter.exs`
  (which turned out not to fire a `GraphInputs` observation at all — see
  above) was also reverted.
- `graph_recompute_fails` was injected and cleared for
  `d7f466a1-591e-4f36-8319-42633f59411e` only; confirmed cleared via `GET
  /dev/faults` (`"injected":[]`) at the end of the pass.
