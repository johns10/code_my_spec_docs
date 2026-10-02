# Qa Story Brief

## Tool

script: `.code_my_spec/qa/scripts/qa_as_agent.sh` (MCP tool calls as a specific
role agent), plus `psql -d code_my_spec_dev` for direct DB verification and
`vibium` CLI (web) for the one browser-authenticated step (approving a tap-out
permission request).

This story's surface is almost entirely server-side agent/task MCP tools
(`start_task`, `evaluate_task`, `cancel_task`, `tap_out`, `set_agent_continuous`,
`start_agent`/`stop_agent`), not LiveView pages, so `qa_as_agent.sh` (which
drives real `tools/call` requests through the harness proxy on :4004 as a
named agent) is the primary instrument. The one page needed is
`/app/permissions/:id`, for approving an agent's tap-out request as the
project owner.

## Auth

- MCP-as-agent calls: `QA_WORKTREE=/Users/johndavenport/Documents/github/math_test_project .code_my_spec/qa/scripts/qa_as_agent.sh <agent-id> <tool> '<json>'`
  — `QA_WORKTREE` must point at `math_test_project`'s own checkout (it carries
  the harness id in `.cms_harness.json`); the default (this worktree) would
  scope calls to the wrong project.
- Browser (for permission approval only): `POST /users/log-in` with
  `user[email]=johns10@gmail.com` (the real account that owns
  `math_test_project`; the QA fixture user `qa@codemyspec.local` does **not**
  own this project's permission requests), then redeem the magic link from
  `/dev/mailbox` — the HTML body's link must have its origin rewritten from
  `dev.codemyspec.com` to `127.0.0.1:4000` before visiting.

## Seeds

    mix cms.seed priv/repo/qa_wake_seed.exs

Run immediately before any admission/continuous test — the seeded agent rows
are reaped `:running` -> `:stopped` within roughly a minute of any harness
health report, and `Work.request_turn_if_runnable/3` requires `status ==
:running`. Chain the reseed and the test call in the same shell invocation;
do not let a `psql`/browser detour sit between them.

Canonical agents on math_test_project (project `d7f466a1-591e-4f36-8319-42633f59411e`,
copy `56f5bf62-9cf8-400d-abcd-6c796afd3437`) as of this pass:

- product `e9dce99a-9512-457d-b613-3baa49c387a7`
- coding `59596b8a-1a5d-44b8-8f38-9bf1b570442d`, `5935042d-6c7e-44aa-b50b-9566b9e2f463`
- main `4e98e2a8-f674-4a10-9592-a1468e4b64ac`

## What To Test

- **1493 / active task blocks a second claim**: `start_task` an actionable
  project/story requirement as one agent, then `start_task` a *different*
  distinct requirement (any valid graph node — `start_task` resolves by
  name+type+id, not by eligibility) as the same agent. Expect a refusal
  naming the existing active task id, not an eligibility complaint. The tool
  schema carries no `force` field, so there is no override to attempt.
- **2869 / cancel frees the requirement**: `cancel_task` an active attempt,
  confirm `get_next_requirement`/`list_requirements` still show it
  unsatisfied with no new task auto-created, then `start_task` it again as a
  fresh, independent claim.
- **1495 / failed manual evaluation**: `evaluate_task` a manual-validation
  task (e.g. `personas_complete`) before its artifacts exist. Expect
  `{needs work}` feedback and the *same* task id still `[active]` in
  `list_tasks`.
- **1494 / passing evaluation**: do the real minimum work, `evaluate_task`
  again. Expect `Passed`, task `[completed]`, and response text pointing at
  `get_next_requirement`/`start_task` for continuation.
- **1499 / approved null-task tap-out**: `tap_out` with no `task_id` as an
  agent. Approve via `/app/permissions/:id` as the project owner. Confirm via
  `psql` that `continuous` flips to `false` and the agent row + task history
  are otherwise untouched.
- **1497 / 3106 / 3108 / 3109 — admission mechanics**: `set_agent_continuous`
  off then on, immediately after a reseed. With zero role-scoped eligible
  work, `read_agent_conversation` stays empty (no message, no turn). With
  eligible work, a generic "Eligible work is available ... start_task" prompt
  lands immediately (before any real engine dispatch), never naming a
  specific requirement. Compare a role with a nonempty queue (main, with
  `technical_strategy` actionable) against one with an empty queue (coding)
  to confirm role-scoping. Toggling never creates or deletes an agent row.
- **1490 / 1498 / 1500 / 1501 / 1502 / 3104 / 3105 — turn-boundary MENU
  content**: see Setup Notes. Not reachable through the wake-fixture rows;
  needs a real backing engine process's completed turn.

## Result Path

Findings are filed live via `create_issue` (see issue id below); this
document plus `.code_my_spec/qa/796/screenshots/` are supporting evidence,
not the record of outcome.

## Setup Notes

**Why the wake-fixture DB rows cannot show stop-hook/turn-boundary MENU
content live.** `Agents.Work.request_turn_if_runnable/3` records a generic
"eligible work" prompt into the agent's conversation *before* dispatching to
the harness (`Conversations.record_sent_to_agent/2` runs synchronously ahead
of `Transport.impl().request_work_turn/5`), which is enough to prove
admission/eligibility gating live. But the rendered `Validation.Menu`
content that criteria 1490/1498/1500/1501/1502/3104/3105 care about is only
produced by `CodeMySpec.Agents.StopDecision.deliver/3`, which fires from a
*real* `turn_ended` event reported by the harness over
`harness_project_channel.ex` — i.e. a genuinely completed turn from a real
backing engine process (`CmsHarness.Agents.Engine.Impl`, a real Alloy/Claude
session).

The seed script's agent rows are exactly that — rows. `web.log` shows the
harness's own periodic reconciliation repeatedly finding
`"main agent ... is not running ... its row said running"` for these rows,
and `Agents.settle_against/3`'s false-branch (confirmed by reading
`lib/code_my_spec/agents.ex:1993-2000`) just reaps the row to `:stopped` via
`record_stopped/2` — it does **not** call `account_for_interrupted_turns/2`
(the only function that renders `Menu.render/4` on a reconciliation path),
so nothing is ever delivered to these rows passively.

I confirmed this empirically rather than only from source: `start_agent`
(role: coding) mints a genuinely backed process; even so, with zero
role-eligible work it took no turn at all (`read_agent_conversation` stayed
empty after `set_agent_continuous(continuous: true)`), which is itself
1497's expected behavior and is a *stronger* result than the DB-only rows.
Getting a real engine to reach an actual STOP boundary needs real,
eligible, completable work (e.g. `technical_strategy`, main-role,
automatic validation) run to natural completion by a live Claude turn — a
multi-minute, real-token, non-deterministic operation per criterion, times
up to 7 remaining criteria (1498 alone needs 5 identical real evaluation
failures before its stop decision). That is what the spex harness's
`CmsHarnessTest.Machine` / `HeldProvider` fixtures exist to simulate
deterministically and cheaply; a black-box QA session reproducing it live
would mean running a real autonomous coding/main agent against
`math_test_project` for an extended, unbounded session, which is out of
proportion to one QA pass. Recorded as spex-only with this reasoning rather
than silently skipped.

**Fixture state left behind for the next pass**, so repros aren't reused
unknowingly:

- `personas_complete` (project-level, singleton) is now permanently
  satisfied — persona "Coding Role Agent" (`coding-role-agent`) exists with
  real `summary.md`/`sources.md` under
  `.code_my_spec/personas/coding-role-agent/` in the `math_test_project`
  checkout. A future pass wanting to re-test 1495's "missing artifacts"
  scenario on `personas_complete` will need a different requirement or a
  fresh persona-less project.
- Two probe stories (1045 "QA796 second lane", 1046 "QA796 lane B") were
  created to test claim/refusal mechanics and **deleted** afterward
  (`delete_story`) per the plan's "delete probe stories afterward" rule.
- Coding agent `25d67c11-f590-4e8e-a00d-6d3fb6bf08eb` is left
  `continuous: false` permanently — it is the approved-tap-out evidence for
  1499 and a legitimate historical artifact, not cleaned up (paralleling the
  pre-existing cancelled `personas_complete` task rows already left by prior
  passes).
- A third coding-role row, `19d79e35-409a-4b68-8cef-14e4bca6b519`, was
  minted via `start_agent` to get a *genuinely backed* process for the 1497
  test and then `stop_agent`'d. It now persists as a 3rd coding-role row
  (the wake seed's "refresh" logic picked it up as one of the "continuous
  coding" agents on the next reseed rather than treating it as extra). Two
  further duplicate rows (`27417912-...` main, `29232a00-...` product,
  `continuous: false`, `status: stopped`) predate this pass.
- Filed issue `fe059aa3-7eeb-4f94-8dd0-c156156e7d43` (medium): `set_agent_continuous`'s
  response text is identical regardless of whether a turn was actually
  admitted, contradicting its own moduledoc's promise to report whether "the
  bell reached something."
