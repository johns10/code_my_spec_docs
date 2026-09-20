# Qa Story Brief: 1012 — The main agent sees what each of its agents is working on

Rewritten 2026-09-20 against the current criteria (3270–3300; the previous
brief predates the 2026-09-19/20 rewrite and is superseded).

## Tool

`.code_my_spec/qa/scripts/qa_as_agent.sh` (MCP, code-mode `run_script` +
direct tool calls) plus `psql` against `code_my_spec_dev` for fixture setup
that has no tool surface (backdating timestamps, toggling
`working_copies.machine_tools`, inserting/clearing `problems` rows).

This story's surface is `list_agent_work` (`CodeMySpec.McpServers.MainAgent.Tools.ListAgentWork`,
rendered by `CodeMySpec.McpServers.MainAgent.AgentWorkMapper`) — a code-mode
MCP tool on the local server (`:4004/mcp`), not a LiveView page. No browser
tool is needed for this story.

## Auth

No user login needed — this is the local harness surface, scoped by
`X-Harness-Id`. Use the QA wake fixture's own harness id (math_test_project's
`.cms_harness.json`), not this worktree's:

```
export QA_WORKTREE=/Users/johndavenport/Documents/github/math_test_project
SCRIPT=.code_my_spec/qa/scripts/qa_as_agent.sh
$SCRIPT <agent-id> <tool> '<json-args>'
```

`list_agent_work` and `check_in` read off the harness's project scope and
ignore the caller identity, so any agent id on that project works as the
`<agent-id>`. Tools that need a specific caller (`start_task`,
`get_next_requirement`, `tap_out`, `ask_user_question`, `stop_agent`) must be
called as the specific fixture agent whose identity the scenario needs.

## Seeds

```
cd /Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator
mix cms.seed priv/repo/qa_wake_seed.exs
```

Idempotent; gives four running agents on math_test_project (project
`d7f466a1-591e-4f36-8319-42633f59411e`, working copy
`56f5bf62-9cf8-400d-abcd-6c796afd3437`):

- coding: `25d67c11-f590-4e8e-a00d-6d3fb6bf08eb`, `59596b8a-1a5d-44b8-8f38-9bf1b570442d`
- product: `e9dce99a-9512-457d-b613-3baa49c387a7`
- main: `4e98e2a8-f674-4a10-9592-a1468e4b64ac`

**The reap race is real and tight.** `Agents.record_running_on_copy/3` reaps
any row claiming `:running` with no live process behind it, and on this box
that happens roughly every harness report cycle (~30s). A `status='running'`
SQL flip followed by anything slower than a couple of curl round trips (a
`mix cms.seed` invocation, a multi-step script) loses the window and the next
`list_agent_work` shows the agents `:stopped` again. Structure each capture
as: **one** `psql` `UPDATE agents SET status='running' ...` immediately
followed by the `list_agent_work` call, in the same shell invocation, with no
slow steps between them. State-setting calls (`start_task`, `ask_user_question`,
`tap_out`, backdating) don't need the agent to be `:running` — `fetch_agent`
doesn't check status — so do all of that first and only worry about the race
for the capture itself.

**This fixture is shared with concurrent QA passes** (siblings ran stories
1009/1011/1017 against the same rows in this session). Pending questions and
tap-outs from other stories' fixtures accumulate on these agent rows because
`qa_wake_seed.exs` only resets `status`/`continuous`/`turn_started_at`/`tasks`
— it does not touch `permission_requests` or `question_requests`. Treat any
pre-existing `blocked on: ...` line as possibly not yours; it's still valid
evidence for this story's criteria (a real unanswered question is a real
unanswered question), just don't assume you created it.

**Only one actionable requirement exists in this fixture project**
(`personas_complete`, product role, `project` entity, `execution_type:
main_agent`) — claim it with `start_task` on the **product** agent to get a
genuinely named, graph-backed task. Coding-role work is empty by design (see
`qa_wake_seed.exs`), which is also the real, unforced "nothing to do" case for
3272/3298.

## What To Test

- **3270/3273 (one view, whole-fleet question answerable):** call
  `list_agent_work` as any agent on the project; confirm every running agent
  appears in a single response, not one call per agent.
- **3271/3275 (named work, parts not a verdict):** `start_task` on the product
  agent for `personas_complete` (`entity_type=project`,
  `entity_id=d7f466a1-591e-4f36-8319-42633f59411e`). Confirm the listing shows
  `task: personas_complete` plus a separate `task opened: <ts>` line — a name
  and a timestamp, not a computed status word. Confirm no field anywhere
  collapses multiple facts into one verdict (no `stalled`/`healthy`/`stuck`
  string appears anywhere in the output).
- **3272 (idle vs. broken don't look alike):** with an agent holding no task,
  confirm it reads `nothing to do: the graph holds no work for its role`.
  Then `UPDATE working_copies SET machine_tools = '{}' WHERE id =
  '56f5bf62-...'` and recapture: the same agent now reads `cannot work: its
  machine reports no tools, so every tool call it makes will fail`. Restore
  `machine_tools` afterward (snapshot the 85-tool array before clearing it).
- **3274 (stopped is not shown as working):** `stop_agent` (direct tool, not
  `run_script`) on a coding agent that currently has a pending question and an
  old `last said`. Recapture `list_agent_work` and confirm that agent is
  entirely absent from the listing — not present with stale facts, just gone.
- **3276 (task opened an hour ago, quiet 45+ min):** after claiming
  `personas_complete`, backdate the task's `started_at` inside the agent's
  `tasks` jsonb array (`UPDATE agents SET tasks = ... jsonb_set(...,
  '{started_at}', to_jsonb(now() - interval '70 minutes'))`). Confirm both
  `task opened:` and `last said:` print as absolute timestamps a reader can
  do the arithmetic on — the tool does not compute or print "45 minutes ago"
  itself (by design; see `AgentWork` moduledoc on why there's no `status`).
- **3277 (waiting on an answer says so):** `ask_user_question` as a coding
  agent (or reuse a pre-existing pending one from the shared fixture).
  Confirm `blocked on: an unanswered question: "<verbatim text>"`.
- **3278 (tapped out ≠ stalled):** `tap_out` (direct tool) as one agent.
  Confirm `blocked on: tapped out — it asked to leave the loop and a person
  has not answered yet`, distinct wording from the unanswered-question line,
  visible in the same capture as a plainly-silent agent for contrast.
- **3279 (long silence + live connection ≠ stall):** an agent with a
  `last said` days in the past that is still `:running` and still listed
  (i.e., present in the fleet at all, with no tapped-out/blocked marker) is
  the evidence — the system doesn't invent a stall label for it.
- **3297 (mid-response shows work in flight):** call
  `CodeMySpec.Agents.record_turn_event(scope, agent_id, %{"kind" =>
  "turn_started"})` via a one-off `mix cms.seed <script>` (there is no MCP
  tool for this — it's normally driven by the harness's websocket channel).
  Confirm `in flight: a turn opened <ts> and has not finished`, shown
  alongside whatever else is true of that agent (task, tapped-out, etc.) as
  independent lines.
- **3298 (nothing to do says exactly that):** already covered by 3272's idle
  case — verbatim string `nothing to do: the graph holds no work for its
  role`.
- **3299/3300 (working-copy problems shown / clean shows none):** insert two
  rows into `problems` keyed to the working copy id; confirm `problems on
  this copy: N` with per-problem `[source] path:line message` lines on every
  agent on that copy. Delete the rows; confirm `problems on this copy: none —
  it is clean`.

## Result Path

No `result.md`. File findings with `create_issue` as you find them and close
the pass with `run_script({ script = "return submit_qa_result({...})" })`
per `qa_story/workflow.md`.

## Setup Notes

- `check_in` (the MCP tool) is **not** this story's surface. Its non-failure
  path only triggers `CodeMySpec.Agents.Work.consider_project/2` and returns
  a static confirmation string — it does not render or deliver
  `CodeMySpec.MainAgent.CheckInReport`, which is unwired dead code belonging
  to story 1059 (see its own moduledoc: "Story 1059, criterion 3332"). Filed
  as a separate issue, attributed there, not to 1012. `list_agent_work` alone
  is sufficient for every one of 1012's fourteen criteria.
- Restore `working_copies.machine_tools` and delete any fixture `problems`
  rows you add before finishing — nothing else in this fixture's reset path
  touches either.
- End the pass by re-running `mix cms.seed priv/repo/qa_wake_seed.exs` to
  cancel any `:active`/`:blocked` tasks you created and put the four agents
  back to a clean `:running` baseline for the next QA pass.
