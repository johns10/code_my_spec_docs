# Qa Story Brief

## Tool

web (Vibium MCP browser tools for LiveView pages on port 4004) and MCP tools (`mcp__plugin_codemyspec_local__*`) for agent-surface criteria

## Auth

Local app (port 4004): no auth required — `LocalOnly` accepts loopback IPs directly. Navigate to `http://127.0.0.1:4004/projects/code-my-spec/personas`.

Hosted app (port 4000): Use password login at `http://127.0.0.1:4000/users/log-in` with credentials `qa@codemyspec.local` / `qa-password-123!`. Use the password form (second form on the page), not the magic-link form. Scope to `form[action="/users/log-in"] input[name='user[email]']`.

MCP tool surface: Use `mcp__plugin_codemyspec_local__*` tools directly — they connect to the local MCP server on port 4004 and handle SSE transport automatically.

## Seeds

Run the server QA seed script first:

```
mix run priv/repo/qa_seeds.exs
```

This creates:
- User: `qa@codemyspec.local` / `qa-password-123!`
- Project id: `11111111-1111-4111-8111-111111111111` (`QA Fixture Project`)
- Local path: `/Users/johndavenport/Documents/github/code_my_spec`

No additional seed scripts are needed — personas are created during test execution via MCP tools.

## Setup Notes

This story covers three distinct surfaces:

1. **MCP tool surface** — `create_persona`, `list_personas`, `link_persona_to_story`, `get_next_requirement`, `evaluate_task` and the `PersonasChecker` logic. These are tested via `mcp__plugin_codemyspec_local__*` tool calls.
2. **LiveView UI** (port 4004) — `PersonasLive.Index` and `PersonasLive.Show` pages at `/projects/:project_name/personas`. Tested with Vibium.
3. **Agent behavior** (criteria 5131–5140) — These test the AI agent's conversational behavior during persona research sessions. These cannot be directly exercised by a QA agent making tool calls; the behavior is specified in the persona research playbook and validated by reading the `AgentTasks.PersonaResearch` prompt. These criteria are DOCS-scope verifiable only at the prompt level.

The QA sandbox at `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` should be used for MCP mutation tests to avoid polluting the working project.

Agent behavior criteria (5131–5140) rely on LLM reasoning and cannot be automatically driven from a QA agent. These will be assessed by reading the `persona_research` task prompt and reporting on whether the instructions are in place.

## What To Test

### Scenario 1: PersonasLive index page renders for a project (Criteria 5145, 5125)
- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/personas`
- Verify the page loads with a "Personas" heading
- With no personas, verify empty state renders with "No personas yet" text
- Screenshot: `4004_personas_empty.png`

### Scenario 2: Create persona via UI (basic CRUD)
- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/personas/new`
- Fill in slug, name, and headline fields in the form
- Submit the form and verify the persona appears in the list
- Screenshot: `4004_persona_form.png`, `4004_persona_created.png`

### Scenario 3: PersonasLive show page renders
- Navigate to the created persona's show page (`/projects/code-my-spec/personas/<slug>`)
- Verify persona details are displayed
- Screenshot: `4004_persona_show.png`

### Scenario 4: MCP create_persona via sandbox project (Criterion 5153 — persona scoped to project)
- Use `mcp__plugin_codemyspec_local__start_task` to probe the MCP surface in the sandbox
- Create a persona via `create_persona` MCP tool
- Switch scope to a different project, call `list_personas` and verify the persona does NOT appear
- Expected: persona is not visible across projects (project-scoped)

### Scenario 5: PersonasChecker — zero personas fails evaluation (Criterion 5145, 5142)
- Use `mcp__plugin_codemyspec_local__evaluate_task` on a `personas_complete` task with no personas
- Expected: response contains "Needs work" / "no personas" / "incomplete" feedback

### Scenario 6: PersonasChecker — missing DB row fails evaluation (Criterion 5142)
- Persona files exist on disk but no DB row is linked to the project
- Evaluate the task and confirm blocking feedback for "no linked persona"

### Scenario 7: PersonasChecker — fully satisfied persona advances graph (Criterion 5141, 5146, 5149)
- Create a persona via MCP
- Write `summary.md` with all required sections (Role, Goals, Pain Points, Context, Decision Drivers, Evidence)
- Write `sources.md` with at least one valid source entry
- Call evaluate and confirm pass
- Call `get_next_requirement` and verify `personas_complete` is no longer surfaced

### Scenario 8: PersonasChecker — missing summary.md fails evaluation (Criterion 5143, 5150)
- Create a persona in DB, write only `sources.md`
- Evaluate and confirm `summary.md missing` appears in feedback

### Scenario 9: PersonasChecker — stray file in persona folder is flagged (Criterion 5148)
- Create a persona, write both `summary.md` and `sources.md`, then add a stray file
- Evaluate and confirm the stray file is called out in feedback

### Scenario 10: PersonasChecker — missing required section fails validation (Criterion 5150)
- Write a `summary.md` missing the `Evidence` section
- Evaluate and confirm failure feedback names the missing section

### Scenario 11: PersonasChecker — optional section accepted (Criterion 5151)
- Write a `summary.md` with all required sections plus an optional section
- Evaluate and confirm it passes

### Scenario 12: PersonasChecker — unrecognized section rejected (Criterion 5152)
- Write a `summary.md` with an unrecognized section name
- Evaluate and confirm feedback flags the unrecognized section

### Scenario 13: Link persona to story — one join row (Criterion 5156)
- Create a persona and a story via MCP tools
- Call `link_persona_to_story` with the persona and story IDs
- Verify response confirms the link with persona_id and story_id

### Scenario 14: Link two personas to one story — two join rows (Criterion 5157)
- Create two personas, create a story
- Link both personas to the story
- Verify both links are confirmed in responses

### Scenario 15: Cross-project link rejected at link creation (Criterion 5158)
- Create a persona on project A
- Create a story on project B
- Attempt `link_persona_to_story` with the cross-project story_id
- Expected: error response indicating cross-project rejection

### Scenario 16: Agent behavior criteria — prompt inspection (Criteria 5131–5140)
- Read `lib/code_my_spec/agent_tasks/persona_research.ex` to confirm:
  - Intake question bank is present for PM with no notes
  - Instructions to narrow questions when partial notes are given
  - Instructions to refuse to skip the conversation
  - Instructions to run web search once input is sufficient
  - Instructions to query knowledge MCP
  - Instructions to surface contradictory evidence
  - Instructions to report dead-ends rather than invent content
  - Instructions to push back on thin descriptions
  - Instructions to end the session rather than produce thin personas
  - Instructions to demand sources when research corroborates nothing

### Scenario 17: sources.md entries include URL, title, and access date (Criterion 5147)
- Confirm the `PersonasChecker` validates sources.md format
- Write a sources.md missing the access date and verify failure feedback

## Result Path

`.code_my_spec/qa/560/result.md`
