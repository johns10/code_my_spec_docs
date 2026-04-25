# Next Actionable Requirement — Rules

**Story (561):** As the agent, I want the harness to return the next actionable requirement — the highest-priority unsatisfied node whose incoming prerequisites are all satisfied — so that I always have exactly one correct thing to work on and can't accidentally work on vacuously-satisfied leaves.

**Out of scope:** Parallel dispatch and in-progress filtering are deferred. `next_actionable` returns an ordered list, but today the caller consumes the head. Human-action / human-task gates are also deferred — every current requirement points to an `AgentTasks.*` module, so the distinction has nothing to exercise today. Both come back when the orchestration and human-task abstractions land.

---

## Rule: Vacuously-satisfied checker results do not enable downstream work

A checker may return satisfied when it shouldn't — a "zero failures" check on a nonexistent test file, a "file count" check on an empty directory. The graph distinguishes checker truth from chain truth: each node keeps its raw `satisfied` (what the checker returned) and a derived `effective_satisfied = satisfied AND every incoming prereq's effective_satisfied`, iterated to fixed point. Downstream edges, actionability, and done-detection all read `effective_satisfied`, so vacuous truth never propagates. `satisfied` and `details` are preserved on the returned node so the UI and logs see what the checker actually reported — a passing test still reads as passing, even when its source file is missing.

## Rule: Actionable means unsatisfied and every incoming prerequisite is satisfied

A node is actionable when both hold: its checker reports unsatisfied, and every inbound edge's source is genuinely satisfied (not merely vacuously so). Using the chain-aware satisfaction prevents the vacuous-truth cascade — a leaf whose checker passes vacuously does not unblock downstream work on its own.

## Rule: Actionable results are sorted by story priority, tiebroken by oldest entity created_at

The returned list is ordered primarily by the priority propagated from the driving story (see story 563). Lower priority numbers come first; nodes with no inherited priority sort last (project-level nodes with no driving story fall into this bucket). Ties break on the entity's `created_at` — older stories or components first. Makes output deterministic and aligns with "the thing you committed to first finishes first."

## Rule: Return distinguishes ready, blocked, and all-done

`next_actionable` returns a tagged value: `{:ready, nodes}` with a non-empty ordered list when work is actionable, `:blocked` when unsatisfied requirements exist but none is currently actionable (at least one prereq is not genuinely satisfied on every candidate), and `:all_done` when every requirement is satisfied. The caller (story 538's agent loop) uses the three states distinctly — `:ready` continues the loop, `:blocked` and `:all_done` terminate with different notifications. The list shape inside `{:ready, nodes}` is preserved so future multi-instance orchestration can consume more than one without re-designing the graph API.

## Rule: Graph computation raises when `satisfied_by` references a missing module

When a requirement definition points to an agent task module that isn't loaded — renamed, deleted, typo — graph computation raises immediately. No silent filter, no graceful fallback. Template staleness surfaces at the earliest possible moment (app start, CI, or the first `compute_graph` call) so refactors can't leave dead references lurking in the template.

---

## Session notes

**Why derive `effective_satisfied` instead of clamping `satisfied`.** The original design clamped the `satisfied` field downward when prereqs were unsatisfied, which prevented the vacuous-truth cascade but had two costs: it overwrote the checker's `details` with a generic "prerequisites not yet satisfied" string (erasing real diagnostic info), and it made the node lie about its own checker state (a passing test read as "not passing" because its source file didn't exist). Deriving a second field keeps the checker's truth intact, preserves `details` for humans and UI, and still gives downstream logic the chain-aware signal it needs. Same invariant, honest fields.

**Fixed-point iteration is the same algorithm.** Compute `effective_satisfied` bottom-up (or iteratively until stable). The cost is the same as the previous clamp. Only the output field and the non-mutation of `satisfied` / `details` change.

**Why no human-gate rule yet.** Every current requirement has `satisfied_by: AgentTasks.*` — nothing in the template is completed by human action. A future story will introduce a proper `human_task` abstraction (stakeholder sign-off, security review, PM approval), and the actionability rule will grow a clause then. Putting `:human_action` in now would be a speculative feature with no real user.

**Why no in-progress filter.** Parallel dispatch across sessions requires either caller-side exclude lists, session-wide lookups, or a lock manager — plus stale-task detection via heartbeats or TTLs. Single-agent-per-session doesn't need any of that. Deferring until the orchestration direction is chosen.

**UI benefit.** Three observable states per node now have distinct representations: checker failed (needs work), checker passes but chain isn't ready (show "waiting on upstream"), truly done.

**Test infrastructure dependency.** The vacuous-cascade scenarios require the ability to construct a graph with specific satisfaction states on specific nodes. Today's graph computes state by running real checkers on real files, so exercising those scenarios requires either real file-system setups that produce the target states (heavy, and depends on per-checker behavior defined in the agent-task specs) or a test-only fixture API that bypasses the calculators. The fixture API is its own small follow-up — tracked in `questions.md`.
