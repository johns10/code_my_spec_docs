# Qa Story Brief

## Tool

`mcp__plugin_codemyspec_local__submit_qa_result` +
`list_qa_attempts` + `invalidate_qa_attempt` (the agent surface
for this story is itself the QA tools — pure self-referential
dogfooding) plus `mix spex` for the in-process contract layer.

## Auth

None. MCP tools run through the local server's authenticated
session.

## Seeds

None required. Each MCP tool call is self-contained.

## What To Test

Live MCP probes (the agent surface IS this story):

- Happy: `submit_qa_result` with task_id, status, scenarios, no
  issue_ids → expect attempt_id in response + "qa_complete is
  satisfied" note
- Failure: `submit_qa_result` with `scenarios: []` → expect
  changeset error "scenarios: must have at least one scenario,
  can't be blank"
- Failure: `invalidate_qa_attempt` with bogus attempt_id
  (zero-uuid) → expect "no attempt with id ... exists. Use
  list_qa_attempts..." message
- Failure: `invalidate_qa_attempt` with whitespace-only reason
  → expect "requires a non-empty reason" message

In-process contract verification:

- `mix spex --pattern "test/spex/726_*/*.exs"` — 12 criteria,
  every rule + failure path exercised through the same Anubis
  tool dispatch path as the live MCP call.

## Result Path

.code_my_spec/qa/726/result.md

## Setup Notes

Story 726's agent surface is the MCP tools themselves. The
probes above EXERCISE those tools live against the running
local server, then submit the outcome via the very tool being
tested — fully self-referential dogfood. Earlier in this session,
attempts cba41736 (607) and a55a50c3 (606) also exercised the
happy path. The failure paths covered here close the loop on
boundary validation discipline (R2 + R6 + R7).
