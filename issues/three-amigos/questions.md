# Three Amigos — Questions

Parked during the session. Each is a gap that needs an answer before
or during implementation.

## Q: `Story.three_amigos_completed_at` exact field shape

Resolved in principle: a boolean or timestamp on Story marks the
session done when `evaluate/2` confirms readiness. Exact column name,
nullable timestamp vs boolean + completed_at pair, migration shape —
TBD at impl time.

## Q: PM-vs-agent simultaneous edits

PM edits cards directly in the UI; agent mutates via MCP. Conflict
resolution model when both touch the same card in the same moment —
last-write-wins, optimistic lock with reject, or PubSub-coordinated
serialization?

## Q: Review agent at session end?

Scenario quality (domain language vs. implementation leakage,
scenario titles that name the persona with relevant context,
observable Then clauses) is hard to enforce in real-time and
unreliable as a structural check. Should the readiness gate spin up a
review agent that grades scenarios at session end and flags issues
for the PM to fix? If yes — what's the contract: pass/fail gate,
advisory only, or PR-style review comments per scenario?

---

## Resolved: Persona research is not inline

Reversed earlier decision. The agent does not run persona research
inside Three Amigos. When a needed persona doesn't exist, the agent
calls `add_persona` to create a lightweight record (identity +
metadata only) and links it via `persona_stories`. Full research
(summary.md + sources.md) surfaces as a separate `personas_complete`
graph requirement on the next pass — keeping Three Amigos sessions
clean of nested task complexity.

## Resolved: Persona library dependency

Three Amigos does not require a pre-existing persona library. The
agent links existing personas when available; if a needed persona
doesn't exist, the agent calls `add_persona` to create a lightweight
persona record and links it. (See above — full research is a separate
graph requirement.)

## Resolved: Question schema — link to rule?

Not necessary. `Question` has `story_id`, `text`, `status` only.

## Resolved: `.feature` file rendering

DB-only. No `.feature` file written to disk. Downstream consumers
(SexySpex, codegen, UI viewer) read from the DB via MCP tools (e.g.
`get_story_gherkin`).

## Resolved: Readiness failure detail surface

Same `delegate` checker pattern as `PersonasChecker` — the checker
returns a markdown detail string listing each failing readiness
condition, surfaced through the stop hook into the next turn's
feedback.

## Resolved: Ordering — position fields or array index?

Neither. Order rules and scenarios by `inserted_at` ascending. No
`position` field. No `reorder_*` MCP tool.

## Resolved: Can the PM edit cards directly in the UI?

Yes. PM mutates state through direct UI edits; agent mutates state
through MCP tools. Both flow through the same domain APIs. (See open
question above on simultaneous-edit conflict resolution.)

## Resolved: What happens when readiness fails?

Session ends without the completion marker being set. Graph
re-dispatches Three Amigos on the next `get_next_requirement` for
that story (since AC < required state). Detail of what failed flows
through the stop-hook checker as a markdown string. The completion
marker (`Story.three_amigos_completed_at` or equivalent)
distinguishes "in progress" from "done."

## Resolved: Walk-away resumption

Out of scope — chat happens in Claude Code, not the local web UI.
If the PM closes Claude Code, they pick the work back up via
`get_next_requirement` in a new Claude session. The story's artifacts
persist; the agent re-orients from the existing Rule / Criterion /
Question records on the story.

## Resolved: 25-minute time-box

No enforcement. Time-boxing is a workshop-facilitator suggestion, not
a system constraint.

## Resolved: Engineer-as-PM persona

Identical protocol. Technical context is allowed in the conversation
(the engineer-as-PM may discuss DB schemas, integration points, etc.),
and the desired outcome is that Given/When/Then bodies stay in domain
language with no implementation details. Not enforced as a structural
rule — see open question on review agent.

## Resolved: Who triggers the readiness check?

Domain validation enforces it structurally. No PM-clicks-confirm
checkpoint.

## Resolved: Gherkin body generation cadence

Titles and Given/When/Then bodies are written together as one atomic
operation per scenario.

## Resolved: Domain model and context placement

Three contexts. New `Rules` (`Rule` schema). New `Questions`
(`Question` schema). `AcceptanceCriteria` enriched (`Criterion` gains
`rule_id`, `body`, `kind`). No Session schema for Three Amigos. Plain
text Gherkin body on Criterion. Separate contexts; not nested.

## Resolved: Write-through tech debt

Reworked inline as part of Three Amigos; not split into separate
stories. `Stories.RemoteClient`, `AcceptanceCriteria` (full
RemoteClient + BootSync + RemoteSync stack), and the new `Rules` /
`Questions` contexts all get the Personas-pattern write-through.

## Resolved: MCP tool surface granularity

Granular per object — `add_rule`, `add_scenario`, `add_question`,
`add_persona`, `link_persona`, `resolve_question`, `get_story_gherkin`,
etc.

---

## Deferred: Story revision invalidates AC

If the PM revises a story description via `story_interview` after
Three Amigos has populated AC, do existing rules / scenarios /
questions get cleared (so Three Amigos re-dispatches), or persist
(PM manually deletes if the spec is now wrong)? In theory yes (clear),
but not implementing now.
