# QA Brief: Story 810 — Orchestrator dispatches follow-ups to live subagents by id

## Tool

MCP tool calls (`mcp__plugin_codemyspec_local__get_next_requirement`, `mcp__plugin_codemyspec_local__list_session_subagents`) and curl for the hook endpoints (`/api/hooks/session-start`, `/api/hooks/subagent-start`).

## Auth

Local endpoints (port 4004) require no user auth — `LocalOnly` accepts loopback IP directly. Pass `X-Working-Dir` header pointing at the sandbox project path for `WorkingDirScope` resolution.

Working dir for QA Fixture Project (sandbox): `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`

MCP tool calls go through `mcp__plugin_codemyspec_local__*` — the agent's own MCP client handles session and scope automatically (it resolves scope from the working directory the local server is pinned to).

## Seeds

Run the local CLI seed to ensure the QA Fixture Project exists in the SQLite DB:

```
MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs
```

No additional story-specific seeds are needed — the hook endpoints (`session-start`, `subagent-start`) are used inline during the test to register sessions and sub-agents.

The QA Fixture Project must have a story with `qa_complete` as the next actionable requirement (all prereqs through `bdd_specs_passing` satisfied). This is the state of the working project (CodeMySpec itself) when `get_next_requirement` is called against the real working dir.

## What To Test

### Scenario 1: SendMessage directive when live QA sub-agent is registered (criterion 6529)

- POST `/api/hooks/session-start` with a unique `session_id` against port 4004, `X-Working-Dir` header pointing at the project working dir
- POST `/api/hooks/subagent-start` with same `session_id`, `agent_id: "qa-live-001"`, `agent_name: "qa"`
- Call `mcp__plugin_codemyspec_local__get_next_requirement`
- Assert response text contains `SendMessage`
- Assert response text contains the agent_id `qa-live-001`
- Assert response text does NOT match `Spawn a @qa sub-agent` (fresh spawn instruction suppressed when live agent exists)

### Scenario 2: list_session_subagents returns agent_id and role for recovery (criterion 6530)

- POST `/api/hooks/session-start` with a new unique `session_id`
- POST `/api/hooks/subagent-start` with `agent_id: "qa-recover-001"`, `agent_name: "qa"`
- Call `mcp__plugin_codemyspec_local__list_session_subagents` with the `session_id`
- Assert response contains `qa-recover-001`
- Assert response matches `qa` (role identifier)

### Scenario 3: Role-keyed registry — two sub-agents surfaced distinctly (criterion 6531)

- POST `/api/hooks/session-start` with a new unique `session_id`
- POST `/api/hooks/subagent-start` twice: `agent_id: "qa-role-001"` / `agent_name: "qa"` and `agent_id: "coder-role-001"` / `agent_name: "code-writer"`
- Call `mcp__plugin_codemyspec_local__list_session_subagents` with the `session_id`
- Assert response contains `qa-role-001`
- Assert response contains `coder-role-001`
- Assert response matches `qa` (role label)
- Assert response matches `code-writer` or `code_writer` (role label)

### Scenario 4: Fresh Agent spawn directive when no live sub-agent registered (criterion 6532)

- POST `/api/hooks/session-start` with a new unique `session_id` (no subagent-start call)
- Call `mcp__plugin_codemyspec_local__get_next_requirement`
- Assert response contains `Agent` (spawn primitive)
- Assert response does NOT match `SendMessage(to:` (no stale id referenced)

### Scenario 5: dispatch/1 emits role: :qa atom and start_task args (criterion 6533)

- POST `/api/hooks/session-start` with a new unique `session_id` (no subagent-start)
- Call `mcp__plugin_codemyspec_local__get_next_requirement`
- Assert response matches `:qa` (role atom surfaced in directive)
- Assert response contains `start_task`
- Assert response contains `qa_complete`

## Setup Notes

Story 810's surface is the MCP tools `get_next_requirement` and `list_session_subagents` — not a browser page. The behavior under test is the dispatch directive text that the orchestrator receives. The hook endpoints at port 4004 are used to register sessions and sub-agents in-flight during testing.

The `get_next_requirement` tool resolves subagents from the most recent active session for the scope's project. The session must be created via the hook endpoint before calling `get_next_requirement` to ensure the sub-agent registration is visible.

The MCP tool calls use the agent's own session context (working dir = CodeMySpec repo root), which maps to the project in the local SQLite DB. The hook endpoints use `X-Working-Dir` header pointing at the same project.

Since `get_next_requirement` picks the most recent active session, the session_id used in curl calls must correspond to the most recently started session for that project scope. Each test scenario should use a fresh `session_id` and rely on `resolve_active_subagents` picking up the most recent session.

## Result Path

`.code_my_spec/qa/810/result.md`
