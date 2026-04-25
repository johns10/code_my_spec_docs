# Persona Research — Questions

## Resolved: Does the agent have web search / research tooling?

Yes. Web search and research tooling are primary sources. The agent also accesses the embedded knowledge base at `priv/knowledge/person_research` via the knowledge MCP server.

## Resolved: What happens when evidence is thin?

The agent does not produce thin personas. It challenges the PM for more context and sources, and keeps the conversation open until signal is adequate.

## Resolved: Is persona↔story many-to-many explicit or implicit?

Explicit — dedicated `persona_stories` join table.

## Resolved: Is the persona library scoped to a project or an account?

Account-scoped. Reusable across every project in the account; not visible across accounts.

## Resolved: Where do the research artifacts land?

`.code_my_spec/personas/<slug>/`, written by the agent during the research task. Two files: `summary.md` and `sources.md`.

## Resolved: Markdown vs DB blob for research text?

Markdown on disk, thin DB record. DB holds identity + metadata + story links; disk holds research text (embedded by the pipeline).

## Resolved: Where does persona research sit in the workflow?

On the requirement graph, in the same phase as ADRs and architecture. Not a project-setup gate. Dispatched via the stop hook when an unsatisfied persona research requirement surfaces through `get_next_requirement`.

## Resolved: What does the agent task's evaluate check?

The `personas` row, `summary.md`, and `sources.md` — all three together. Missing any returns invalid with specifics (which persona, which artifact).

## Resolved: Should `summary.md` be structured?

Yes. Register a `persona_summary` document type with `CodeMySpec.Documents` and validate required sections on `evaluate/2`. Mostly a good idea when you want to guarantee fields are present rather than hoping the agent writes them.

## Resolved: Stop hook fidelity

Not a blocker. Delegate checker returns a markdown-formatted detail string. The existing hook path already carries that through — same pattern as `issues_triaged` / `issues_resolved` in `project_graph`. If structured data is wanted later, that's polish, not a prerequisite.

## Resolved: How does a persona requirement get added to the graph?

Single `personas_complete` node on `project_graph`, parallel to `technical_strategy`, prereq `[project_setup]`. The delegate iterates over personas linked to the project — no per-persona graph nodes. "Zero personas" = unsatisfied node → task dispatched.

## Resolved: Required sections for `persona_summary`

Required: Role, Goals, Pain Points, Context, Decision Drivers, Evidence. Optional: Jobs to Be Done, Quotes, Motivations, Behaviors, Anti-Patterns. Closed to additional sections.

## Open: Slug generation rule

Manual (PM supplies) or derived (from persona name)? Collision handling? Affects folder path and DB unique constraint. Small enough to resolve at impl time.

## Deferred: Does updating a persona auto-refresh the research markdown?

Updating research is a separate flow, probably a slash command later. Out of scope for this story.
