# QA Story Brief — 961: An agent I am done with stops, and stops costing

## Tool

`mcp__plugin_codemyspec_local__{start_agent,stop_agent,list_agents}` (local MCP, LiveView not applicable)

## Auth

None needed for the local surface — `Plugs.LocalOnly` + the harness id bound
to this Claude Code session already scope every call to this project on the
running dev server (`:4000`) via the local endpoint (`:4004`).

The typed tools `mcp__plugin_codemyspec_local__start_agent`,
`..._stop_agent`, and `..._list_agents` are this QA session's own harness's
MCP tools, and they forward to `CodeMySpec.McpServers.LocalServer`'s
`StartAgent`/`StopAgent`/`ListAgents` — the exact same MCP tool modules the
spex drive (`CodeMySpec.McpServers.Agents.Tools.{StartAgent,StopAgent,ListAgents}`).
No curl setup is required; call them directly.

(The same tools are also reachable externally via
`POST /mcp/harness` on the hosted endpoint with an OAuth bearer +
`X-Project-ID` header, per `.code_my_spec/qa/plan.md`'s Tools Registry — not
needed here since the typed tools already reach the real thing.)

## Seeds

None. No DB fixture is needed — `start_agent` creates its own agent row.
A provider credential must already be connected for the account; this
account already has `openai-codex` connected (confirmed live — `anthropic`
and `zai` are NOT connected and return `:not_connected` cleanly).

## What To Test

- **2880 — Cancelling one we asked for and never saw**: call `start_agent`
  with a connected provider (`openai-codex`). Confirm the agent lands at
  `status: starting` with no OS pid (this is the correct outcome for an
  agent no harness has confirmed — not a defect). Call `stop_agent` on that
  id. Expect a clean success, the agent gone from `list_agents`, and no
  wording about a harness/process being unreachable.
- **2873, 2874, 2877, 2878, 2879, 2881, 2882, 2883, 2884, 2885** — all
  require a *real, signalable OS process group* under a harness that the
  server can actually route a `start_agent`/`stop_agent` call to. Attempting
  this live surfaced a blocking defect (see Setup Notes) that makes every
  one of these unreachable from any external QA surface right now, in any
  environment — not just this one. They remain covered only by spex, which
  bypass the broken transport via `Application.put_env(:code_my_spec,
  :agent_transport, CodeMySpecTest.InProcessAgentTransport)`.
- **2875, 2876** — 2875 is channel-only (`HarnessChannel` `agents_running`
  reconcile), not reachable via MCP tools or a browser; spex-covered.
  2876 (pid survives a failed stop) is partially covered by the 2880 flow in
  the sense that a `:starting` agent's `os_pid` stays `nil` through a
  successful cancel, but the interesting case (a *running* agent's `os_pid`
  surviving a *failed* stop) needs the same real process this environment
  cannot currently produce.

## Result Path

Findings filed via `create_issue` as found; final result recorded via
`submit_qa_result` (task id from `start_task`). No result.md file.

## Setup Notes

**Blocking defect found while trying to exercise the "real process" criteria
(critical, filed as issue `10ed6f60-3bfd-462e-a926-adcfa8cc65ef`):**
`CodeMySpec.Agents.Transport.Harness` (`lib/code_my_spec/agents/transport/harness.ex:16`)
aliases `CodeMySpecWeb.HarnessRegistry` — a module that does not exist
anywhere in the codebase and is never started. `holder/1`'s
`Registry.lookup/2` always raises `ArgumentError`, silently caught and
turned into "nothing registered for working copy `<id>`" — even though a
real harness was live and actively reconciling that exact working copy at
the moment of the call (confirmed twice, against two different working
copies, both resolving to the same `working_copy_id` and both refused).

The registry a harness's channel join actually populates is a *different*,
correctly-named module: `CodeMySpec.Analysis.HarnessRegistry` (started in
`lib/code_my_spec_web/application.ex:39`, populated by
`Analysis.register_executor/3` from `harness_project_channel.ex:1289`).

Practical effect: `start_agent`/`stop_agent` can never reach a real,
connected harness in any environment — the story's core promise (a stop
actually ends the process) does not work end-to-end today. This is invisible
to `mix spex` because every spex in this story swaps in an in-process fake
transport, never exercising the real `Harness` module. Once this is fixed,
re-run this brief's untested scenarios (2873, 2874, 2876 running-agent case,
2877-2879, 2881-2885) against a real started agent and a real `stop_agent`
call — that was the intended test plan and could not be completed only
because of this defect.
