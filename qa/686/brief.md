# Qa Story Brief

Story 686 — AI-Assisted Story Management. Tests the agent-facing MCP surface for
story/persona/Three Amigos/issue triage tooling via the local MCP server.

## Tool

MCP client tools (`mcp__plugin_codemyspec_local__*`) for all story, persona, BDD rules,
and issue tool tests. Vibium browser for verifying results in the local web UI
(port 4003). curl for health-check and seed verification only.

## Auth

Local server (port 4003) — no user auth required. `Plugs.LocalOnly` accepts loopback.
MCP tools in this session are pre-authenticated via the session's X-Working-Dir context.

For browser verification (Vibium): navigate directly to `http://127.0.0.1:4003/projects/code-my-spec/stories` — no login needed.

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

Seeds create/verify: qa@codemyspec.local, account `code-my-spec`, project
`QA Fixture Project` (id `11111111-1111-4111-8111-111111111111`, local_path = PWD).

Note: the QA seed script reports "stories: skipped (table not found)" for the Postgres
DB, which is expected — stories moved to the local SQLite CLI deployment. The MCP tools
under test use the running local server (port 4003) scoped to the working directory.

## What To Test

All scenarios exercise MCP tools directly via `mcp__plugin_codemyspec_local__*`.
After each MCP call, optionally navigate the local web UI (port 4003) to confirm
the UI reflects the change. The QA project slug is `code-my-spec`.

### SC-1 — Agent creates a story (criterion 5907)
- Call `start_task` with requirement_name "create_story" (or use the direct MCP tool)
- Actually: call a story MCP operation via the available plugin tools
- Verify the story appears in the local web stories list at
  `http://127.0.0.1:4003/projects/code-my-spec/stories`
- Expected: new story title visible in the list

### SC-2 — Agent updates a story (criterion 5908)
- Create a story, then update its title and description
- Verify changes reflected in a subsequent get operation
- Expected: updated title and description visible, old title absent

### SC-3 — Agent deletes a story with cascade (criterion 5909)
- Create a story with a linked persona, a rule, and a linked issue
- Delete the story
- Verify: story absent from list, rule removed, issue survives with story_id cleared

### SC-4 — Agent adds a criterion (criterion 5910)
- Create a story, then add a criterion to it
- Verify the criterion appears in get_story output

### SC-5 — Agent creates and applies a tag (criterion 5912)
- Create a story, apply a new tag via tag_stories (tag is auto-created)
- Verify tag appears in list_project_tags and on the story via get_story

### SC-6 — Agent starts a story interview session (criterion 5913)
- Call start_story_interview
- Verify response contains "Product Manager" and "bare user stories" instruction

### SC-7 — Agent starts a Three Amigos session (criterion 5914)
- Create a story, call start_three_amigos_session with that story_id
- Verify response contains "Three Amigos", references the story title, mentions
  add_rule/add_scenario/persona tools

### SC-8 — Agent runs full Three Amigos workflow (criterion 5915)
- Create a story, create a persona, link persona to story, add_rule, add_scenario,
  add_question (park a question)
- Verify list_rules, list_questions, get_story_gherkin all reflect the entries

### SC-9 — Accept issue as requirements change (criterion 5916)
- Create an issue, create a story, accept the issue as requirements_change linked
  to the story
- Verify get_issue shows accepted status and story link

### SC-10 — Accept issue as bug without story link (criterion 5917)
- Create an issue, accept it as bug with no story_id
- Verify get_issue shows accepted/bug status with no story reference

### SC-11 — Dismiss an issue with reason (criterion 5918)
- Create an issue, dismiss it with a reason
- Verify get_issue shows dismissed status and the reason recorded

## Result Path

`.code_my_spec/qa/686/result.md`

## Setup Notes

The stories and related tables (criteria, personas, bdd_rules, questions) were moved
from the hosted Postgres backend to the local SQLite CLI deployment in story 701.
The running local server (port 4003) in dev mode still serves these domains via the
same `StoriesRepository` code backed by `CodeMySpec.Repo`. The QA seed verifies the
project row is in place so the working-dir scope resolves correctly.

All 11 MCP tool groups are registered in `CodeMySpec.McpServers.LocalServer` and
available through the `mcp__plugin_codemyspec_local__*` plugin tools in this session.
