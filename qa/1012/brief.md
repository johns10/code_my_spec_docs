# Qa Story Brief

## Tool

`mcp__plugin_codemyspec_local__run_script` (Lua) calling `list_agent_work({})` and `check_in({})`.

This is the real production surface: `run_script` executes against `CodeMySpec.McpServers.ScriptableTools`, the same MCP component registry mounted on the local harness's `4004/mcp` endpoint (see `lib/code_my_spec/mcp_servers/scriptable_tools.ex:148`, `lib/code_my_spec/mcp_servers/local_server.ex`). `ListAgentWork.execute/2` is the tool the story names as the API (see spex criterion 3270 moduledoc). Calling it via `run_script` is the ergonomic, schema-validated path the QA plan recommends over raw curl where the agent's own MCP client tools reach the surface.

Equivalent raw curl (documented for completeness, not needed since `run_script` reaches the same code path):
```
curl -s -X POST http://localhost:4004/mcp -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -H "X-Harness-Id: $ID" -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"list_agent_work","arguments":{}}}'
```

## Auth

None needed — this session's `run_script` tool is already bound to this project's harness (`X-Harness-Id` resolved automatically by the local MCP client). No login flow involved.

## Seeds

None. Testing was done against the **live, real fleet already running on this CodeMySpec dev project** — not the QA fixture project — because the story's subject (a fleet of registered coding/qa/product/main agents spread across several real working copies, with real tasks, real silences, real tapped-out states, and real working-copy problems) already existed naturally and gave better evidence than a synthetic fixture would. See Setup Notes for why, and for the induction plan used for the states that were not naturally present.

## What To Test

For each criterion, call `list_agent_work({})` via `run_script` and inspect the rendered text against the live fleet (currently 11 registered agents across ~5 working copies of this project). Where the live fleet does not naturally exhibit a state, induce it on a throwaway working copy (`create_working_copy`) and offboard it afterward.

- **3270** — one call must list every agent with named work. ✅ confirmed live: one `list_agent_work` call returned all 11 agents (`main`, `coding`, `product`, `qa` roles) spanning 5 different working copies.
- **3271** — work is named with the story title, not just the requirement id. ✅ confirmed live: coding agent `0067d652` shows `task: code_on_running_copy — "New user reaches a working app state without seeing the account picker"` — both the pipeline step and the actual story title.
- **3272** — idle and broken (toolless) read differently, both with a reason. Idle half ✅ confirmed live (`nothing to do: the graph holds no work for its role`). Broken/toolless half: no naturally-toolless agent in the live fleet; induction risks a shared-harness disruption (see Setup Notes) — verify by source inspection of `AgentWork.toolless?/1` and `WorkRepository` rendering, or induce only with team-lead's go-ahead.
- **3273** — one call spans every working copy of the project, not just the asking checkout. ✅ confirmed live: the single call above already spanned 5 different `working_copy_root`s.
- **3274** — an agent silent a long time with a held task is not reported as "working on X", but the silence is visible. ✅ confirmed live: coding agent `0067d652` has held `code_on_running_copy` since `15:16:57Z` and last said something at `15:19:14Z` (~3h20m of silence as of this check) — the view shows `last said:` (satisfies the positive assertion) and never says "working on"/"currently working on" (satisfies the negative assertion).
- **3275** — the view reports parts (open task, last said, blocked-on, in-flight), never a verdict word (stalled/stuck/dead/healthy/unhealthy). ✅ confirmed live: none of the 11 entries contain any verdict word; all use the four labelled parts.
- **3276** — task-opened and last-said are two distinct, separately-labelled clocks. ✅ confirmed live: agent `0067d652` shows `task opened: 2026-09-12T15:16:57` and `last said: 2026-09-12T15:19:14` — present, labelled, and different.
- **3277** — an agent waiting on an answer shows the question's own text. Not yet exercised live — see Setup Notes (pending confirmation this won't page a live teammate/the user before inducing it).
- **3278** — a tapped-out agent shows the tap-out and no fault language. ✅ confirmed live and unprompted: product agent `780b1159` on this very worktree shows `blocked on: tapped out — it asked to leave the loop and a person has not answered yet`, with none of stalled/stuck/dead/not responding/fault present.
- **3279** — a long silence with an open turn (`in_flight`) is not read as a stall. Not yet exercised — needs a registered agent caught mid-turn; see Setup Notes.
- **3297** — an agent mid-response shows work in flight (the `in flight:` line says something other than "nothing"/"none"/"no turn"). Not yet exercised — same blocker as 3279.
- **3299** — a coding agent's working-copy problems (with detail, not just a count) are shown against it. ✅ confirmed live: QA agent `fdc75092`'s checkout carries 146 real `mix test` failures, printed in full (file, message, stacktrace) against that agent's row.
- **3300** — a clean copy says so, and doesn't inherit another copy's problems. ✅ confirmed live: on the same call, agents on other checkouts (`93bdde5a`, `524295bc`, etc.) show `problems on this copy: none — it is clean` rather than the 146 failures from the dirty copy, and rather than being left blank.

## Result Path

No result.md — findings go through `create_issue` + `submit_qa_result` per the harness's discipline (see task prompt). Screenshots/evidence, if any, live in `.code_my_spec/qa/1012/screenshots/`.

## Setup Notes

**Why the live project instead of the QA fixture project:** the QA fixture project (`11111111-...`) has no registered fleet of its own to observe. This story's subject — several real coding/qa/product/main agents, spread across several real working copies, with real held tasks, real silences, a real tapped-out agent, and real working-copy problems — already existed on the live CodeMySpec dev project this session is part of, and produced far better evidence than a synthetic single-agent fixture would. All calls made were read-only (`list_agent_work`), so this carries none of the mutation risk the QA plan warns about for the sandbox-only rule (that rule is about writing MCP tools — `create_story`, `ask_user_question`, etc. — not about read-only listing tools).

**Remaining induction, gated on a team-lead check-in:**
- 3277 needs a non-main agent to call `ask_user_question`. Per `CodeMySpec.MainAgent.holder_for/2` and `question_raised/2`, this delivers to the project's live main agent (an orchestrator nudge), not directly to the user — but this project's live main agent is a real teammate doing real work, and a stray QA probe question has no expiry/dismiss (tracked precedent: issue `08d4d7bd`, story 896). Flagged to team-lead before firing it.
- 3279/3297 need a registered agent caught with an open `agent_turn_event` (mid-turn). None of the 11 live agents were mid-turn across three snapshots. Plan: stand up a throwaway working copy (`create_working_copy`), give its coding agent a real prompt via `message_agent`, and poll `list_agent_work` in parallel to catch the open turn; offboard afterward.
- 3272's broken/toolless half needs `WorkingCopies.record_machine_tools(scope, [])`, which in production reflects a harness's MCP client going empty — not something to induce live without risking other checkouts on the same machine (a machine-wide fault, per `CodeMySpec.MainAgent.check_machinery/1`'s own docs). Leaning toward reporting this half from source/spex inspection only, flagged as partial, unless team-lead knows a safe lever.
