# Qa Story Brief — Story 1007: An agent is told only about work for its own role

## Tool

`run_script` (the Lua MCP sandbox) plus the top-level `start_analysis` tool. No browser needed — this story's testable surface is entirely MCP tool calls (`:mcp`/`:hook` pipeline), not a LiveView page. Vibium MCP was unavailable this session (connection closed) and would not have added coverage here regardless: no criterion names a `:browser`-pipeline route.

## Auth

None required. `run_script` and `start_analysis` authenticate as the calling Claude Code session against the live dev harness on this working copy (`9f77b922-9810-4b49-931d-b073012bc317`, `.claude/worktrees/phx-new-generator`) — no login flow, no token minting.

## Seeds

None. This story's surface is agent-to-agent notification routing on the **real, live project** (CodeMySpec's own dev project — there are 8 real running agents across several worktrees at the time of writing). Do **not** use `qa_sandbox` or manufacture throwaway stories/personas for this one: the routing this story controls (`CodeMySpec.Agents.wake_roles/3`, `wake_project_roles/2`) reads real `agents` rows and real `Requirements`/graph state, and the sandbox project has no agents of its own to route between.

Two real agents already share this working copy and are useful fixtures as-is:
- coding — agent id `880c7713-d9a4-48ee-bbf9-7472960ea9a8`
- qa — agent id `61c87cd5-df77-4972-a60b-39583e2a9348`

`run_script({ script = "return list_agents({})" })` re-lists current ids/roles/working copies if they've changed since this brief was written.

## What To Test

Static verification first (fast, safe, and this story's mechanism has no admin toggle to flip live):

- Read `lib/code_my_spec/agents.ex`: `wake_roles/3`, `wake_project_roles/2`, `wakeable?/3`, `project_wakeable?/2`, `StopDecision.wake/2` (menu rendered from `agent.role`), and `@copy_roles` / `role_of/1` (confirms `:devops` is not a role — defaults to `:main`).
- Read `lib/code_my_spec/mcp_servers/tasks/tools/start_analysis.ex` and `lib/code_my_spec/mcp_servers/issues/tools/{create_issue,list_issues,get_issue}.ex` — confirm none gate on `agent.role`, only on `Validators.validate_local_scope` (tenancy, not role).

Then live, against the tools above:

- **Criterion 3202** (any agent may run a spex): call `start_analysis({ source = "spex" })` directly. Expect an immediate "Started spex…" reply, no role-based refusal text.
- **Criterion 3203/3226, read half** (looking is allowed): `run_script` → `list_issues({})` (expect the real project's issue list, no refusal) and `get_issue({ issue_id = "<any real 8-char prefix from the list>" })` (expect full detail). Grep the response text for `role|not your|qa agent|permission|not allowed` — none should appear.
- **Criterion 3199/3200** (role-scoped push routing): there is no MCP tool that forces "a project whose only remaining work is QA on one story" or "devops work appears" on demand — the spex build that premise with in-process fixtures (`FullSatisfactionFixtures.apply_up_to_analysis/1` + `apply_qa_readiness_transition/1`, `Fixtures.enable_devops/1`) that have no live equivalent, and manufacturing it against the real project would mean mutating real graph/story state shared with several other active agents. Treat as covered by the static review above plus this observational check:
  - `read_agent_conversation({ agent_id = "880c7713-…", limit = 15 })` and the same for `61c87cd5-…` (qa) — confirm each agent's most recent "Work of your kind is available" operator message names only tasks/requirements belonging to its own role (coding sees its own `bdd_specs_exist`/etc. tasks; qa sees its own `qa_complete` tasks). This is corroborating, not a controlled before/after proof — say so plainly in the result, don't overclaim it.
- File `bdbb663d-6ba0-455f-a83d-16591952754d` already documents the 3199/3200 live-reproduction gap for future QA passes on this story — read it rather than re-deriving the same conclusion from scratch.

## Result Path

Findings via `create_issue` as they're found; final outcome via `submit_qa_result(task_id: "79287146-d38f-49bc-9184-c2448b19126e", …)`. No result.md — the DB attempt is canonical.

## Setup Notes

- This is the **live production CodeMySpec project**, not a sandbox. Several real agents are actively working and some are blocked on real pending questions to the human operator — do not message, restart, or stop any of them as part of this story's QA. All testing here is read-only (`list_issues`, `get_issue`, `read_agent_conversation`) plus one idempotent, already-sanctioned action (`start_analysis`), which any agent may legitimately call at any time regardless of this test.
- `run_script`/`run_browser_script` expose ~120 tools including `create_issue`, `list_issues`, `get_issue`, `submit_qa_result`, `list_agent_work`, `read_agent_conversation`. These are **not** separately-typed top-level MCP tools in this session — `tool_docs({})` lists the full scriptable catalog and the (short) list of tools that must be called directly instead of from a script.
- App URL for reference (not needed for this story): `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.
