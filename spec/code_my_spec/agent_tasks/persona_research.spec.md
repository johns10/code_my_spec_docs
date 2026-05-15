# CodeMySpec.AgentTasks.PersonaResearch

## Type

skill

## Intent

Run a persona research session with the Product Manager. Produce
one persona on the active project: a DB record (via `create_persona`)
plus two markdown artifacts at `.code_my_spec/personas/<slug>/`
(`summary.md` with required H2 sections, `sources.md` as a link list),
linked to at least one story via `link_persona_to_story`.

Triangulation is the evidence bar: ≥3 independent sources per claim,
verbatim quotes over paraphrase. The session is multi-turn —
intake conversation, then research, then artifacts.

## Done signal

`Requirements.PersonasChecker.complete?/2` returns success. The check
requires:

- ≥1 persona linked to this project via `persona_stories`.
- Every linked persona has a DB row.
- `.code_my_spec/personas/<slug>/summary.md` exists and validates
  against the persona document type (required H2 sections present).
- `.code_my_spec/personas/<slug>/sources.md` exists and is non-empty.

## Dispatch shape

`componentless_task` — project-scoped. Surfaces from the requirement
graph as `personas_complete` (id 13, `validation_type: :manual`),
gated by `project_setup` (id 1). The story-graph `three_amigos_complete`
node depends on personas existing for the story.

## Out of scope

- The task does not write user stories. Stories come from
  `story_interview`; this task links existing personas to them.
- The task does not implement personas in code. The output is research
  artifacts (markdown + DB record), not application code.
- The task does not invent sources. If web search returns no useful
  data, the agent asks the PM for source leads — never fabricates.

## Failure modes the agent should avoid

- Producing a low-evidence persona when the PM gives a one-liner.
  Push back with targeted follow-up questions; end the session if
  refused.
- Inventing claims, sources, or quotes to fill required sections.
- Skipping `link_persona_to_story` — a research artifact without
  story linkage doesn't satisfy the requirement.
- Reusing a name/slug that already exists on the project without
  checking — `list_personas` first.
- Calling `evaluate_task` before all five artifacts (DB record,
  summary.md, sources.md, link) exist.

## Resources

Required input:
- The active project — needs `active_project_id` on the scope.
- At least one story on the project — needed for
  `link_persona_to_story`.
- The PM in conversation. This is a human-in-the-loop task.

Required reading (framework persona knowledge — `priv/knowledge/persona_research/`):
- `workflow.md` — the five-step session sequencer pointing at the
  topic files below.
- `README.md` — workflow order, guardrails, evidence footer.
- `overview.md` — persona types, Cooper roles, Goodwin goal types.
- `pm_intake.md` — 15-question intake bank + artifact checklist.
- `primary_research.md` — fresh user interview planning.
- `secondary_research.md` — online mining (Reddit, G2, HN, LinkedIn).
- `jtbd.md` — Jobs-to-Be-Done framework.
- `synthesis.md` — raw data → persona transform.
- `templates.md` — persona fields, one-page layout, deliverable set.
- `pitfalls.md` — anti-patterns, bias countermeasures.

Produced:
- DB persona record via `create_persona`.
- `.code_my_spec/personas/<slug>/summary.md` — structured markdown.
- `.code_my_spec/personas/<slug>/sources.md` — citation list.
- Persona ↔ story link via `link_persona_to_story`.

## Tools

Task-specific MCP tools:

- **`list_personas`** — enumerate existing project personas (check for
  reuse before researching duplicates).
- **`get_persona`** by `slug` or `id` — fetch a full record.
- **`add_persona` / `create_persona`** — write the DB record.
- **`link_persona_to_story`** — required for the done signal.
- **`evaluate_task`** — manual validation trigger when conditions met.

Built-ins (Read, Write, WebSearch / WebFetch) handle the research and
file writes.

## Dependencies

- CodeMySpec.Requirements.CheckerResult
- CodeMySpec.Requirements.PersonasChecker
