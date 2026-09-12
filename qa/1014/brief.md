# Qa Story Brief

Story 1014 — The main agent starts, stops and restarts its agents.

## Tool

`run_script` (Lua, calling the `main_agent` MCP tool surface directly:
`restart_agent`, `check_machinery`, `list_agent_work`, plus `create_working_copy`,
`start_agent`/`message_agent`/`offboard_working_copy` to stage and drive real
throwaway agents). This is the actual agent-facing surface for this story —
there is no LiveView or curl-only route for `RestartAgent`; the McpServers.MainAgent
tools are what a real main agent calls, and `run_script` is a first-class way to
drive them directly, per `tool_docs`.

`list_issues` / `dismiss_issue` (also via `run_script`) to check the
issue-raising side of the criteria and clean up test noise afterward.

## Auth

None needed. This QA session's own harness/session credentials already carry
a working `main_agent` MCP tool set scoped to the real "Code My Spec" project
(account `johns10@gmail.com`, project `708492f9-454e-482f-a2eb-be64f0356b87`).

Do **not** use the qa-account / magic-link flow for this story — the
`restart_agent`/`list_agent_work`/`check_machinery` tools only exist on the
caller's own project scope (they operate on "your agents"), and this session's
own scope already is a live project with other real agents running on it.

## Seeds

None. Do not run `qa_seeds.exs` or touch the QA Fixture Project for this
story — restart-agent testing needs real, running agents on a machine, not
database fixtures, and this project already has them.

Instead, **stage a dedicated throwaway working copy** per session:

```lua
create_working_copy({ label = "qa-1014-restart-test", roles = "coding,qa" })
```

This mints a fresh git worktree + two real `claude-code`-provider agents
(confirmed: this project's agents already default to `provider: claude-code`,
not the broken `openai-codex` fallback the QA-account hits). Get their ids
from `list_agents({})` / `list_agent_work({})`, filtered to the new
`working_copy_id`.

**Offboard it when done**: `offboard_working_copy({ working_copy_id = "..." })`.

## What To Test

This is a **shared dev box** with other people's real agents doing real work.
The one rule that matters more than any single criterion: only ever pass an
`agent_id` to `restart_agent` that belongs to a working copy this session
created in this run. `list_agents`/`list_agent_work` will show a dozen other
real, unrelated agents (other worktrees, other stories) — never touch them.

- **3290 (acts on what it sees) / 3291 (restart carries its reason)**: message
  the staged coding agent once (`message_agent`) to establish a baseline reply,
  then `restart_agent(agent_id, reason)`. Confirm the response is not an error
  and names the agent id and the reason. Then `message_agent` the same agent
  again, asking it to recall, verbatim, every `Restarted: ...` instruction in
  its own conversation history — a real agent's own recollection is strong,
  non-browser proof the reason actually reached its thread (not just the tool
  reply).
- **3302 (a fix ends there)**: restart the same agent twice for the *same*
  reason, letting it reply in between. Both restarts should succeed (not
  refused) — a restart that resolved (agent spoke since) must not count
  against a later one for the same reason.
- **3306 (restarts one agent and nothing else)**: fire `message_agent` on the
  working copy's *other* staged agent (a longer prompt, so its turn is still
  running) and `restart_agent` on the target **in the same parallel batch**
  (two independent tool calls sent together). Confirm the neighbor's turn
  still completes cleanly and is not reset or lost.
- **3307 (cannot restart the harness)**: call `restart_agent` with the
  *working copy id* (not an agent id) as `agent_id`. Must be refused
  (`:not_mine`), and `list_issues({status="incoming", scope="framework"})`
  must show a new high-severity issue naming the reason. This is the safe way
  to exercise the criterion — it never touches a real harness process.
- **3292 (repeat suppression) / 3308 (fault outlives a restart)**: **found not
  reproducible live against a healthy agent** — see Setup Notes. Attempted via
  4 rapid back-to-back `restart_agent` calls for one reason; all 4 succeeded
  because the real agent's very first streamed token gets written to its
  thread as an `assistant` message almost immediately, which is exactly what
  `RestartRepository` reads as "spoke since the restart" — so a live, healthy,
  responsive agent resolves every restart before the next can accumulate
  toward the 3-strike refusal. Do not spend more time chasing this by timing
  tricks; it is an architectural property, not a flake.
- **3293 (a bad restart is visible in order)**: same limitation as above for
  the "goes quiet after" half. The "recorded in sequence on the agent's own
  thread, in order" half **is** reachable — the agent's own recollection
  (3291's check) already proves restarts land in-order, interleaved with its
  own replies, on one thread.
- **3304 (everybody carries on after the app restarts) / 3305 (a paused agent
  comes back paused)**: driven by the harness's `agents_to_restore` channel
  handshake on reconnect — there is no lighter surface. `check_machinery`
  on this box reports the harness as shared: *"4 other project(s) have
  checkouts here, so anything done to this machine takes their in-flight work
  with it."* Restarting it to observe the handshake degrades other people's
  real in-flight work. **Do not do this.** Record as partial.

## Result Path

Findings and outcome go through `create_issue` / `submit_qa_result` per the
task prompt, not a result.md file. Evidence lives in this brief's Setup Notes
and in the submitted scenario observations.

## Setup Notes

Staged working copy for this run: `687bac73-c3eb-4c51-b195-37314e033b24`
(`.claude/worktrees/qa-1014-restart-test`), agents `90465e0f...` (coding,
restart target) and `780a366f...` (qa, neighbor). Both offboarded at the end
of the session. One issue the testing itself produced as an expected side
effect of 3307 (`b8793f9b`) was dismissed with a note rather than left as
backlog noise.

Why 3292/3308/half of 3293 are unreachable live: `RestartRepository.spoke_at/1`
counts any `role: assistant` message on the agent's thread since the restart's
`inserted_at`. `Agents.write_turn_event/3` writes one the moment the harness
reports *any* text-bearing step of a turn — not only on completion. A real,
healthy `claude-code` agent starts streaming within a couple of seconds of
being sent anything, including the restart's own injected
`"Restarted: <reason>"` message, so it "speaks" (and self-resolves) almost
immediately. Reproducing "restarted and still hasn't spoken" needs an agent
that is genuinely unable to produce output — not something to manufacture on
a shared box without either damaging real infrastructure or writing directly
to the `restarts` table, which is a fixture-level move, not QA. This is
exactly what the story's own spex suite is for, and it does reach this path
(via `Fixtures.age_agent_messages` / a silent agent fixture) — that coverage
is real, it just is not reachable from black-box QA against a live, working
agent.
