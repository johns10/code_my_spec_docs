# Next Actionable Requirement — Rules

**Story (561):** As the agent, I want the harness to return the next actionable requirement — the highest-priority unsatisfied wave whose incoming prerequisites are all satisfied — so that I always have the right batch of work to focus on, and never thrash across sibling trees or work on vacuously-satisfied leaves.

**Out of scope:** Parallel dispatch and in-progress filtering remain deferred. The harness returns one wave per call; the agent works the wave to completion before asking for the next. Human-action / human-task gates also deferred — every current requirement points to an `AgentTasks.*` module, so the distinction has nothing to exercise today. Both come back when the orchestration and human-task abstractions land.

---

## Rule: Vacuously-satisfied checker results do not enable downstream work

A checker may return satisfied when it shouldn't — a "zero failures" check on a nonexistent test file, a "file count" check on an empty directory. The graph distinguishes checker truth from chain truth: each node keeps its raw `satisfied` (what the checker returned) and a derived `effective_satisfied = satisfied AND every incoming prereq's effective_satisfied`, iterated to fixed point. Downstream edges, actionability, and done-detection all read `effective_satisfied`, so vacuous truth never propagates. `satisfied` and `details` are preserved on the returned node so the UI and logs see what the checker actually reported — a passing test still reads as passing, even when its source file is missing.

## Rule: Actionable means unsatisfied, has a satisfied_by, and every incoming prerequisite is satisfied

A node is actionable when three conditions all hold: it has a non-nil `satisfied_by` (an agent task that can address it), its checker reports unsatisfied, and every inbound edge's source is genuinely satisfied (not merely vacuously so). Using the chain-aware satisfaction prevents the vacuous-truth cascade — a leaf whose checker passes vacuously does not unblock downstream work on its own. A node missing any of the three is filtered.

## Rule: next_actionable returns one wave plus a remaining count

The harness returns a tagged value: `{:ready, %{wave: nodes, remaining_count: n}}` when work is actionable, `:blocked` when unsatisfied requirements exist but none is currently actionable, and `:all_done` when every requirement is satisfied. The wave is the leading run of the sorted actionable list whose nodes share the same sort key — typically the parallel-eligible siblings of one orchestrated tree, or a single node when the chain is serial. `remaining_count` is the number of actionable nodes outside the surfaced wave, so the agent and UI know how much work is queued behind the current focus. The agent works the entire wave to completion before calling again.

## Rule: Project work leads when actionable

Whenever a project-level node is in the actionable list, it surfaces before any story-driven work. Project's sort key precedes every story and component sort key, so even if a story chain is mid-flight, a project node that becomes actionable (because its cross-graph deps have just cleared) will preempt the next story wave on the following `next_actionable` call. Project work is foundational; it should never wait behind work that depends on it.

## Rule: Stories sort by priority, components inherit through the projector

Among stories, lower priority number leads, with oldest `created_at` breaking ties. Components inherit priority from their linked story via three propagation paths the projector already establishes: direct `story.component_id` link, surface-component dependencies (`DependencyTree`), and `parent_component_id` chains. Components with no inherited priority sort last among their cohort. The graph carries one effective priority per node; no domain-specific sort hooks live in the harness.

## Rule: One orchestrated tree at a time

The wave never crosses an orchestrated-tree boundary (`parent_entity_id`). When a story spans multiple bounded contexts, they complete serially in dependency order — each context's full chain (parent spec, children specs, review, children impls and tests) finishes before the next context starts. Parallelism is only offered within a single tree (parent fanning out to children at spec time and again at implementation time). The same principle applies anywhere parallelism could otherwise emerge across sibling trees — project tracks, future multi-instance dispatch — not just bounded contexts. Reason: keep the agent's working memory loaded on one tree at a time so reasoning stays coherent.

## Rule: Every returned node carries its orchestration metadata

Every node in the wave carries `execution_type` (`:main_agent` vs `:sub_agent`), `orchestrated_by` (the orchestrator-owning task, if any), and `validation_type` (`:automatic` vs `:manual`). The wave is a list of action items the caller can dispatch directly, not a list of pointers requiring a second lookup.

## Rule: Graph computation raises when `satisfied_by` references a missing module

When a requirement definition points to an agent task module that isn't loaded — renamed, deleted, typo — graph computation raises immediately. No silent filter, no graceful fallback. Template staleness surfaces at the earliest possible moment (app start, CI, or the first `compute_graph` call) so refactors can't leave dead references lurking in the template.

---

## Session notes

**Why a wave instead of a flat priority-sorted list.** The original return shape was a single ordered list with the agent consuming the head. That conflates two questions: "what's the highest-priority work?" and "how much of it can I do at once?" The wave answers both — it's the prefix of the sorted list that shares the same sort key, so it naturally captures parallel-eligible siblings (children fanning out from a parent context) and naturally collapses to a single node when the chain is serial. The shape is `{:ready, %{wave, remaining_count}}` so the UI can show "working on wave of N — M others queued" without re-querying.

**Why one orchestrated tree at a time.** Sibling-context parallelism would force the agent to thrash across multiple bounded contexts at once — switching mental models for each, losing continuity, producing shallower designs. Serializing sibling trees keeps the working context coherent. The graph already carries `parent_entity_id` for free as the orchestrated-tree boundary, so this rule needs no new domain knowledge — just one constraint on the wave-extraction logic.

**Why project leads.** Project work is structurally foundational: stories and components depend on it. The previous "project sorts last" rule was a side-effect of nodes lacking inherited priority; with priority inversion, project gets a leading sort key and all chains naturally wait behind it. Project nodes that re-enter the frontier after their cross-graph deps clear (e.g., `all_bdd_specs_passing` waiting on every story's BDD pass) will preempt the next-up story wave. That's intentional.

**Why derive `effective_satisfied` instead of clamping `satisfied`.** Clamping the `satisfied` field downward when prereqs were unsatisfied would prevent vacuous-truth cascades but at two costs: it overwrites the checker's `details` with a generic "prerequisites not yet satisfied" string (erasing real diagnostic info), and it makes the node lie about its own checker state (a passing test reading as "not passing"). Deriving a second field keeps the checker's truth intact, preserves `details` for humans and UI, and still gives downstream logic the chain-aware signal it needs.

**Why no human-gate rule yet.** Every current requirement has `satisfied_by: AgentTasks.*` — nothing in the template is completed by human action. A future story will introduce a proper `human_task` abstraction (stakeholder sign-off, security review, PM approval), and the actionability rule will grow a clause then. Putting `:human_action` in now would be a speculative feature with no real user.

**Why no in-progress filter.** Parallel dispatch across sessions requires either caller-side exclude lists, session-wide lookups, or a lock manager — plus stale-task detection via heartbeats or TTLs. Single-agent-per-session doesn't need any of that. Deferring until the orchestration direction is chosen.

**Test infrastructure dependency.** The vacuous-cascade and wave scenarios require the ability to construct a graph with specific satisfaction states on specific nodes. Today's graph computes state by running real checkers on real files, so exercising those scenarios requires either real file-system setups that produce the target states or a test-only fixture API that bypasses the calculators. The fixture API is its own small follow-up — tracked in `questions.md`.
