# QA Result — Story 1017

Evidence log. The canonical pass/fail record is the `submit_qa_result` DB
attempt + linked issues; this is supporting detail only.

Fixture: `math_test_project` (project `d7f466a1-591e-4f36-8319-42633f59411e`,
working copy `56f5bf62-9cf8-400d-abcd-6c796afd3437`), refreshed via
`mix cms.seed priv/repo/qa_wake_seed.exs`.

## 3320 / negative half of 3317 — quiet recovery leaves everyone alone

Called `check_in` as main twice: once with the seeded fleet mid-reap-window
(main + both coding agents ineligible; product had real eligible graph work —
see 3317 below) and once with the whole fleet fully `status: stopped`. In
both cases every ineligible/idle agent's row was unchanged
(`work_request_id`/`turn_started_at` stayed null throughout a ~9s concurrent
DB poll), `list_tasks` stayed "No tasks." for main/coding, and
`list_notifications`'s count did not change. `cadence({seconds: 300})` then
`cadence({seconds: 1200})` similarly produced no task/notification side
effects (3331).

## 3317 — positive half (admits a turn only for genuinely runnable work)

`get_next_requirement` as `product` (e9dce99a-...) showed real eligible graph
work (`personas_complete`); main and both coding agents showed "Nothing for
this role right now." Re-seeded, then immediately called `check_in` as main
while polling agent rows every ~300ms. No persisted `work_request_id` blip
was caught, and response latency (0.70s eligible vs 0.57s baseline) was
inside the noise of the three-round-trip MCP handshake, so this pass could
not distinguish "attempted a fast-failing dispatch to a non-existent live
engine" from "no attempt made" purely by black-box observation — proving the
positive admission path conclusively needs either a live engine process
listening for that agent (out of scope for a fast pass) or the spex
HeldProvider/Machine harness that criteria 3317/3334 already exercise
directly. The negative guarantee (no eligible work → definitely nothing
happens, demonstrated repeatedly above) is the higher-value live signal and
is solid.

## 3318 — question work reconsidered without waiting for the timer

`ask_user_question` as coding agent `25d67c11-...` → immediately (no delay)
`list_notifications` as main already showed it under "Needs your attention,"
not queued for a future check. Question id `99d8418f-c9f5-4734-9655-f68d8d3eb94f`.

## 3319 — silent agent observed, no automatic intervention

`list_agent_work` as main reported per-agent state only; no restart fired
from the read. Every `check_in` response also states this in its own text
("no process was started or restarted").

## 3331 — interval configures checks, not turns

See 3320 above — `cadence({seconds: N})` changed only the reported interval.

## 3332 — recovery exposes evidence without selecting a task

`check_in`'s response text plus `list_tasks` staying "No tasks." for main
immediately after every call.

## 3333 — failed digest remains an observable failure

`POST /dev/faults {"key":"d7f466a1-...","fault":"digest_unavailable"}` →
`check_in` → issue "The check-in could not be assembled" (severity high,
scope framework, status incoming) created immediately. Cleared via
`DELETE /dev/faults`.

## 3334 — task tap-out is local

`start_task` as product for `personas_complete` → task id
`9c0a643e-aa74-4016-80cc-8ec039fa60ba`. `tap_out({task_id: "9c0a643e-..."})`
→ `list_tasks` showed it `[blocked]` on `tap_out 2e1130f1-...`. `cadence({})`
and `agents.continuous` (still `true` in DB) were identical before and after.

## 3335 — whole-agent tap-out preserves reachability

`tap_out({task_id: nil})` on main (no active task) → response text
correctly says "asks to turn off continuous work upon approval"; permission
request `3892806d-e9fe-447a-80db-4b83dc3b046c` created, `task_id: nil`,
`tool_name: "tap_out"`. Approving it and observing `continuous` flip to
`false` while the agent stays reachable requires a session belonging to the
permission's `user_id` (real account owner, id 1) — blocked for QA, see
brief's Setup Notes and issue `a0880cf1-a3f5-484a-af76-95131fc54798`. The
mechanism itself (`update_tap_out_owner/3` in `notifications.ex`) is a
direct, deterministic field update confirmed by source reading, and the
spex drives the approve-and-observe half directly.
