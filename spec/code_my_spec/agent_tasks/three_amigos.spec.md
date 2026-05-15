# CodeMySpec.AgentTasks.ThreeAmigos

## Type

skill

## Intent

Run a facilitated Example Mapping (Three Amigos) session on a single
story. The agent plays all three amigos — **Business** (rules and
outcomes), **Developer** (constraints and dependencies), **QA**
(failure modes and edge cases) — while the human Product Manager
holds product intent.

The deliverable is a populated set of Rule + Criterion (scenario) +
Question records on the story, persisted via dedicated MCP tools.
No Gherkin is written to disk during the session — that's
`write_bdd_specs`'s job downstream.

This is a **multi-turn, manual-validation** task. The agent and PM
exchange across many turns; the stop hook does not auto-evaluate.
The agent calls `evaluate_task` explicitly when readiness conditions
are met.

## Done signal

`BddRulesChecker.complete?/2` returns success. The check requires
ALL of:

- ≥1 persona linked to the story (`link_persona_to_story`).
- ≥1 Rule exists on the story (`add_rule`).
- Every Rule has ≥1 scenario, any `kind` (`add_scenario`).
- `rules < 10` (story too big past 10 — split it).
- `scenarios > open questions` if questions exist (the story isn't
  ready if questions outnumber scenarios).

## Dispatch shape

`topic_task` — takes a story_id directly (via the
`/codemyspec:product three-amigos <story_id>` skill route or via the
graph dispatch's `entity_id`). Surfaces from the story graph as
`three_amigos_complete` (id 5, `validation_type: :manual`), gated by
`component_linked` (id 1).

## Out of scope

- The task does not write BDD spec files (`*_spex.exs`). That's
  `write_bdd_specs` on the next graph pass.
- The task does not do persona research. Lightweight identity +
  metadata is what gets linked here; full research is the
  `personas_complete` requirement on the next graph pass.
- The task does not implement the story or write code. Discovery,
  not delivery.
- The task does not auto-evaluate. The PM/agent conversation is
  multi-turn — the stop hook is suppressed.

## Failure modes the agent should avoid

- Writing Gherkin to disk during the session. The MCP tools are
  the persistence layer.
- Fabricating failure-path scenarios to fill a coverage template.
  Only add a `failure_path` when a genuine failure surface exists.
- Skipping persona linkage. Without a persona the story has no
  voice.
- Doing persona research inline. Defer to `personas_complete`.
- Splitting one rule across two `add_rule` calls. Each rule is one
  statement.
- Calling `evaluate_task` before readiness conditions are met.
  The check will fail and the session won't advance; verify the
  done signal first.

## Resources

Required input:
- `task.story_id` (or `requirement_name` carrying the story_id, or
  `entity_id` from graph dispatch). The task resolves any of these
  to the underlying Story record.
- The story record (title + description) — used to orient the
  session in the rendered prompt.

Optional context:
- Existing personas on the project — listed via `list_personas`.
- Existing rules/scenarios on the story (from a prior partial
  session) — preserved across runs.

Required reading:
- `priv/knowledge/three_amigos/workflow.md` — full protocol:
  ordering, MCP tool usage per phase, done-signal definition,
  manual-validation flow, anti-patterns.

Produced (via MCP tools, not files):
- Persona records linked to the story.
- Rule records on the story.
- Criterion (scenario) records on each rule.
- Question records (red cards) for unresolved items.

The rendered prompt also includes a Session URL
(`<base_url>/app/stories/<story_id>/three-amigos`) that the PM
opens to watch cards appear in real time.

## Tools

Task-specific MCP tools — all required:

- `list_personas` — enumerate personas on the project.
- `add_persona` (alias for `create_persona`) — create a lightweight
  persona record (identity + metadata only).
- `link_persona_to_story` — associate persona with the story.
- `add_rule` — persist a Rule on the story.
- `add_scenario` — persist a Criterion under a Rule with `kind:
  happy_path` or `failure_path`.
- `add_question` — park an unresolved Question on the story.
- `evaluate_task` — manually trigger validation when readiness
  conditions are met (this task does not auto-evaluate).

## Dependencies

- CodeMySpec.Requirements.BddRulesChecker
- CodeMySpec.Requirements.CheckerResult
- CodeMySpec.Stories
