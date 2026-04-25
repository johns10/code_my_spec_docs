# Persona Research — Rules

**Story (560):** As a product manager, I want to run a persona research process with an agent to build a reusable persona library for my product.

**Persona for this story:** PM / Founder. Scope is limited to PM and solo-founder; founder is treated as a PM who also writes code. Engineer-as-PM is out of scope.

---

## Rule: Persona research is a graph requirement, not a setup gate

Persona research sits on the project's requirement graph as a single `personas_complete` node in `project_graph`, parallel to `technical_strategy`. Prerequisite is `project_setup` only. It is not itself a prereq to architecture or tech strategy — those remain independent. Satisfying the node means ≥1 persona on the project with record + both markdown files.

## Rule: Stop hook dispatches the research task

The `personas_complete` node uses `check_type: :delegate` pointing at a `PersonasChecker.complete?/1` function. When evaluation fails, the checker returns a markdown-formatted detail string listing each failing persona and its specific missing artifacts. That string flows through the existing stop hook path into the next turn's feedback — same mechanism as `issues_triaged` / `issues_resolved`. No separate trigger or hook rework.

## Rule: Conversational input from the PM

The session is a dialogue. The PM brings whatever context they have — notes, hypotheses, nothing at all. The agent asks structured questions. The PM answers. The agent does not start writing until the conversation produces enough signal to research against.

## Rule: Agent-led research with real tooling

The agent uses three primary sources: web search / research tooling, the embedded knowledge base at `priv/knowledge/persona_research/` (accessed via the knowledge MCP server), and any prior personas in the account. Research is not a fallback — it is the main source of content.

The knowledge base is the agent's playbook. The task prompt should name the key files by name: `overview.md` (what a persona is, which type to build), `pm_intake.md` (the intake checklist and 15-question bank for the PM conversation), `primary_research.md` (planning fresh user interviews), and `README.md` (the canonical workflow order and guardrails — triangulate, verbatim wins, evidence footer).

## Rule: No thin personas — agent challenges the PM

The agent does not produce a low-evidence persona with a warning. If evidence is thin, the agent challenges the PM for more context, presses for sources, and keeps the conversation open until signal is adequate. Thin in, nothing out.

## Rule: Evaluate requires record and both files together, per persona

The node's delegate checker iterates over every persona linked to the project. A persona is complete when its `personas` row, `.code_my_spec/personas/<slug>/summary.md`, and `.code_my_spec/personas/<slug>/sources.md` all exist. The checker returns `:ok` when every persona is complete, otherwise an invalid result listing each incomplete persona with its specific missing artifacts.

## Rule: Research artifacts are exactly two markdown files

Each persona folder at `.code_my_spec/personas/<slug>/` contains exactly two files:

- `summary.md` — structured document registered as a `persona_summary` type with `CodeMySpec.Documents`
- `sources.md` — link list with URL, title, and access date per entry

No other files. Long-form research stays on disk and is indexed by the embedding pipeline. The DB holds identity, metadata, and story links — not research text.

## Rule: `persona_summary` required sections

Registered with `CodeMySpec.Documents.Registry` with these required sections:

- **Role** — title, responsibilities, decision scope
- **Goals** — outcomes the persona is trying to achieve
- **Pain Points** — frustrations and escape motives
- **Context** — environment, tools, workflow, constraints
- **Decision Drivers** — what gets them to adopt / buy / switch
- **Evidence** — interviews, reviews, analytics cohorts backing the claims

Optional sections: **Jobs to Be Done**, **Quotes**, **Motivations**, **Behaviors**, **Anti-Patterns**. `allowed_additional_sections` is closed — no free-form additions.

## Rule: Personas are account-scoped

Personas belong to an account, not to a single project. Any project within the account can link to any persona in the account. Personas are not visible across account boundaries.

## Rule: Personas link to stories via a many-to-many join

A dedicated `persona_stories` join table links personas to stories. One persona links to many stories; one story references many personas. Cross-account links are rejected.

---

## Session notes

**Storage split.** DB holds identity + metadata + story links. Disk holds research text at `.code_my_spec/personas/<slug>/`. The embedding pipeline indexes the on-disk markdown. Matches the existing story/knowledge pattern.

**Why structured `summary.md`.** `CodeMySpec.Documents.create_dynamic_document/2` validates required/optional sections and H1 against a registered type. Registering `persona_summary` gives real structural guarantees (role, goals, pain points, etc. all present) rather than "agent wrote some text".

**Updating persona research is out of scope** for this story — probably a slash command later. This story covers first-time creation only.

**Agent task shape** mirrors `lib/code_my_spec/agent_tasks/write_bdd_specs.ex`: `command/2` builds a prompt with project/account context, PM guidance, research-tool instructions, and expected output paths. `evaluate/2` checks the record + both files, returning per-artifact specifics when invalid.
