# QA Brief — Story 704: Agent administers their session

Story 704 introduces a sub-agent registry on `Session`, four admin MCP
tools (`list_session_subagents`, `assign_subagent`, `cancel_task`,
`tap_out`), two webhook endpoints (`/api/hooks/subagent-start` and
`/api/hooks/subagent-stop`), and a "Registered Sub-agents" block on
the session detail LiveView. The spex suite at
`test/spex/704_agent_administers_their_session/` covers the
single-process semantics; this brief covers the moving parts that
only show up in real-process operation:

- SubagentStart / SubagentStop hooks running under actual Claude Code
  during a spawned sub-agent
- TTL pruning visible in the LiveView as the wall clock advances
- Tap-out PubSub broadcast reaching a real subscriber
- Cross-surface parity between `list_session_subagents` and the
  "Registered Sub-agents" table on the session detail page
- Behavior when Claude Code's actual SubagentStart/SubagentStop hook
  payload shape diverges from what the controllers expect (real-world
  edges the spex can't catch)

Covers criteria 6086–6102 from a real-process angle. The unit-level
single-call semantics are already proven by the spex suite — do NOT
re-run those scenarios in isolation. Spend QA time only on the
multi-process / wall-clock / real-hook things the spex can't observe.

## Tool

- `mcp__vibium__browser_*` for the session detail LiveView at
  `http://127.0.0.1:4003/projects/:project_name/sessions/:id`
- `mcp__plugin_codemyspec_local__list_session_subagents`,
  `assign_subagent`, `cancel_task`, `tap_out`, plus the existing
  `start_task` / `list_tasks` / `get_next_requirement` for setup
- `curl` for hitting `/api/hooks/subagent-start` and
  `/api/hooks/subagent-stop` directly (to simulate real Claude Code
  hooks against a known payload)
- A live Claude Code session in this repo that can spawn sub-agents
  via the Agent tool — for the one end-to-end test that exercises the
  real hook payload shape
- `psql` / `iex` for spot-checking `Session.subagents` and
  `Session.state["pending_tap_out"]` only when LiveView and MCP
  surfaces disagree — start from the surfaces, not the DB

## Auth

None. Local app on port 4003 is gated by `Plugs.LocalOnly`.

If `curl -s http://127.0.0.1:4003/health` doesn't return
`{"status":"ok"}` first, stop and fix the server before continuing.

## Seeds

Use a real project with a real synced component so `start_task` has
something to claim. The QA Fixture Project from `priv/repo/qa_seeds.exs`
is fine — it already has at least one component with an open
`spec_file` requirement.

```
# Confirm fixture project + at least one open task-able requirement
mcp__plugin_codemyspec_local__list_projects
mcp__plugin_codemyspec_local__get_next_requirement
# expect: a requirement on the QA Fixture Project, NOT an init/sync stub
```

Set the working directory header to the QA Fixture Project's
`local_path` for every MCP call. If a tool replies "No active session"
or "no working directory," reconnect MCP via `/mcp` — known Anubis
Streamable-HTTP interaction.

## Session ID convention

For every fresh session below, pick an external id you'll recognize
in the LiveView URL and `list_sessions` calls:

```
SESSION_ID="qa-704-$(date +%s)"
```

Use the same value when curling `session-start`, `subagent-start`,
`subagent-stop`, `stop` — that's how the local server stitches a
single Claude Code session together.

## What to Test

Screenshot at every key state into `.code_my_spec/qa/704/screenshots/`
(Vibium writes to `~/Pictures/Vibium/<basename>` — name files with a
criterion prefix and `cp` them in at the end).

### A. Real Claude Code hook payload shape (one-shot, do first)

Goal: catch any divergence between Claude Code's real `SubagentStart`
/ `SubagentStop` hook payload and our controllers' expected shape.

- [ ] Open a fresh Claude Code session in this repo.
- [ ] Confirm the session's external id matches what the local server
      sees: `curl -s http://127.0.0.1:4003/api/sessions | jq '.[].external_conversation_id'`
      (or check the most-recent row).
- [ ] In Claude Code, spawn a sub-agent via the Agent tool with any
      trivial prompt ("say hi"). This fires the real
      `SubagentStart` hook.
- [ ] Navigate the browser to
      `http://127.0.0.1:4003/projects/<project_name>/sessions/<session_id>`.
- [ ] Pass: a "Registered Sub-agents" row appears with a non-empty
      `agent_id` and `agent_name` (Claude Code's value, not nil).
      Screenshot `A_real_subagent_start.png`.
- [ ] Wait for the sub-agent to finish. Pass: the row disappears
      (or `last_heartbeat_at` ages out — see section D for that
      variant). Screenshot `A_real_subagent_stop.png`.
- [ ] If `agent_id`/`agent_name` is nil/empty in the table, file a
      `qa` issue: our controllers expect specific keys and Claude
      Code is sending a different shape. Capture the raw payload
      from `~/.codemyspec/server.log` (grep `req=` near the
      `/api/hooks/subagent-start` POST) and attach it to the issue.

### B. Cross-surface parity (criteria 6092–6094)

Use the simulated path (curl) so you can deterministically place
heartbeats — then compare what the LiveView shows against what
`list_session_subagents` returns.

- [ ] Curl `session-start`:
      ```
      curl -s -X POST -H 'Content-Type: application/json' \
        -H "x-working-dir: <project local_path>" \
        -d "{\"session_id\":\"$SESSION_ID\"}" \
        http://127.0.0.1:4003/api/hooks/session-start
      ```
- [ ] Curl two `subagent-start` calls with distinct `agent_id`s
      (e.g. `qa-subagent-a` and `qa-subagent-b`).
- [ ] Open the session detail page. Pass: both rows visible, each
      with a "—" or "unassigned" assignment cell. Screenshot
      `B_two_registered.png`.
- [ ] In a second Claude Code window, call
      `list_session_subagents session_id=$SESSION_ID`. Pass: same
      two agent_ids, same agent_names. If LiveView and MCP disagree,
      that's the bug — `Session.active_subagents/2` is the only
      source on both sides and divergence means a config mismatch
      (TTL configured differently for one path, etc.).

### C. Assign + cancel surface assignment in both places (6095–6097)

- [ ] With both sub-agents from section B still registered, call
      `start_task` with `agent_id=qa-subagent-a` for an open
      requirement. Pass: `list_tasks` shows that task with
      `agent=qa-subagent-a`. Pass: session detail's "Registered
      Sub-agents" table shows `qa-subagent-a` assigned to that
      task (not "unassigned"). Screenshot `C_assigned_via_start.png`.
- [ ] Call `assign_subagent session_id=$SESSION_ID
      agent_id=qa-subagent-b task_id=<the same task>`. Pass: the
      task's `agent` field changes to `qa-subagent-b` in
      `list_tasks`; LiveView reflects the swap on next refresh.
      Screenshot `C_reassigned.png`.
- [ ] Call `cancel_task session_id=$SESSION_ID
      task_id=<the task>`. Pass: `list_tasks` no longer lists it as
      active (status `cancelled`); LiveView's assignment cell
      returns to unassigned for `qa-subagent-b`. Screenshot
      `C_cancelled.png`.
- [ ] Call `assign_subagent` with an `agent_id` that was never
      registered (`qa-subagent-ghost`). Pass: MCP returns an error
      naming that agent_id; no task carries it.

### D. TTL pruning over wall-clock time (6090, 6094)

Default TTL is 10 minutes. Set it lower so QA doesn't stall.

- [ ] In `iex`, drop TTL to 1 minute for the QA Fixture Project's
      `project_configuration`:
      ```
      iex> alias CodeMySpec.Configurations
      iex> scope = ... # build a scope for the QA Fixture Project
      iex> Configurations.upsert(scope, %{subagent_ttl_minutes: 1})
      ```
- [ ] Curl `subagent-start` with `agent_id=qa-subagent-ttl`.
- [ ] Pass: LiveView and `list_session_subagents` both show the row
      immediately. Screenshot `D_fresh.png`.
- [ ] Wait 70 seconds (real wall clock — set a timer).
- [ ] Reload the session detail page. Pass: `qa-subagent-ttl` no
      longer in the table. Call `list_session_subagents`. Pass:
      same — empty. Screenshot `D_pruned.png`.
- [ ] Spot-check the DB to confirm we did NOT mutate the row (lazy
      prune contract):
      ```
      iex> Sessions.get_by_external_id(scope, "$SESSION_ID").subagents
      ```
      Pass: the row IS still in the JSONB array (just filtered on
      read). If the array is empty, that's a regression — file an
      issue, TTL is supposed to be lazy. Reset TTL to 10 when done.

### E. Tap-out broadcast reaches a real subscriber (6099–6101)

The spex covers `respond/4` directly. This section proves the PubSub
broadcast actually arrives at a process the agent could subscribe
from.

- [ ] In an `iex -S mix phx.server`:
      ```
      iex> Phoenix.PubSub.subscribe(CodeMySpec.PubSub, "permissions:tap_out")
      ```
- [ ] In Claude Code, with continuous mode on for `$SESSION_ID`, call
      `tap_out session_id=$SESSION_ID`.
- [ ] In `iex`: `flush()`. Pass: see
      `{:tap_out_requested, "<request_id>", "<session_id>"}`.
- [ ] In `iex`:
      ```
      iex> CodeMySpec.Permissions.TapOut.respond(scope, "$SESSION_ID", "<request_id>", :approve)
      iex> flush()
      ```
      Pass: see `{:tap_out_decision, "<request_id>", :approve}`.
- [ ] Curl `/api/hooks/stop` for `$SESSION_ID`. Pass: the response
      does NOT block with the autonomous-loop continuation directive
      (continuous cleared by approve). Screenshot
      `E_stop_after_approve.png`.
- [ ] Repeat with `:reject` on a fresh tap-out request. Pass: the
      next `/api/hooks/stop` STILL blocks with the autonomous-loop
      directive in `reason` (continuous stayed on). Screenshot
      `E_stop_after_reject.png`.

### F. Sub-agent directive footer (criterion 5113, smoke)

Not strictly Story 704 but co-shipped — the `start_task` directive
text for sub-agent paths must not include the `— call start_task`
hint that gives the sub-agent the wrong cue.

- [ ] Call `get_next_requirement` until you land on a sub-agent
      requirement (one whose orchestrate_node prompt advertises
      `(sub-agent start_task args: ...)` in its prompt). Pass:
      the rendered directive contains `(sub-agent start_task
      args: ...)` and does NOT contain a trailing `— call
      start_task` invitation. Screenshot `F_subagent_directive.png`.

## Exploration

After the scripted scenarios, freely poke:

- Spawn 5+ sub-agents to one session, hit the page, see if pagination
  / overflow is sane.
- Register a sub-agent, then re-register with the same `agent_id`
  (Claude Code does this on long-running sub-agents). Pass: row
  updates in place, no duplicate row.
- `cancel_task` on a task that was already completed. Pass: graceful
  error, no orphan state.
- `tap_out` twice in a row without a response in between. Pass:
  decide what we want here — clobber vs reject — and either file an
  issue or note it as expected.

File any UI/UX defect or unhandled-error path as a `qa` issue with
severity matching impact.
