# Persona Research — Examples

## Rule: Persona research is a graph requirement, not a setup gate

- PM finishes ADRs and architecture, graph surfaces an unsatisfied persona research requirement as the next actionable item
- Agent calls `get_next_requirement` on a project mid-design and receives a persona research task

## Rule: Stop hook dispatches the research task

- Agent stops mid-turn with the requirement still unsatisfied, stop hook evaluates, next turn picks up the same persona research task
- Agent completes all three artifacts for a persona, stop hook evaluates clean, next `get_next_requirement` returns a different requirement
- Agent stops with two persona requirements unsatisfied, next turn resumes on the higher-priority one

## Rule: Conversational input from the PM

- PM launches the session with zero prior notes, agent produces structured opening questions
- PM pastes partial notes into the session, agent reads them and asks only about gaps
- PM tells the agent to skip questions and just write something, agent refuses and asks questions instead

## Rule: Agent-led research with real tooling

- Agent finishes the conversation with enough signal, runs a web search and cites findings in `sources.md`
- Agent queries `priv/knowledge/person_research` via the knowledge MCP server, pulls relevant internal material into the summary
- Agent's web search returns no useful results, agent falls back to asking the PM for source leads instead of inventing content
- Agent finds contradictory evidence across sources, surfaces the conflict to the PM before writing the summary

## Rule: No thin personas — agent challenges the PM

- PM gives one-line input, agent pushes back with targeted follow-up questions
- PM refuses to provide additional context, agent ends the session without writing a persona rather than producing a low-evidence one
- Agent's research plus PM input together fall short of the evidence bar, agent challenges the PM for specific sources

## Rule: Evaluate requires record and both files together, per persona

- One persona on the project with record + `summary.md` + `sources.md`, checker returns valid and the graph node clears
- Persona has markdown files but no DB row, checker returns invalid naming the missing record
- Persona has DB row + `summary.md` but no `sources.md`, checker returns invalid naming the missing file
- Two personas incomplete with different gaps, checker returns invalid listing each persona with its specific missing artifacts
- Zero personas linked to the project, checker returns invalid and the stop-hook feedback tells the next turn to start a persona

## Rule: Research artifacts are exactly two markdown files

- `summary.md` parses as the registered `persona_summary` document type with all required sections present
- `sources.md` contains every URL the agent consulted with title and access date, one entry per line
- Agent writes a stray third file in the persona folder, checker flags it

## Rule: `persona_summary` required sections

- `summary.md` has Role, Goals, Pain Points, Context, Decision Drivers, and Evidence — all required sections present, Documents validation passes
- `summary.md` is missing the Evidence section, Documents validation fails naming "Evidence"
- `summary.md` includes the optional Jobs to Be Done section in addition to all required ones, validation passes
- Agent adds an unrecognized section like "Demographics" that is neither required nor optional, validation fails naming the disallowed section

## Rule: Personas are account-scoped

- PM in account A creates a persona, that persona is available to every project in account A
- PM opens a second project in the same account and links an existing persona from the account library
- PM attempts to link a persona from a different account, request is rejected

## Rule: Personas link to stories via a many-to-many join

- PM links one persona to a new story, a single `persona_stories` row is created
- PM links two personas to one story, two `persona_stories` rows are created
- PM attempts to link a persona from account A to a story in account B, harness rejects the link
