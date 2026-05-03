# Next Actionable Requirement — Questions

## Resolved: How does the graph prevent vacuous-truth cascades?

Each node carries two satisfaction fields: `satisfied` (raw checker result, never mutated) and `effective_satisfied` (derived, `= satisfied AND every prereq's effective_satisfied`, iterated to fixed point). Downstream edge checks and `next_actionable` read `effective_satisfied`, so a vacuously-satisfied leaf (`satisfied=true, effective_satisfied=false`) correctly blocks downstream work without overwriting the checker's own truth or details. Computed on every `compute_graph`, `compute_all`, and `next_actionable` call.

## Resolved: Does `next_actionable` return one or many? What about "nothing actionable" vs "all done"?

Returns a tagged value: `{:ready, nodes}` | `:blocked` | `:all_done`. Three distinct states because story 538's agent loop needs to tell "graph has work but nothing is actionable right now" (blocked on prereqs or human gates — loop terminates with notification) apart from "graph is fully satisfied" (loop terminates, work complete). The list shape inside `:ready` is preserved so future multi-instance orchestration can consume more than one without re-designing the API. Today's caller takes the head.

## Resolved: Priority tiebreaker when multiple actionable nodes share inherited priority

Break ties on the entity's `created_at` — older stories or components first. Makes output deterministic and aligns with "the thing you committed to first finishes first" intuition.

## Resolved: Execution type routing

`next_actionable` returns `:main_agent` and `:sub_agent` nodes mixed. One query, no caller-side splitting. Revisit if the orchestration direction demands separate streams.

## Resolved: Task-failure backoff

No backoff. Failed tasks re-surface on the next `next_actionable` call. Stuck-detection and escalation live in story 538 (LLM Agent Autonomous Task Execution).

## Deferred: Human-action / human-task gates

Every current requirement has `satisfied_by: AgentTasks.*` — nothing in the template is completed by human judgement today. Originally this story introduced `satisfied_by: :human_action` as an explicit marker, but with nothing to exercise it, the rule was speculative. Dropped from this story. A future story will introduce a proper `human_task` abstraction (stakeholder sign-off, security review, PM approval) and grow the actionability rule with the appropriate filter at that point.

## Resolved: What if `satisfied_by` points to a module that no longer exists?

Loudest possible failure. Graph computation raises immediately, naming the missing module and the requirement that referenced it. No silent filter, no graceful fallback. Template staleness surfaces at app start, CI, or the first `compute_graph` call — refactors can't leave dead references in the template.

## Deferred: Multi-session concurrent races + in-progress filter

Parallel dispatch across sessions (subagents or multi-instance agents) requires either caller-side exclude lists, session-wide lookups, or a lock manager — plus stale-task detection via heartbeats or TTLs. Out of scope for this story. A future orchestration story will cover multi-instance dispatch, likely via a `:role` field on requirements rather than subagents.

## Deferred: What counts as "in-progress" on a task?

Folded into the deferred multi-instance orchestration story. When that story lands, candidate rule: `task.status in [:prepared, :active]` excludes; `:completed`, `:failed`, `:cancelled` do not.

## Deferred: Graph test-fixture API

Vacuous-cascade scenarios in the feature file require the ability to construct a graph with specific satisfaction states on specific nodes. Today the graph computes state by running real checkers on real files, so exercising those scenarios means real file-system setups — which depend on per-checker behavior defined in the agent-task specs. A small test-only fixture API that skips the calculators and stamps node states directly would unblock the BDD tests without waiting on every agent-task spec. Tracked here so it doesn't vanish; belongs in its own story once the agent-task specs clarify what checker behavior needs to be simulated.
