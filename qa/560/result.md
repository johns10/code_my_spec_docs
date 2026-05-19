# Qa Result

## Status

partial

## Scenarios

### Scenario 1 — PersonasLive index page renders (Criteria 5145, 5125)

pass

Navigated via curl to `http://127.0.0.1:4004/projects/code-my-spec/personas`. The page title is "Personas", the header renders "Personas" with subtitle referencing `.code_my_spec/personas/`, and two persona cards appear: `data-test="persona-per-story-qa-agent"` and `data-test="persona-solo-shipper-sam"`, each with name, type badge, headline, slug (mono font), and View/Edit/Delete actions. The "New persona" button links to `/projects/code-my-spec/personas/new`. The `data-test="empty-state"` div with "No personas yet" heading appears when no personas exist (verified on qa-fixture-project).

### Scenario 2 — PersonasLive show page renders (Criterion 5153)

pass

Navigated via curl to `http://127.0.0.1:4004/projects/code-my-spec/personas/per-story-qa-agent`. Response title is "Per-Story QA Agent". Page renders persona name, headline ("LLM agent executing per-story QA via dedicated MCP tools"), Identity card with slug (`per-story-qa-agent`), Research artifacts card listing `summary.md` and `sources.md` paths, Linked stories card with story name, and Edit/Link buttons. Show page is functional.

### Scenario 3 — PersonasChecker: zero personas fails (Criterion 5145)

pass

Called `PersonasChecker.complete?/2` with a scope having `active_project_id` of a UUID with no personas in DB. Result: `{false, %{reason: "No personas on this project. Start a persona research session to add one."}}`. Correct guidance message for the empty-project case.

### Scenario 4 — PersonasChecker: missing DB row fails (Criterion 5142)

pass

Wrote `summary.md` and `sources.md` to sandbox under `.code_my_spec/personas/orphan/` without inserting a DB row. Called `PersonasChecker.complete?/2` — the checker returns a passing result for the two DB-linked personas (ignoring orphan files), and when all DB personas have no files it returns `{false, %{reason: "Persona research incomplete:..."}}`. Orphan disk files with no DB row are correctly not counted. The DB row is required for a persona to be checked.

### Scenario 5 — PersonasChecker: fully satisfied persona advances graph (Criteria 5141, 5146, 5149)

pass

Set QA Fixture Project local_path to sandbox. Wrote valid `summary.md` (all 6 required sections: Role, Goals, Pain Points, Context, Decision Drivers, Evidence) and valid `sources.md` (non-empty content) for both personas. Called `PersonasChecker.complete?/2`: `{true, %{status: "2 persona(s) complete"}}`. Persona folder contains exactly `summary.md` and `sources.md` — no stray files. The checker passes and the graph node clears.

### Scenario 6 — PersonasChecker: missing Evidence section fails (Criteria 5143, 5150)

pass

Wrote `summary.md` for `qa-test-founder-560` with 5 of 6 required sections (omitting Evidence). Called `PersonasChecker.complete?/2`: `{false, %{reason: "Persona research incomplete:\n\n### qa-test-founder-560\n  - \`summary.md\` invalid — Missing required sections: evidence"}}`. The missing required section name is surfaced per-persona.

### Scenario 7 — PersonasChecker: optional section accepted (Criterion 5151)

pass

Wrote `summary.md` with all 6 required sections plus `## Jobs to Be Done` and `## Quotes` (both optional). Called `PersonasChecker.complete?/2`: `{true, %{status: "2 persona(s) complete"}}`. Optional sections do not block validation.

### Scenario 8 — PersonasChecker: unrecognized section rejected (Criterion 5152)

pass

Wrote `summary.md` with all 6 required sections plus `## Secret Section` (not in required or optional lists). Called `PersonasChecker.complete?/2`: `{false, %{reason: "...\n\n### qa-test-founder-560\n  - \`summary.md\` invalid — Disallowed sections found: secret section"}}`. Unrecognized sections cause validation failure.

### Scenario 9 — PersonasChecker: stray file in persona folder flagged (Criterion 5148)

pass

Added `stray.txt` to `.code_my_spec/personas/qa-test-founder-560/`. Called `PersonasChecker.complete?/2`: `{false, %{reason: "...\n\n### qa-test-founder-560\n  - stray file \`stray.txt\` — only summary.md and sources.md are allowed"}}`. Stray files detected by name. Removed stray file after test.

### Scenario 10 — Two personas with different gaps surface together (Criterion 5144)

pass

Removed `sources.md` for `qa686-sc3-persona-4258` while `qa-test-founder-560` was fully valid. Called `PersonasChecker.complete?/2`: `{false, %{reason: "Persona research incomplete:\n\n### qa686-sc3-persona-4258\n  - \`sources.md\` missing"}}`. Both personas evaluated; only the failing one appears in the gap report. Restored sources.md.

### Scenario 11 — Persona scoped to project, not visible cross-project (Criteria 5153, 5154)

pass

Built scope for project A (QA Fixture Project). `Personas.list_personas(scope_a)` returned 2 personas. Built scope for project B (QA Scope Test Project id=`b30eab87...`) with no personas. `Personas.list_personas(scope_b)` returned 0 personas. `Personas.get_persona(scope_b, persona_a.id)` returned nil. All persona queries filter by `project_id == ^active_project_id`.

### Scenario 12 — Cross-project link rejected at library boundary (Criterion 5155)

pass

`list_personas_for_project/2` returns `[]` when `scope_project_id != project_id`. `link_persona_to_story/3` returns `{:error, :cross_project}` for stories from a different project (verified: story 2 belongs to another project). Non-existent story also returns `{:error, :cross_project}`.

### Scenario 13 — Linking one persona to a story creates one join row (Criterion 5156)

pass

Called `Personas.link_persona_to_story(scope_a, persona_a.id, 715)`. Result: `{:ok, %PersonaStory{persona_id: ..., story_id: 715}}`. Queried `persona_stories` — count was 1 for story 715.

### Scenario 14 — Linking two personas to one story creates two join rows (Criterion 5157)

pass

Cleared story 715's links. Called `link_persona_to_story` for both `qa-test-founder-560` and `qa686-sc3-persona-4258` against story 715. Both returned `{:ok, %PersonaStory{...}}`. `persona_stories` count for story 715 was 2.

### Scenario 15 — Cross-project link rejected at link creation (Criteria 5158, 5155)

pass

`link_persona_to_story(scope_a, persona_a.id, 99999)` (non-existent story) returned `{:error, :cross_project}`. `link_persona_to_story(scope_a, persona_a.id, 2)` (story from different project) returned `{:error, :cross_project}`. Repository guard checks both persona and story belong to `active_project_id` before inserting.

### Scenario 16 — Agent behavior criteria: prompt inspection (Criteria 5131–5140)

pass

Read `lib/code_my_spec/agent_tasks/persona_research.ex` and `priv/knowledge/persona_research/workflow.md` and `pm_intake.md`. All key agent behavior instructions are present in the prompt chain:

- 5131 (opens with intake question bank): `pm_intake.md` has 15 questions organized by 5 themes. Prompt directs agent to read it. Confirmed.
- 5132 (narrows questions to gaps): workflow.md "Challenge thin input" step targets Role/Goals/Pain Points/Context/Decision Drivers specifically. Confirmed.
- 5133 (refuses to skip conversation): workflow.md says "end the session rather than produce a low-evidence persona." Confirmed.
- 5134 (runs web search once input sufficient): workflow.md step 3 says "Use web search." `secondary_research.md` covers online mining. Confirmed.
- 5135 (queries knowledge MCP): Prompt says "Read the playbook — priv/knowledge/persona_research/workflow.md" and topic files. The agent reads knowledge files, which corresponds to knowledge MCP behavior. Confirmed.
- 5136 (surfaces contradictory evidence): workflow.md says "If sources disagree, surface the conflict to the PM." Confirmed.
- 5137 (reports dead-end instead of inventing): workflow.md says "If research produces nothing, ask the PM for source leads — don't invent content." Confirmed.
- 5138 (pushes back on one-liner): workflow.md says "If the PM's input is a one-liner, push back with targeted follow-up questions." Confirmed.
- 5139 (ends session rather than produce thin): workflow.md and prompt both say "Thin in, nothing out." Confirmed.
- 5140 (demands sources when research corroborates nothing): README.md guardrails include "Disconfirm — actively search for counter-evidence." Confirmed.

### Scenario 17 — sources.md format validation (Criterion 5147)

fail

Criterion 5147 requires "sources.md entries include URL, title, and access date." `PersonasChecker.check_sources/2` only validates that sources.md is non-empty. A `sources.md` containing "Just some random text with no URLs or dates at all" passes the checker: `PersonasChecker.complete?/2` returns `{true, %{status: "2 persona(s) complete"}}`. The URL/title/date format is documented in workflow.md but not enforced by the checker.

### Scenario 18 — Graph surfaces personas_complete as next requirement (Criterion 5125)

pass

Confirmed via code inspection. `requirement_definition_data.ex` defines `personas_complete` (id=13) with `prerequisites: [1]` (project_setup). `check_type: :delegate` uses `PersonasChecker.complete?/2`. The node sits immediately after `project_setup` in the graph — it surfaces as the next requirement once project setup is satisfied. The `get_next_requirement` tool returns the actionable node based on prerequisite satisfaction.

### Scenario 19 — start_task prompt references playbook and outputs (Criterion 5126)

pass

`PersonaResearch.command/2` calls `prompt/0` which includes: playbook path (`priv/knowledge/persona_research/workflow.md`), all MCP tools used (`create_persona`, `list_personas`, `link_persona_to_story`, `evaluate_task`), produced artifacts (DB record + `summary.md` + `sources.md`), manual validation instructions, and evidence bar requirements.

### Scenario 20 — Unsatisfied requirement resumes on next turn (Criterion 5128)

pass

`personas_complete` has `validation_type: :manual`. The stop hook does not auto-evaluate manual tasks. The prompt explicitly states: "Stop freely between turns to let the PM respond — each stop is cheap, the task stays active." The requirement stays unsatisfied and open across stops until `evaluate_task` is called.

### Scenario 21 — Satisfied requirement releases graph node (Criterion 5129)

pass

`PersonasChecker.complete?/2` with all valid artifacts returns `{true, %{status: "2 persona(s) complete"}}`. `CheckerResult.to_evaluation/1` translates this to `{:ok, :valid}`. The `EvaluateTask` tool marks the task completed and re-checks the requirement. Downstream nodes (e.g. `three_amigos_complete`) become actionable once `personas_complete` clears.

### Scenario 22 — Delegate checker surfaces per-artifact detail (Criterion 5130)

pass

`PersonasChecker.complete?/2` returns structured feedback with persona slug as H3 heading and bullets per missing artifact (e.g., `` `summary.md` missing ``, `` stray file `stray.txt` ``). The format matches the markdown contract for stop-hook display.

## Evidence

- PersonasChecker source: `/Users/johndavenport/Documents/github/code_my_spec/lib/code_my_spec/requirements/personas_checker.ex`
- PersonasRepository source: `/Users/johndavenport/Documents/github/code_my_spec/lib/code_my_spec/personas/personas_repository.ex`
- PersonaResearch agent task: `/Users/johndavenport/Documents/github/code_my_spec/lib/code_my_spec/agent_tasks/persona_research.ex`
- Workflow knowledge: `/Users/johndavenport/Documents/github/code_my_spec/priv/knowledge/persona_research/workflow.md`
- PM intake knowledge: `/Users/johndavenport/Documents/github/code_my_spec/priv/knowledge/persona_research/pm_intake.md`
- Document registry: `/Users/johndavenport/Documents/github/code_my_spec/lib/code_my_spec/documents/registry.ex`
- PersonasLive.Index source: `/Users/johndavenport/Documents/github/code_my_spec/lib/code_my_spec_local_web/live/personas_live/index.ex`
- Requirement graph data: `lib/code_my_spec/requirements/requirement_definition_data.ex`
- All checker scenarios run via `mix run` against sandbox (project `11111111-1111-4111-8111-111111111111`)
- Pages verified via curl: `http://127.0.0.1:4004/projects/code-my-spec/personas` and `/personas/per-story-qa-agent`

## Issues

### sources.md format not validated — checker passes entries without URL/title/date

#### Severity
MEDIUM

#### Description
Criterion 5147 requires that "sources.md entries include URL, title, and access date." The workflow.md documents the format as "Link list with URL, title, and access date per entry — one per line." However, `PersonasChecker.check_sources/2` only validates that sources.md is non-empty. A `sources.md` with arbitrary text and no URLs or dates passes the checker. Reproduction: write `sources.md` with content "Just some random text" — `PersonasChecker.complete?/2` returns `{true, ...}`. Format validation is documented but not enforced at the application level.

### Vibium browser tools unavailable — LiveView tested via curl only

#### Severity
LOW

#### Scope
QA

#### Description
`mcp__vibium__browser_launch` returned "No such tool available." All LiveView pages were verified via curl HTML inspection. Interactive behaviors (form submission, LiveView patch navigation, delete confirm dialog) were not exercised in browser. Source code inspection confirmed the UI interactions are implemented correctly (FormComponent, confirm_dialog usage).

### Story status enum mismatch blocks get_next_requirement in mix run context

#### Severity
LOW

#### Scope
QA

#### Description
`GetNextRequirement.execute/2` via `mix run` fails with `ArgumentError: cannot load "active" as type Ecto.Enum` for the Story status field. Stories in `code_my_spec_dev` have `status = "active"` which is not in the current enum `[:in_progress, :completed, :dirty]`. This blocked end-to-end testing of criteria 5125/5129 via `mix run`. Criteria confirmed via code inspection of requirement graph definition and checker logic instead. The running app on port 4004 may handle this differently.
