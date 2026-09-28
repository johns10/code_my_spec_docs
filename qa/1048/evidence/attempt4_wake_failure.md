# Story 1005, attempt 4 — evidence for "wake never fired"

## Target
- Agent `0067d652-1059-4e6d-a3ec-6e742435779a`, role=coding, continuous=true, working_copy_id=`8a03db06-5035-494f-a751-bb7477eaf8ad` (root `.../963-main-agent-nontechnical`, harness_id == working_copy_id, JOINED at 21:38:28Z).

## Four gates verified before triggering (21:42-21:43 UTC)
1. status=running, continuous=true (`/dev/agents`, `/dev/fleet`).
2. No pending question/tap_out: read_agent_conversation (relayed via
   call_mcp_server -> harness 8a03db06 -> run_script -> read_agent_conversation)
   showed the tail ending on two consecutive "The harness restarted. Nothing
   of your own was in flight, so nothing was lost." operator notices, no
   trailing `Q:` without a matching `A:`.
3. Not mid-turn: `turn_started_at` is NULL in `agents` table; /dev/fleet's
   tool_calls/spoke/last_message identical across two reads 6s apart
   (21:42:48 and 21:42:54).
4. GraphWatcher for project 708492f9 was watching=true, recompute_pending=false,
   last_recompute fresh (21:40:42Z), disagreements=[] — confirmed via /dev/state.

## Trigger
- 21:43:45Z: `create_issue` (scope=app, severity=medium, story_id=985) then
  `accept_issue`. Story 985 confirmed routed to working_copy_id 8a03db06 via
  psql (`select ... from stories where id=985` -> working_copy_id =
  8a03db06-5035-494f-a751-bb7477eaf8ad).
- `/dev/fleet` gating_issues.app incremented 15 -> 16 on the very next read,
  confirming registration.

## What should have happened, confirmed via DB + code
- `requirements` row for (story_id=985, name=story_issues_resolved,
  working_copy_id=8a03db06) flipped satisfied=true -> satisfied=false within
  the very next GraphWatcher recompute pass (21:43:57Z, confirmed via
  web.log `[Requirements] pass cost ...` / shadow log lines naming
  `story:985/story_issues_resolved`).
- Its sole prerequisite in the story-requirements template is `qa_complete`
  (id 4 in that template), which is satisfied=true for this working copy.
- The node (requirements.id=3094830) has exactly ONE edge, incoming, FROM
  qa_complete(985) which is satisfied. Zero outgoing edges. So nothing in
  `RequirementGraph.blocked_for_role/3` (lib/code_my_spec/requirements/requirement_graph.ex:1442)
  can be clamping it — clamping only propagates along OUTGOING edges from an
  unsatisfied same-role seed, and this node has no incoming edge from any
  *other* unsatisfied node.
- `role: :coding`, `satisfied_by: AgentTasks.FixStoryIssues` (not nil),
  `entity_type: "story"` (so `untethered_component?/2` returns false) — every
  filter in `actionable_for_role_from/4` (same file, line 1421) should pass.

## What actually happened
- `/dev/fleet`'s `actionable` for agent 0067d652 stayed at **0** across 6+
  polls spanning 21:43:21Z (before trigger) through 21:52Z+ (well after),
  including across at least 3 further GraphWatcher recomputes
  (21:43:57, 21:45:05, and others visible in web.log up to 21:46:59).
  This is not a stale/cached read — `dev_state.ex:actionable_for/1` calls
  `CodeMySpec.Requirements.actionable_count(scope, role)` fresh on every
  HTTP request, scoped to the agent's own `working_copy_id` + `role` — the
  identical function `StopDecision.wake/2` -> `Validation.Menu.render/4` ->
  `Menu.live/3` calls to decide whether to message the agent.
- `read_agent_conversation` (relayed) for the window `since=2026-09-16T21:43:00Z`
  through the time of the last check (~21:51Z) returned **"No turns fall
  inside that window"** — i.e., literally zero new conversation activity of
  any kind for the target agent, not just no "Work of your kind is
  available" text.
- gating_issues.app is correctly incremented (16) confirming the issue itself
  is real and counted at the project level — the disconnect is specifically
  between "this working copy's coding-role actionable set" and the
  underlying unsatisfied+unblocked requirement row.

## Correlated (not proven causal) signal
`CodeMySpec.Requirements.Shadow` (the experimental event-derived projection
being validated against the live/authoritative computation) logged
persistent, non-converging disagreement on exactly `story:985/story_issues_resolved`
from 21:43:53Z through at least 21:46:59Z (4 separate recompute passes),
and — independently, from an EARLIER QA attempt's own probe issue on story
965 (`46757733-7f02-4bc7-b7fe-cce23e5ed3e0`, already resolved) — the same
persistent disagreement on `story:965/story_issues_resolved`, despite that
story's requirement already reading satisfied=true in the live table. Two
independent QA-probe mutations, on two different stories, both left a
same-shaped shadow/live disagreement that never converges across many
passes. This does not by itself explain the actionable-count defect above
(Shadow is documented as read-only instrumentation, not the source
`actionable_count` reads), but it is the same class of graph-consistency
failure and worth an engineer's attention alongside it.

## Conclusion
Criteria 3188 / 3295 / 3294 ("a ready story wakes the idle coding agent" /
"work inside my role and my copy wakes me" / "a published wake reaches a
healthy agent") did not reproduce under ideal, fully-gated conditions. The
defect appears to sit in `CodeMySpec.Requirements.RequirementGraph`'s
actionable computation (or something upstream of it that this trace could
not reach — e.g. a fingerprint/cache layer not visible from the DB rows
inspected here) rather than in `StopDecision`/`Agents.wake_project_roles`,
which were traced and look correct.
