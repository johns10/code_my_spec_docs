# Three Amigos — Rules

**Story (559):** As a product manager, I want to run the three amigos process
with an agent to develop my BDD specifications.

**Persona for this story:** Solo founder PM'ing their own product. Variable
BDD fluency. Working in Claude Code (chat) with the local web UI open in a
browser to visualize cards. Adjacent personas: small-team PM,
engineer-as-PM.

---

## Rule: Three Amigos is graph-dispatched per story; story is fixed input

The requirement graph auto-dispatches Three Amigos for any story whose AC
is empty (`count(criteria) == 0`). Prereq is `story_created`. Not
PM-initiated; no "click to start a session" affordance. The story
description is fixed during the agent's task — to revise the story, the
PM abandons and re-runs `story_interview` first.

## Rule: Protocol ordering is enforced

Persona linkage → Rules → Scenarios. The agent cannot skip ahead. A
scenario is a single green card holding both a title and its
Given/When/Then body, created as one atom — no two-stage "titles now,
bodies later" split. "Examples" and "scenarios" refer to the same
artifact at different fidelities; the domain stores one Criterion per
green card.

## Rule: Persona linkage required

The session cannot complete unless ≥1 persona is linked to the story
via `persona_stories`. The agent searches the account's persona
library; if no suitable persona exists, the agent calls the
`add_persona` MCP tool to create a lightweight persona record
(identity + metadata only — no research artifacts) and links it. Full
persona research (summary.md + sources.md) is not part of Three Amigos
— it surfaces as a separate `personas_complete` requirement on the
next graph pass. This keeps Three Amigos sessions focused on rules and
scenarios, free of nested task complexity.

## Rule: Each rule needs at least one happy-path and one failure-path scenario

Coverage gate. The agent generates failure-path scenarios even when the
PM only volunteers happy-path ones.

## Rule: Session readiness gate

The session cannot transition to completed until all of these are true.
Enforced by domain validation, surfaced through the stop hook via the
same `delegate` checker pattern as `PersonasChecker` (markdown detail
string listing each failing condition).

- ≥1 persona linked to the story
- `rules > 0`
- `rules < 10`
- `scenarios > questions` (green cards > red cards)
- every rule has at least one happy-path scenario
- every rule has at least one failure-path scenario

## Rule: Session state is a persisted domain object; PM and agent share it

Rules, Criteria (scenarios), and Questions (red cards) are top-level
persisted records, not embedded in a session blob and not flat files.
They live in dedicated contexts: `Rules`, `AcceptanceCriteria`
(enriched), `Questions`. Surfaced live in the local web UI as a
card-based view of the story's BDD spec. The agent mutates state
through MCP tools; the PM mutates state through direct UI edits — both
flow through the same domain APIs. A refresh, new tab, or chat-restart
never loses state.

## Rule: Agent operates via MCP tools

The agent's task prompt enumerates the available MCP tools (`add_rule`,
`add_scenario`, `add_question`, `add_persona`, `link_persona`,
`resolve_question`, `get_story_gherkin`, etc.) and points the agent at
the knowledge MCP for protocol guidance.
No direct DB writes, no flat-file writes, no out-of-band mutations. The
MCP calls are visible in Claude Code's chat transcript; no separate
audit log is persisted.

## Rule: Documentation is split — PM gets UI, agent gets knowledge MCP

PM-facing tutorial content (what is a rule, why happy and failure paths
both matter, what makes a good scenario title) lives as in-product
documentation in the local web UI: doc links on the session page, hover
tooltips on card types, an onboarding panel for first-time users. The
agent queries the knowledge MCP tool for protocol guidance — overview,
scenario quality bar, readiness rules. Source documents are embedded
into the knowledge corpus by the pipeline; the agent addresses the
corpus through the MCP tool, never the on-disk directory directly. The
agent does not embed BDD tutorials in its chat responses.

---

## Session notes

**No session schema.** The story IS the session container. Rule,
Criterion, and Question rows hang off the story directly. Mirrors the
persona research pattern (no session record; the artifacts ARE the
session output). Resumption is automatic — the story has its current
artifacts at any point.

**Completion marker.** A boolean (or timestamp) field on `Story`
(e.g., `three_amigos_completed_at`) is written when the agent's
`evaluate/2` confirms the readiness gate passes. Distinguishes
"AC exists but session never officially completed" from "session done."
Exact column shape TBD at impl time.

**Scenario quality is not enforced in real-time.** The "scenarios in
domain language" / "observable behavior, not internal state"
guidelines BDD literature pushes are quality concerns the agent is
encouraged to follow, but the readiness gate doesn't enforce them —
there's no reliable structural check. A future review-agent pass at
session end is a candidate for catching scenario quality issues; see
open question.

**`.feature` file is DB-only.** No `.feature` file written to disk.
Downstream consumers (SexySpex, codegen, UI viewer) read directly from
the DB via MCP tools (`get_story_gherkin` or similar). `.feature` files
are not versioned in git for stories.

**Gherkin body shape.** Single `body` text field on Criterion, plain
Gherkin. No per-clause split into `given` / `when` / `then` columns —
Gherkin uses `And` / `But` / `*` / multi-line steps that don't fit a
3-column model. The .feature view (UI or via MCP) is just
`Scenario: <title>` with the body indented underneath.

**Three new/enriched contexts.** `Rules` (new — `Rule` schema with
`story_id`, `project_id`, `account_id`, `statement`). `Questions`
(new — `Question` schema with `story_id`, `project_id`, `account_id`,
`text`, `status: :open | :resolved | :deferred`). `AcceptanceCriteria`
enriched (`Criterion` gains `rule_id`, `body`,
`kind: :happy_path | :failure_path`). Separate contexts — not nested
under AcceptanceCriteria. Ordering of rules and scenarios is
`inserted_at` ascending; no `position` field, no reorder MCP tool.

**Write-through tech debt.** Three Amigos cannot ship until
`Stories.RemoteClient` adds local-cache write-through (Personas
pattern) and `AcceptanceCriteria` grows the full
`RemoteClient + BootSync + RemoteSync` stack. New `Rules` and
`Questions` contexts need the same pattern from the start. Reworked
inline as part of this story; not split into separate stories.

**Agent task module shape** mirrors
`lib/code_my_spec/agent_tasks/write_bdd_specs.ex` and persona research:
`command/2` builds a prompt with project / story / persona context,
knowledge MCP pointer, and tool surface; `evaluate/2` checks the
readiness gate and returns per-condition specifics on failure.
