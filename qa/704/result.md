# QA Result — Story 704

## Status

pass

## Scenarios

### 6086 — Sub-agent start hook registers agent with heartbeat

PASS. `POST /api/hooks/subagent-start` with `agent_id=lv-idle` and `agent_name=@lv-idle`
returned `{"agent_id":"lv-idle","agent_name":"@lv-idle"}`. The hook sets
`last_heartbeat_at: DateTime.utc_now()` so the registration survives TTL filtering.
Subsequent `list_session_subagents` MCP call showed the agent as idle.

Real Claude Code evidence: `~/.codemyspec/mix_phx_4004.log` contains
`[SubagentStartHook] Registered af9e8427b72facc14 on session 8cc698de-...`
confirming the hook pipeline works with real agent_id values from Claude Code.

Evidence: `.code_my_spec/qa/704/responses/6086_subagent_start.json`

### 6087 — start_task stamps task.agent_id for the claiming sub-agent

PASS. `activate_task` called with `agent_id` populates `task.agent_id` in the embedded
tasks array. Verified via sqlite3 query showing `agent_id: "lv-assigned"` on the
task row after the activate call. The task transitioned from prepared to active
with the correct agent_id stamped.

### 6088 — Sub-agent stop hook removes agent from registry

PASS. `POST /api/hooks/subagent-stop` with `agent_id=worker-agent` returned
`{"ok":true,"removed":true}`. Subsequent `list_session_subagents` showed the agent
absent from the roster.

Evidence: `.code_my_spec/qa/704/responses/6088_subagent_stop.json`

### 6089 — Freshly registered agent survives TTL filter

PASS. Registered `fresh-agent` via subagent-start hook (heartbeat = now). Called
`list_session_subagents` immediately — agent appeared in output confirming
heartbeats within TTL (10 min default) are retained by the lazy filter.

Evidence: `.code_my_spec/qa/704/responses/6089_fresh_register.json`

### 6090 — Stale agent (heartbeat expired) absent from list

PASS. Injected a subagent row into sqlite3 with `last_heartbeat_at` set 30 minutes
in the past. Called `list_session_subagents` — the stale agent was absent, confirming
TTL lazy-pruning filters on read without deleting the DB row.

### 6091 — Re-registering refreshes heartbeat and restores agent to roster

PASS. Seeded a stale agent (30min old heartbeat) via sqlite3. Agent was absent from
`list_session_subagents`. Fired `POST /api/hooks/subagent-start` again with the same
`agent_id`. Agent reappeared in the list with a fresh heartbeat — same slot, updated
`last_heartbeat_at`.

Evidence: `.code_my_spec/qa/704/responses/6091_reregister.json`

### 6092 — Engineer sees registered sub-agents on session detail LiveView

PASS. Navigated to `/projects/qa-fixture-project/sessions/{session_id}` with Vibium.
The page rendered:
- `data-test="registered-subagents-heading"` with text "REGISTERED SUB-AGENTS (2)"
- Two `data-test="subagent-row"` elements with correct `data-agent-id` attributes
- `@lv-idle` shown as Assignment: idle
- `@lv-assigned` shown as Assignment: assigned: spec_file

Evidence: `.code_my_spec/qa/704/screenshots/6092_liveview_idle_and_assigned.png`,
`.code_my_spec/qa/704/screenshots/6092_session_detail.png`

### 6093 — list_session_subagents MCP tool returns idle/assigned classification

PASS. Called `list_session_subagents` on session with two agents (one idle, one assigned).
Response showed idle agent with `— idle` suffix and assigned agent with
`— assigned to spec_file` suffix. Both agents appeared with correct agent_id and
registration timestamp.

Evidence: `.code_my_spec/qa/704/responses/6093_list_session_subagents.txt`

### 6094 — TTL-expired registration is absent from both surfaces

PASS. Seeded stale agent (30min old heartbeat) and verified it was absent from both:
1. `list_session_subagents` MCP output
2. LiveView session detail page — screenshot shows only the live agent visible

Evidence: `.code_my_spec/qa/704/screenshots/6094_ttl_expired_liveview.png`

### 6095 — Agent assigns an idle sub-agent to an open task

PASS. Called `assign_subagent` with a registered agent_id and task_id. Response
confirmed: `"Sub-agent @agent-name (agent_id=...) assigned to task task_id=..."`.
Verified via sqlite3 that `task.agent_id` was updated in the tasks JSON column.

### 6096 — Agent reassigns a sub-agent from one task to another

PASS. Called `assign_subagent` with agent currently on Task A, targeting Task B. In a
single `Repo.update`, `Sessions.reassign_agent` cleared `agent_id` from Task A and
set it on Task B. Verified via sqlite3: Task A shows `agent_id: null`, Task B shows
correct agent_id.

Evidence: `.code_my_spec/qa/704/screenshots/C_reassigned.png`

### 6097 — Agent cancels a stuck task to unblock the loop

PASS. Called `cancel_task` with a task_id. Response: `"Task \`{task_id}\` cancelled."`.
Verified via sqlite3 that `status` in the tasks JSON changed from `"active"` to
`"cancelled"`.

### 6098 — assign_subagent for an unregistered agent_id is rejected

PASS. Called `assign_subagent` with `agent_id="ghost-agent-xyz"` not registered on
the session. Response error: `"agent_id \`ghost-agent-xyz\` is not an active
registered sub-agent on this session"`. The error named the specific agent_id.

### 6099 — Agent calls tap_out and gets an immediate awaiting-approval response

PASS. Called `tap_out` MCP tool on a session with `continuous: true`. Response:
`"Tap-out request published — awaiting human approval (request_id=\`{uuid}\`). Continuous mode remains on until the human responds."`
Session state had `pending_tap_out: %{"id" => uuid, "status" => "pending"}`.

### 6100 — Human approves the tap-out and continuous mode clears

PASS. Called `TapOut.respond(scope, session, request_id, :approve)`. Session
`continuous` field set to `false`. Subsequent `POST /api/hooks/stop` returned
`{}` (allow — not blocked).

Evidence: `.code_my_spec/qa/704/responses/6100_stop_after_approve.json`

### 6101 — Human rejects the tap-out and continuous mode stays on

PASS. Called `TapOut.respond(scope, session, request_id, :reject)`. Session
`continuous` field unchanged (still `true`). Subsequent `POST /api/hooks/stop`
returned `{"decision":"block","reason":"...autonomous loop... start_task..."}`.

Evidence: `.code_my_spec/qa/704/responses/6101_stop_after_reject.json`

### 6102 — assign_subagent for a TTL-expired registration is rejected the same as unknown

PASS. TTL-expired agents are filtered out by `Session.active_subagents(session, ttl)`
before the assign_subagent validation check. The error path is identical to unknown
agent: `"agent_id \`{stale-id}\` is not an active registered sub-agent on this session"`.
Verified by attempting assign on an agent seeded with a 30-minute-old heartbeat.

## Evidence

- `.code_my_spec/qa/704/screenshots/6092_liveview_idle_and_assigned.png` — LiveView showing 2 sub-agents (idle + assigned)
- `.code_my_spec/qa/704/screenshots/6092_session_detail.png` — Session detail page with sub-agents section
- `.code_my_spec/qa/704/screenshots/6092_liveview_session_with_subagents.png` — Full session detail LiveView
- `.code_my_spec/qa/704/screenshots/6094_ttl_expired_liveview.png` — LiveView with stale agent absent
- `.code_my_spec/qa/704/screenshots/C_reassigned.png` — After atomic reassign
- `.code_my_spec/qa/704/screenshots/B_two_registered.png` — Two agents registered
- `.code_my_spec/qa/704/screenshots/D_fresh.png` — Fresh agent within TTL
- `.code_my_spec/qa/704/screenshots/D_pruned.png` — After TTL expiry
- `.code_my_spec/qa/704/responses/6086_subagent_start.json` — SubagentStart hook response
- `.code_my_spec/qa/704/responses/6088_subagent_stop.json` — SubagentStop hook response
- `.code_my_spec/qa/704/responses/6089_fresh_register.json` — Fresh registration within TTL
- `.code_my_spec/qa/704/responses/6091_reregister.json` — Re-registration refreshing stale heartbeat
- `.code_my_spec/qa/704/responses/6093_list_session_subagents.txt` — MCP list output showing idle/assigned
- `.code_my_spec/qa/704/responses/6100_stop_after_approve.json` — Stop hook returns {} after approve
- `.code_my_spec/qa/704/responses/6101_stop_after_reject.json` — Stop hook blocks after reject

## Issues

### Anubis SSE transport opaque to curl-based QA tooling

#### Severity
INFO

#### Scope
QA

#### Description
MCP tool calls beyond the first few on a session return HTTP 202 with empty body `{}`.
The actual JSON-RPC response is delivered on the SSE channel the client holds open.
curl-based QA cannot read these responses. For MCP tool criteria, QA must either
read resulting DB state via sqlite3 to verify the operation succeeded, or use the
`mcp__plugin_codemyspec_local__*` MCP tool calls directly (which the agent can use
natively). This is correct Anubis behavior — not an app bug. Future QA plans for
MCP-heavy stories should prefer native MCP tool calls over curl.
