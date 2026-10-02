# Qa Story Brief

## Tool

curl (single-line) — `POST /api/hooks/post-tool-use` and `POST /api/hooks/stop` are `:hook`-pipeline
controller endpoints (`CodeMySpecLocalWeb.Hooks.PostToolUseController` /
`StopController`), not LiveView. `list_problems` is an MCP tool
(`mcp__plugin_codemyspec_local__list_problems`) — use the agent's own MCP
client, never curl (see plan.md's "Local MCP can't be QA'd via plain curl").

## Auth

None. Port 4004's `:hook` pipeline is `LocalOnly` (loopback-only) + a scope
resolved from `X-Harness-Id` (preferred) or `X-Working-Dir` (fallback).

This working copy's harness id (looked up once via psql, safe to reuse for
the whole session):

```
psql -qtA code_my_spec_dev -c "select id from harnesses where root = '/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator';"
```

At the time this brief was written that returned `6bc4851f-f735-4590-bb1c-c660619b4019`.
Send it on every hook call:

```
-H "X-Harness-Id: 6bc4851f-f735-4590-bb1c-c660619b4019"
```

## Seeds

None needed from the standard QA fixtures — this story's surface (`Problems`,
`AnalysisAlert`) reads whatever is already recorded for the working copy's
harness. Do **not** seed synthetic problem rows via `/api/hooks/stop`'s
`test_output_files` override against this shared harness — that param exists
for the spex suite's cassette-backed fixtures only (`Hooks.Stop` says so in
its own moduledoc: "Real Claude Code clients never send this param"), and
writing through it here would insert fake `Problems` rows scoped to
`6bc4851f-...`, which is the *same* harness every other agent's stop-hook
decisions on this worktree read from. That is real, disruptive shared state,
not a private fixture — don't use it against the main working copy's harness.

Instead, verify current live problem state read-only via psql before testing
(safe while the server is up, per plan.md):

```
psql -qtA code_my_spec_dev -c "select source, severity, count(*) from problems where harness_id = '6bc4851f-f735-4590-bb1c-c660619b4019' group by source, severity;"
```

At brief-writing time this returned 131 credo/error + 275 credo/info + 8
spex/error = 414 rows, and none were excluded by `reject_superseded`
(verified by replicating that filter's SQL directly) — so the alert should
have real content to report without any injected data. Because this is a
live, actively-edited shared worktree, re-check this count immediately
before running the "told" scenarios — if it has dropped to 0, either wait
for the async sweep to record something or ask before seeding.

## What To Test

All scenarios use fresh, made-up `session_id` values (never reuse a real
agent's session id) — this mirrors exactly what the spex suite does and is
side-effect-free: an unrecognized `session_id` just means `mark_active` and
`FileEdits` tracking no-op, so nothing is attributed to a real session.

- **Two agents in one working copy are both told** (criterion 2340). POST
  `/api/hooks/post-tool-use` with two different fresh session_ids, each
  `tool_name: "Read"`. Both responses' `systemMessage` should name the
  analyzer(s) currently failing (e.g. `credo`) — neither should say anything
  like "not yours" / "another agent".
- **A subagent's breakage reaches its parent** (2341). POST
  `/api/hooks/post-tool-use` with `session_id` = a fresh parent id AND
  `agent_id` = a fresh subagent id, `tool_name: "Write"`. Then POST again
  with the same `session_id` and no `agent_id`, `tool_name: "Read"` — the
  parent's own next tool call should carry the alert.
- **An agent that never stops still finds out** (2342) / **A reading turn is
  told too** (2343). A single POST with a fresh `session_id`,
  `tool_name: "Read"` (never call `/api/hooks/stop` for this session) should
  still carry the alert if the harness currently has recorded problems.
  Repeat with `tool_name: "Grep"` — same result, since delivery must not
  depend on which tool fired.
- **A large backlog stays one line** (2344). Inspect the `systemMessage`
  from any of the above: it must name the analyzer and a count
  (`=~ ~r/\d/`), must be under 200 characters, and must NOT contain a file
  path (e.g. `example_context` or any `lib/...` path) — the credo backlog
  here is large (400+), so this is a real test of "notification, not
  report."
- **Silence when nothing moved** (2345). POST with a fresh `session_id`
  twice in a row (or more), both `tool_name: "Read"`. The alert should
  appear on the FIRST call only — the second and third calls should return
  `{}` for the same session, even though the underlying problems are still
  there.
- **A clean run says nothing** / **an answer that predates the fix**
  (2346/2349). These need a real transition (failing → clean, or edit-lands
  with no rerun since) and are the two hardest to trigger safely against
  shared state — do NOT force one via `test_output_files`. Instead: watch
  for a natural transition during the session (the async sweep runs
  continuously on this worktree), or treat this pair as regression checks
  on message content that hold unconditionally regardless of the current
  live state — assert the `systemMessage` NEVER matches
  `~r/green|passing|clean|resolved|fixed/i` on any call you make during this
  session. That assertion is valid at every point in time, seeded state or
  not, and is what the criteria are actually guarding against.
- **The suffix does not tax the turn** (2347). Send ~10 POSTs with no
  `session_id` at all (baseline — the check short-circuits entirely) and
  ~10 with a real fresh `session_id` already told once (so the alert path
  hits its "nothing new" branch). This is a query-count property best
  verified by reading the spex
  (`criterion_2347_the_suffix_does_not_tax_the_turn_spex.exs`, which measures
  telemetry directly) rather than by timing curl — timing on a loaded shared
  box is noise. Note in the result that this criterion is spex-verified
  rather than independently re-measured over curl.
- **The age is on the line** (2348). Any alert-bearing response's
  `systemMessage` must match `~r/ago|just now|seconds?|minutes?|hours?/i`.

### list_problems (MCP tool)

Call `mcp__plugin_codemyspec_local__list_problems` (no args, or
`severity: "error"`) from the agent's own MCP session and confirm: (a) it
returns a paginated `# Problems (N of TOTAL) — page P/PAGES` header, (b) a
`source` filter (e.g. `source: "spex"`) narrows the list, (c) a page beyond
the last returns the "No problems recorded" message or an empty body
appropriately.

**Known blocker as of this brief:** this tool — and in fact the entire
story-890 code path (`AnalysisAlert`, the updated `PostToolUse` hook) — is
unreachable against the live `:4004` dev server right now. Root-caused: the
`:4004` BEAM process has been running since 01:22, and all of story 890's
source files were written between 09:30–09:55 — after boot. A live curl to
`/api/hooks/post-tool-use` against a harness with 414 confirmed live
(non-superseded, verified via direct SQL replication of
`Problems.watermark`'s query) problems still returns bare `{}`, which is only
possible if the running process is executing the pre-story `PostToolUse`
code that never calls `AnalysisAlert.check`. Phoenix's code reloader is not
picking this commit up; a real restart of the `:4004` process is required.
This is a shared process (9+ other agents were active on it at the time of
writing), so it was not restarted unilaterally — coordinate via team-lead
before restarting, then re-run every scenario above for real before
submitting a `pass`.

## Result Path

No result.md — findings via `create_issue`, outcome via
`mcp__plugin_codemyspec_local__submit_qa_result` per the `qa_story` workflow.

## Setup Notes

The BDD spex for this story (`test/spex/1012_analysis_results_reach_the_agent_that_caused_them/*_spex.exs`,
10 files, one per criterion) already exercise every scenario above through
`Phoenix.ConnTest` (in-process, not real HTTP) with `x-harness-id` set to
`context.scope.active_harness_id` and use `ExCliVcr`'s `test_output_files`
override to seed synthetic runs safely (isolated per-test scope, not this
shared harness). Per team-lead: all 10 are green
(`mix spex --pattern "test/spex/1012_*/**/*_spex.exs"`). This QA pass's job
is the thing spex cannot do — confirm the real running app, real network
path, and real (not synthetic) data honor the same contract — which is
exactly what is currently blocked by the stale `:4004` process above.
