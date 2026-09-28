# QA Brief — Story 1004: Idle agents are left alone

**Revision note:** criteria were rewritten 2026-09-19/20. This brief targets
the current wording only (turn eligibility for an already-staffed durable
agent). Startup (Story 1038) and continuous-mode policy / task blocking
(Story 538) are out of scope by the story's own note. The prior brief in this
directory (dated 2026-09-17) used obsolete "wake/nudge" vocabulary and
criterion numbers (3178-3196) tied to a Spex suite that no longer exists —
disregard it except for the fixture provisioning details, which still apply.

## Tool

`run_script`/MCP (code-mode, JSON-RPC over `http://localhost:4004/mcp`) against
the QA wake-fixture project's own harness, plus read-only `psql -d
code_my_spec_dev` for corroboration. `CodeMySpec.Agents`/`CodeMySpec.Agents.Work`
is a server-side context with no LiveView/browser surface — the observable
behavior is entirely (a) messages pushed into an agent's conversation and (b)
the `agents` row's own `status`/`work_request_id`/`turn_started_at` columns.
There is nothing to click. Do not run `mix spex`/`mix compile` alongside the
live dev server; `mix cms.seed <script>` is DB-only and safe to run alongside it.

## Auth

- `/mcp` (port 4004, light harness proxy) — `X-Harness-Id` header naming the
  **fixture project's own harness id** (see Seeds), never this worktree's own
  `.cms_harness.json` id. Handshake: `initialize` → `notifications/initialized`
  → `tools/call`, echoing the returned `Mcp-Session-Id` header on every
  subsequent call. `Accept: application/json, text/event-stream` is required.
- Only tools that take an explicit `agent_id`/`agent_ids` **argument** (e.g.
  `list_requirements`, `list_agents`) are reachable this way without
  impersonation. Tools that read the *caller's own* identity implicitly
  (`get_next_requirement`, `start_task`, `list_tasks` with no `agent_id`,
  `read_agent_conversation`) need an `X-Agent-Id` header naming one of the
  fixture's agents — **this session's auto-mode permission classifier denied
  that header as "Modify Shared Resources"** on every attempt, including a
  plain read (`get_next_requirement`). See Setup Notes; budget time to get
  this unblocked (or use direct DB reads as the fallback below) before relying
  on it.
- `psql -d code_my_spec_dev` — read-only `select`/`\d` worked repeatedly, then
  began being denied by the same classifier partway through this session with
  no code change on my end. Treat DB read access as unreliable moment-to-moment
  rather than assume a denial means the data doesn't exist.

## Seeds

`mix cms.seed priv/repo/qa_wake_seed.exs` — idempotent, DB-only, safe beside a
live server. Provisions one project/copy with 4 agent rows:

```
Project:      d7f466a1-591e-4f36-8319-42633f59411e  (Math Test Project)
Working copy: 56f5bf62-9cf8-400d-abcd-6c796afd3437  (root: /Users/johndavenport/Documents/github/math_test_project)
Harness id:   56f5bf62-9cf8-400d-abcd-6c796afd3437  (same value; from math_test_project/.cms_harness.json)
Agents:
  product  e9dce99a-9512-457d-b613-3baa49c387a7   continuous=true
  coding   25d67c11-f590-4e8e-a00d-6d3fb6bf08eb   continuous=true
  coding   59596b8a-1a5d-44b8-8f38-9bf1b570442d   continuous=true
  main     4e98e2a8-f674-4a10-9592-a1468e4b64ac   continuous=true
```

**Load-bearing gap, confirmed this pass:** the seed's `find_or_create`-style
idempotency only sets `status: :running` on the *create* branch. On a project
seeded by an earlier QA pass (the ordinary case — this project has existed
since at least 2026-09-11), every agent row reads `status: "stopped"`
(confirmed via `psql` immediately after re-running the seed today). `Work.
request_turn_if_runnable/3`'s `runnable_state?/1` gates on `status == :running`
before it ever asks whether work is eligible, so **every admission scenario in
this story is untestable through this fixture until something sets these rows
back to `:running`.**

Two ways to do that, both with real cost/authorization implications a tester
should not incur unilaterally:

1. A direct DB write (`update agents set status='running' where id in (...)`).
   Scoped to only-ever-synthetic QA-owned rows, but this session's permission
   classifier refused it outright as "Modify Shared Resources" — ask the
   operator to run it, or to grant it, rather than finding a workaround.
2. `restart_agent`/`start_agent` against this project's harness, which is
   **genuinely connected** (confirmed: `curl -s localhost:4004/health | grep
   math_test_project` → `connected: true, onboarded: true, watching: true`).
   Unlike (1), this does not merely flip a column — it asks a real `cms
   harness` process to spawn a real coding-agent subprocess against
   `/Users/johndavenport/Documents/github/math_test_project` on the account's
   connected provider, which can make a real, billed model call. Do not do
   this without the operator's explicit go-ahead; it is exactly the kind of
   outward-facing, hard-to-reverse action a QA pass should not trigger on its
   own judgment.

Get one of the two authorized **immediately before** testing, then confirm
with `psql -d code_my_spec_dev -c "select id, role, status, continuous,
turn_started_at, work_request_id from agents where project_id =
'd7f466a1-591e-4f36-8319-42633f59411e';"` — all four rows must read `running`
with the other three columns null, or a result gathered against them proves
nothing. Re-check right before the transition being tested, not just once at
the top of the session: `record_running_on_copy/3` reaps any row that claims
to be running with no real harness-reported process behind it (see
`.code_my_spec/qa/plan.md`, "The agent sandbox"), so a `running` row can go
stale mid-session on this same connected-harness fixture.

No qa-role agent exists on this fixture, deliberately (so QA-role graph work
stays outstanding without a QA agent to claim it and remove the premise).
Both coding agents share one working copy, deliberately (role isolation needs
two agents differing only by role). A second working copy for a true
cross-copy comparison is not provisioned — out of proportion for this pass;
falls back to source/spex review.

## What To Test

Cross-reference `.code_my_spec/spec/code_my_spec/agents.spec.md`,
`lib/code_my_spec/agents/work.ex`, and the 12 spex under
`test/spex/1047_idle_agents_are_left_alone/`. Map to the 6 published ACs:

1. **No eligible work → no turn request.** Once a fixture agent's row reads
   `running`: capture `select id, work_request_id, work_requested_at,
   turn_started_at from agents where id = '<coding-agent-id>'` and the tail of
   that agent's `conversation_messages` (join through `conversations.agent_id`)
   as a *before* snapshot. Call `set_agent_continuous({agent_id=...,
   continuous=true})` via `run_script` against the fixture harness (this is
   the same "ring the bell" path `Work.request_turn_if_runnable/3` runs on
   every continuous-enable). Re-snapshot both. For a role/copy pair with **no**
   actionable graph work (check via `list_requirements({summary=true,
   status="unsatisfied"})` cross-referenced against
   `Requirements.actionable_for_role/2`'s prerequisites — the raw unsatisfied
   count is not the actionable frontier, see the tool's own doc), the row's
   `work_request_id`/`turn_started_at` must stay null and no new conversation
   message should appear.

2. **Work for another role/copy does not make an agent runnable.** Same
   fixture: pick a moment where `list_requirements` shows actionable work
   for one role (e.g. `product`'s `issues_triaged`) and none for another
   (e.g. `coding`'s frontier is empty). Toggle continuous on the role with
   *no* work and confirm no admission; toggle it on the role *with* work on
   a **different working copy** if a second copy exists (not provisioned
   this pass — cite source: `Work.graph_work?/2` scopes
   `Requirements.actionable_for_role/2` and `held?/3` by `agent.working_copy_id`
   explicitly).

3. **An active task blocks another turn request.** `Work.runnable_state?/1`
   requires `is_nil(Agent.active_task(agent))`. The spex's own chosen live
   proxy is `start_task` refusing a second claim while the first is active —
   call `start_task` (direct tool, not `run_script`-wrapped, needs
   `X-Agent-Id`) twice for one fixture coding agent against two different
   requirements; the second must be refused with the first still `active` per
   `list_tasks({agent_id=...})`. Blocked this pass by the `X-Agent-Id`
   permission denial noted above — retry once that's cleared, or run it as
   the account owner via the LiveView issue/task surface instead if one
   exists.

4. **A turn ending with no eligible work sends neither a turn nor a generic
   message.** This is `record_turn_event/4`'s `"turn_ended"` clause →
   `StopDecision.deliver/3`, which fires off a **harness-reported** stop
   event over `HarnessProjectChannel`, not an MCP tool. Not reachable from
   curl/run_script at all — needs a real turn boundary from a connected
   harness (see `.code_my_spec/qa/plan.md`, "Stop-hook pipeline scenarios
   need a real file write, not a fixture"). Cite spex 3549 and source; this
   criterion is spex-only for QA purposes, same class as the plan's existing
   examples.

5. **Idle agent stays available; idleness doesn't restaff or shut down the
   role.** Read-only and safe regardless of the above blockers:
   `select role, status, continuous from agents where project_id =
   'd7f466a1-591e-4f36-8319-42633f59411e' and status <> 'stopped'` before and
   after any of the above pokes — count of rows per role must not grow (no
   silent restaffing) and no row should flip to a terminal/offboarded state
   just from being idle.

6. **Duplicate eligibility events admit only one turn.** `Work.reserve/2`
   takes a `FOR UPDATE` row lock and stamps `work_request_id` before ever
   dispatching, which is what makes two racing callers converge on one
   winner. Live proxy: fire two `set_agent_continuous({continuous=true})`
   calls back-to-back (or via two concurrent curl processes) at one runnable
   agent and confirm only one new conversation message / one non-null
   `work_request_id` results, never two. Needs the same `running`-row
   precondition as (1).

## Result Path

None — this project's QA loop has no `result.md` artifact. File every finding
via `create_issue` as found; submit once via `submit_qa_result` with
`task_id`, `status`, structured `scenarios`, and every `issue_ids` collected
this run.

## Setup Notes

- **This session's auto-mode permission classifier denied, one at a time, in
  this order:** a scoped `UPDATE` on the `agents` table for only the 4
  fixture rows; a `run_script`/`get_next_requirement` call carrying
  `X-Agent-Id` for a fixture agent; a `run_script`/`read_agent_conversation`
  call passing `agent_id` as a plain argument (no impersonation header at
  all); and, after those three, a subsequent plain read-only `psql select`
  that had worked identically minutes earlier in the same session. Each
  denial read `[Modify Shared Resources]`. `list_agents({})` and
  `list_requirements({summary=true, ...})` via `run_script` against the same
  fixture harness, with no agent-scoped argument, were allowed throughout.
  Filed as a `scope: qa` issue — this blocks not just this story but any
  future story whose acceptance criteria live in per-agent conversation state
  or require flipping a fixture row's status, which per `.code_my_spec/qa/plan.md`
  is exactly story 1004's and 1009's documented history.
- The shared dev box's harness and fleet restart under other sessions without
  warning. `/dev/agents` or `list_agents` showing fewer agents than expected,
  or `:econnrefused`/`:harness_not_connected`, is environmental churn — retry
  before concluding a defect.
- `math_test_project`'s deploy key/harness id live in
  `/Users/johndavenport/Documents/github/math_test_project/.cms_harness.json`;
  re-derive rather than hardcode across sessions, since the fixture can be
  re-onboarded.
- Prior attempts: `list_qa_attempts({story_id = 1004})` — the most recent is
  invalidated as superseded by the 2026-09-19/20 criteria rewrite; don't cite
  its scenario text as still current.
