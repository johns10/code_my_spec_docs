# Qa Story Brief

Story 1015 — The main agent sees the health of the machinery its agents
depend on. Component: `CodeMySpec.MainAgent` (context, no LiveView).

## Tool

`mcp__plugin_codemyspec_local__run_script` (Lua calling this session's own
bound MCP tools)

This story's whole surface is three MCP tools on the `MainAgent` server:
`check_machinery`, `restart_agent`, and `list_issues` (for verifying what
`restart_agent` raises). There is no LiveView or HTTP route for this story —
`CodeMySpec.MainAgent` is a context with `exports: :all` and no web layer of
its own. Per the QA plan's Tools Registry, the right pipeline for "an MCP
tool registered on a server" is the agent's own MCP client tools where they
exist, which they do here (`check_machinery`, `restart_agent` are in this
session's `run_script` catalog per `tool_docs`). No curl/Vibium needed.

## Auth

None. This session's `run_script` tools are already bound to this project's
harness (the real CodeMySpec dev project, not the QA Fixture Project) —
there is no separate login step for the MCP surface under test.

## Seeds

None. Do **not** run `qa_seeds.exs` or point at the sandbox for this story —
the surface under test is `check_machinery`'s read of the *real, live* fleet
(harness connections, machine tool lists, preview status, analyzer runs,
device load, cross-project tenancy on a shared Mac mini). That live state —
9 real checkouts, several real running agents, 4 other real projects sharing
the box — is better evidence than anything a fixture could stage, and it is
exactly the "shared dev box" scenario criteria 3324/3325/3326 are about.

The one caution: `restart_agent` is a real mutating action against real
running agents. Never call it against an agent id that is actually running
real work — that kills an in-flight turn on shared infrastructure. It is
safe to call it with a synthetic/nonexistent `agent_id` (e.g.
`00000000-0000-0000-0000-000000000000`) to exercise the refusal-and-raise
path (`{:error, :not_mine}` → an issue filed) with zero blast radius beyond
one throwaway issue, which should be dismissed immediately after with a note
that it's a QA verification artifact.

## What To Test

- `check_machinery({})` — assert the report names harness, tools, preview,
  analyzers, and machine sections, and that healthy pieces say so positively
  (not "unknown"/"not checked"). → 3309.
- Read the `tools:` line: on this live fleet it should currently read
  `working — every agent's machine is answering with a usable tool list.`
  with no per-agent blame. 3310/3311's discriminating clauses
  (`Machinery.tool_fault/1` → `:machine` vs `{:agents, ids}`, rendered by
  `MachineryMapper.tools/1`) cannot be exercised live without deliberately
  breaking a shared harness's tool client — don't do that. Confirm by code
  reading `lib/code_my_spec/main_agent/machinery.ex` and the two spex files
  (`criterion_3310_*`, `criterion_3311_*`) instead, and note the live report
  matches the `:none` clause exactly.
- Read the `analyzers:` section — confirm each of `compiler`/`credo`/`exunit`/
  `spex` is named individually in the same report as everything else (3322),
  and confirm any analyzer in `:stale` state is described as not a passing
  verdict ("Nothing it reports should be read as passing") rather than
  silently green (3323). On this box right now all four are genuinely stale —
  real evidence, not staged.
- Read the `machine:` section — confirm it names the shared device, states
  `other_projects` as a count only (no names/ids of other projects' work),
  and lists `agents on it` — cross-check that list against `list_agents({})`
  filtered to this project to confirm no foreign agent id leaks in (3325).
- Confirm the `load` sub-line: check whether any device on this box has ever
  reported `machine_load` (`load_reported_at` non-nil). If not — as is
  currently the case — check whether anything in `lib/cms_harness/project/
  channel_client.ex` (the harness's own channel client) actually sends a
  `machine_load` message, the way it already sends `preview_status` and
  `git_state`. If no sender exists anywhere, criterion 3324's positive case
  can never occur live — file it.
- `restart_agent({agent_id = "00000000-0000-0000-0000-000000000000", reason = "..."})`
  against a synthetic id — confirm `isError` (refused) and that `list_issues`
  now shows an issue explaining the refusal and why (harness/shared-machine
  reasoning, from the caller-supplied `reason`) (3312's refuse-and-raise
  shape, 3326). Dismiss the created issue immediately after with a note that
  it's a QA artifact.
- Do **not** call `restart_agent` against a real running agent id to force
  the success path (3321) or the machinery-tool-fault refusal (3312's other
  half) — both require either killing real in-flight work or an actually
  toolless machine, neither of which is safe to induce on this shared box.
  Verify these by code review of `lib/code_my_spec/main_agent.ex`
  (`consider/2`, `decide/4`, `attempt/4`) against the matching spex
  (`criterion_3312_*`, `criterion_3321_*`) instead.

## Result Path

`.code_my_spec/qa/1015/result.md`

## Setup Notes

This session is a real working copy of the CodeMySpec project itself (not
the QA Fixture Project) with several other worktrees/checkouts and real
agents live on the same Mac mini — that live shared-box state is the
evidence base for 3324/3325/3326 rather than something staged. Findings are
filed via `create_issue` as usual; no seed script changes were needed for
this story.
