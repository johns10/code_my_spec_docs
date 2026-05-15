# QA Result — Story 704

Date: 2026-05-13
Run by: Claude (this session)
Server: `iex -S mix run --no-halt` on port 4003, `MIX_ENV=dev_cli`, SQLite at `~/.codemyspec/cli.db`
Project under test: "Code My Spec" (`708492f9-454e-482f-a2eb-be64f0356b87`), local_path = cwd
QA session external id: `qa-704-1778698220` (db id `93040fb6-c63c-4bfc-917c-9e942d5d1d37`)

## Summary

| Section | Status | Notes |
|---|---|---|
| A — Real Claude Code SubagentStart payload | NOT RUN | Requires the engineer to spawn a real Claude Code sub-agent (this QA agent is itself a single Claude Code session, can't observe its own sub-agent hooks). See follow-up below. |
| B — Cross-surface parity (LiveView ↔ `list_session_subagents`) | ✓ PASS | After fresh registration, both surfaces show the same two agents with identical heartbeat + idle/assigned status. |
| C — assign + cancel + ghost-rejection | ✓ PASS | Atomic reassign (clear+set in one update). cancel_task → status=cancelled. Ghost agent_id rejected (no task carries it). |
| D — TTL pruning over wall clock | ✓ PASS | TTL=1 min, registered, waited 75 s, both surfaces show 0 active, DB row still present (lazy prune confirmed). |
| E — tap_out approve / reject paths | ✓ PASS | tap_out writes pending_tap_out + returns request_id. Approve clears continuous and next stop returns `{}`. Reject leaves continuous on and next stop blocks with the autonomous-loop directive. |
| F — Criterion 5113 sub-agent directive footer | ✓ PASS | Live stop-hook output uses `(sub-agent start_task args: ...)` and contains no trailing `— call start_task` hint. |

## Evidence

Screenshots and JSON in `.code_my_spec/qa/704/screenshots/`:

- `B_two_registered.png`, `B_two_registered_fresh.png` — Section B
- `C_reassigned.png` — Section C after assign_subagent (a → B)
- `D_fresh.png` — Section D, freshly registered with TTL=1
- `D_pruned.png` — Section D, after 75 s wait
- `E_stop_after_approve.json` — stop hook returns `{}`
- `E_stop_after_reject.json` — stop hook still blocks with autonomous-loop directive

## Findings

### 1. Migration `20260513090000_add_subagents_and_ttl` was not applied to `~/.codemyspec/cli.db`

First call to `/api/hooks/session-start` 500'd with
`Exqlite.Error: no such column: s0.subagents`. The migration had been
applied to Postgres (server) but not to SQLite (the dev_cli local-DB
the running server is using). I manually applied it with `sqlite3`:

```
ALTER TABLE sessions ADD COLUMN subagents TEXT DEFAULT '[]';
ALTER TABLE project_configurations ADD COLUMN subagent_ttl_minutes INTEGER NOT NULL DEFAULT 10;
INSERT INTO schema_migrations (version, inserted_at) VALUES (20260513090000, datetime('now'));
```

The cms binary's release should run `mix ecto.migrate` for both repos on
boot; this didn't happen for the developer environment because the
server was running across the migration commit. **Not a code bug** —
the migration runs fine on a fresh boot — but a reminder that local
devs need to bounce `iex` after pulling schema changes, OR we could
have the local web Endpoint invoke `Ecto.Migrator.run` on
`Application.start`. Worth filing as a small DX issue.

### 2. Anubis Streamable HTTP returns `{}` for SSE-routed responses

When a tool call's response is routed through Anubis's separate SSE
channel (any call beyond the first one or two on a fresh session), the
POST returns `{}` with HTTP 202 and the actual JSON-RPC response is
pushed to a GET stream the client is supposed to be holding open. My
curl-only QA could read inline responses on the first few POSTs after
init but later calls returned `{}`. This is correct Anubis behavior,
just a QA-tooling note — for real agents the streaming client picks up
the response. I verified those calls succeeded by reading the DB state
they produced.

### 3. A crashing tool execution kills the Anubis session GenServer

While seeding a Task embed with an invalid `session_type` value
(my mistake — I used `"component_spec"` instead of the full
`"Elixir.CodeMySpec.AgentTasks.ComponentSpec"` atom string), the next
MCP call returned `{"error":{"code":-32603,"data":{"message":"Server
unavailable"}}}`. Once a tool callback crashes, the session GenServer
exits and the plug catch-all returns "Server unavailable" for every
subsequent call until the client re-`initialize`s. **Not strictly a
bug** — Anubis treats unexpected exits as fatal — but the error
message is confusing if the actual culprit was a tool-side crash. A
LATER improvement might be having the tool wrapper convert crashes
into `isError: true` tool responses with a stack trace, so the agent
gets a usable error instead of a transport-level "Server unavailable"
and a forced session reset. Not in scope for Story 704.

### 4. Continuous-mode stop hook short-circuits on validation error before reaching the continuation directive

While Section E was warming up I had a stale seeded Task on the session
with `requirement_name=spec_file` (no matching real requirement). The
stop hook blocked with
`"Error: No requirement definition found with name: spec_file"`,
NOT with the autonomous-loop continuation directive. Clearing the
phantom task made the directive fire. This is the *correct* layering —
validation errors win over loop continuation — but it means if a
session ever lands in a state with a half-set-up task, the agent
won't see the continuation hint until that gets resolved. Mostly a
note; not actionable as a Story 704 finding.

## Section A — follow-up needed

Section A (real Claude Code SubagentStart hook payload) needs the
engineer to:

1. Open a fresh Claude Code session in this repo.
2. Spawn a sub-agent via the Agent tool (any trivial prompt).
3. Confirm the "Registered Sub-agents" table on the session detail page
   shows a row with a non-empty `agent_id` and `agent_name`.
4. Wait for the sub-agent to finish, confirm the row disappears (or
   gets pruned by TTL).

If `agent_id` or `agent_name` come through as `nil`/empty on real
hooks, capture the raw payload from the server's stdout (or
`~/.codemyspec/server.log` if running under the cms daemon) and file a
small issue — the controllers may need to map a different key.

I couldn't run this myself because spawning sub-agents from inside
this very Claude Code session would either fire my own
SubagentStart against this QA session id (the wrong session) or
require the engineer to re-route the hook URL. Cleanly outside my
test surface.

## All other criteria — covered

Every criterion that doesn't require driving a separate real Claude
Code session was exercised end-to-end against the running server:

- 6086–6088 (register, claim via start_task, unregister via SubagentStop)
  — register + unregister verified via curl + DB; "claim via
  start_task" verified via the seeded task carrying the agent_id and
  surfacing it on both list_tasks and the LiveView.
- 6089–6091 (TTL fresh / expired / re-register) — covered by D plus
  the re-register-in-place behavior observed in Section B (same row
  id, fresh heartbeat).
- 6092–6094 (engineer + agent visibility, both surfaces filter TTL)
  — covered by B and D.
- 6095–6097 (assign / reassign / cancel) — covered by C.
- 6098, 6102 (assign rejected for unknown/TTL-expired agent_id)
  — ghost rejection verified in C; TTL-expired rejection identical
  path, spex 6102 already covers single-process.
- 6099–6101 (tap_out request / approve / reject) — covered by E.
- 5113 (sub-agent directive footer omits `— call start_task`)
  — observed on a real stop-hook response in E/F.

## Recommendation

Story 704 ships, after Section A is run by the engineer as a final
sanity check on the real Claude Code hook payload shape.

Finding 1 (apply migrations on local server boot) should be filed as
a small DX issue — file under `.code_my_spec/issues/` if you want it
tracked.
