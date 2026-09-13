# Qa Story Brief

Story 1014 — The main agent starts, stops and restarts its agents.

## Tool

`run_script` (Lua, calling the `main_agent` MCP tool surface directly:
`restart_agent`, `check_machinery`, `list_agent_work`, `message_agent`, plus
`create_working_copy` / `offboard_working_copy` to stage and drive real
throwaway agents). This is the actual agent-facing surface for this story —
there is no LiveView or curl-only route for `RestartAgent`; the
`McpServers.MainAgent` tools are what a real main agent calls, and
`run_script` is a first-class way to drive them directly, per `tool_docs`.

Two more surfaces are load-bearing for the criteria that were previously
marked unreachable — see Setup Notes for exactly how to use each:

- **`curl` against `POST http://localhost:4004/api/harnesses/<working_copy_id>/rejoin`**
  (local harness endpoint, port 4004) — drops and rejoins ONE working copy's
  channel, triggering the same `agents_to_restore` handshake a full harness
  restart does, without touching any other project's checkout on the box.
  This is what makes 3304/3305 testable without degrading other people's
  in-flight work.
- **`curl` against `GET/POST/DELETE http://localhost:4000/dev/faults`**
  (hosted app, port 4000, dev-only route) — `POST {"key":"<agent_id>","fault":"agent_stays_silent"}`
  makes one specific agent count as never having spoken (`RestartRepository`
  reads `spoke_at` as permanently `nil` for it), so a restart genuinely does
  not resolve itself. This is what makes 3292/3308 (and the "goes quiet
  after" half of 3293) testable against a real, live, healthy agent instead
  of only via the spex suite's DB fixtures. **Always `DELETE` the fault
  afterward** — it is a standing override, not a one-shot.

`list_issues` / `dismiss_issue` (also via `run_script`) to check the
issue-raising side of the criteria and clean up test noise afterward.

## Auth

None needed for the `run_script` / MCP surface. This QA session's own
harness/session credentials already carry a working `main_agent` MCP tool
set scoped to the real "Code My Spec" project (project
`708492f9-454e-482f-a2eb-be64f0356b87`).

The `/dev/faults` and `/dev/agents` routes (port 4000) and the `/rejoin`
route (port 4004) need no auth beyond being on localhost — they are
compiled out of release builds.

Do **not** use the qa-account / magic-link flow for the `restart_agent` /
`list_agent_work` / `check_machinery` MCP tools — they only exist on the
caller's own project scope. The magic-link flow is only relevant if you need
the `/app/.../agent-conversation` LiveView (e.g. to click the per-agent
pause toggle). If you do: log in as `johns10@gmail.com` via `/dev/mailbox`,
then switch to the **"Code My Spec" account** via `/app/accounts/picker`
(the account defaults to an unrelated "QA Account" otherwise) before
navigating to a project page. Budget extra time — this session hit both an
account-scope mismatch and an unrelated session drop trying to reach that
page; the `run_script`/`dev/*` route path below is more reliable.

## Seeds

None. Do not run `qa_seeds.exs` or touch the QA Fixture Project for this
story — restart-agent testing needs real, running agents on a machine, not
database fixtures, and this project already has them.

Instead, **stage one or two dedicated throwaway working copies** per
session:

```lua
create_working_copy({ label = "qa-1014-restart-test", roles = "coding,qa" })
```

This mints a fresh git worktree + real `claude-code`-provider agents. Get
their ids from `list_agents({})` / `list_agent_work({})`, filtered to the
new `working_copy_id`. New agents default to `continuous: false`.

**Offboard every copy you stage at the end**:
`offboard_working_copy({ working_copy_id = "..." })`. This stops the agents
and detaches the copy from the project; it does **not** delete the worktree
directory from disk — that is left for a person (`git worktree remove` from
outside this session; QA subagents cannot run git-mutating commands).

## What To Test

This is a **shared dev box** with other people's real agents doing real
work, and — as of this run — a genuinely unstable local harness process
(see Setup Notes). Only ever pass an `agent_id` to `restart_agent` that
belongs to a working copy this session created in this run.

- **3290 (acts on what it sees) / 3291 (restart carries its reason)**:
  message the staged coding agent once (`message_agent`) to establish a
  baseline reply, then `restart_agent(agent_id, reason)`. Confirm the
  response names the agent id and the reason. Then message the same agent
  again asking it to quote back, verbatim, the reason it was given for its
  most recent restart — a real agent's own recollection is strong,
  non-browser proof the reason reached its thread.
- **3302 (a fix ends there)**: restart the same agent twice for the *same*
  reason, letting it reply in between. Both restarts should succeed (not
  refused).
- **3306 (restarts one agent and nothing else)**: fire `message_agent` on a
  *different* agent and `restart_agent` on the target in the same batch (two
  independent tool calls). Confirm the other agent's turn is unaffected.
- **3307 (cannot restart the harness)**: call `restart_agent` with the
  *working copy id* (not an agent id) as `agent_id`. Must be refused
  (`:not_mine`), and `list_issues({status="incoming", scope="framework"})`
  must show a new high-severity issue naming the reason. Safe — never
  touches a real harness process.
- **3292 (repeat suppression) / 3308 (fault outlives a restart)** — **now
  reachable live.** Inject `agent_stays_silent` on the target agent
  (`POST /dev/faults`), then: restart once → `list_agent_work` +
  `list_issues(scope=framework)` should already show
  `"A restart changed nothing: <reason>"` (3308, fires on the *first*
  restart). Restart twice more (still succeeds, not yet at the limit).
  Restart a 4th time for the identical reason → must be refused
  (`{:error,{:already_tried,3}}`) and `"Restarting is not fixing this:
  <reason>"` must appear in issues (3292). **Clear the fault
  (`DELETE /dev/faults`) and dismiss both synthetic issues afterward.**
- **3293 (a bad restart is visible in order)** — **now fully confirmed live**,
  after `5066334b419a` fixed the substitution bug this story's own QA found
  (`21325686`). Stage one agent, send it a message, `restart_agent` with a
  distinct reason, send a second message, then open
  `/app/projects/<project_id>/agent-conversation?conversation=<conversation_id>`
  for that exact agent (the conversation id is on its "Open <name>" link on
  the working-copies page — it is *not* the agent id). Confirm the transcript
  renders that agent's own turns, with the restart notice interleaved in the
  correct position between the before- and after-turns. Separately, load the
  same project URL with a conversation id that resolves to nothing and
  confirm it renders an empty state ("No agent activity recorded..."), never
  a different agent's thread. Account-switching is no longer needed — the
  fix corrected the substitution itself, not a scope staleness (the account
  the QA login lands on now shows "Code My Spec" as Current by default in
  this pass, for whatever that is worth).
- **3304 (everybody carries on) / 3305 (a paused agent comes back paused)**
  — **now reachable live without degrading other projects.** Stage two
  agents (or two copies): one left at default `continuous: false`
  ("paused"), one flipped to `continuous: true` via
  `POST /dev/copies/:id/continuous {"continuous":true}` ("working"), each
  with at least one real message on its thread. `POST` the per-copy
  `/rejoin` endpoint (see Tool section). Confirm via
  `GET http://localhost:4000/dev/agents` (before/after) that `continuous`
  round-trips correctly per agent, and via `curl localhost:4004/health`
  that **only** the rejoined copy's `joined_ago_s` resets while every other
  root's keeps aging — that isolation claim is exactly what makes this safe
  to run on a shared box. Also acceptable as evidence: a real, unplanned
  full-harness restart happening during the session (watch
  `~/.codemyspec/harness.log` for `SIGTERM received` / a new `inst=`) —
  every previously-running agent on the box should show up as `"restored
  agent <id>"` afterward, with `continuous` unchanged.

## Result Path

Findings and outcome go through `create_issue` / `submit_qa_result` per the
task prompt, not a result.md file. Evidence lives in this brief's Setup
Notes and in the submitted scenario observations.

## Setup Notes

**2026-09-13, follow-up pass (this attempt).** Focused entirely on closing
3293, per the fix at `5066334b419a` (issue `21325686`). Staged one throwaway
working copy (`8ea5c1a3-0dd4-40c1-893f-32259b682104`, agent `cea4be15`,
"opal-orchard"), sent it `turn-one-before-restart`, restarted it with a
distinct reason, then sent `turn-two-after-restart`. Logged in via magic
link and opened
`/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/agent-conversation?conversation=<its conversation id>`
(found via the working copy's "Open opal-orchard" link, not guessed):
the transcript rendered that agent's real turns in order — `turn-one-before-restart`
→ the `Restarted: <reason>` notice → the agent's own reaction and tool calls
→ `turn-two-after-restart` — settling the ordering half live rather than by
recollection. Then loaded the same project URL with a random UUID as
`?conversation=`: rendered "No agent activity recorded for this project yet.",
not a substituted thread. Both halves of 3293 pass. Offboarded the working
copy afterward (worktree left on disk per convention).

**New finding, not attached to this story**: while confirming 3293 I had two
real projects in one account in front of me (as issue `4a470cc3` asked for)
and used them to settle its unproven reading. Loading the *same* conversation
id under a **different** project's URL, same account, rendered that other
project's agent transcript in full — tool calls included — rather than
nothing. Filed as `7dbf9709-f0ab-4368-b214-907484641590` (high, scope app),
confirming `4a470cc3`. This is a pre-existing gap in
`Conversations.get_agent_conversation_by_id/2` (scopes on `account_id`, not
`project_id`), not a regression from `5066334b419a`, and not part of story
1014's own criteria — left unattached to this story's release gate.

**Prior run (2026-09-13, earlier the same day).** Staged working copies
`92b07035-5800-49a9-8264-0be9c7fb9aed`
(`qa-1014-restarts`, agents `43a2cf7c...` coding / `82bab1c6...` qa, both
`continuous: true`) and `72b8cd0b-debd-439f-9137-2c42afbf07f1`
(`qa-1014-paused`, agent `a75ba956...` coding, `continuous: false`). Both
offboarded at the end of the session; the worktree directories are left on
disk for a person to remove.

**The local harness (port 4004) was unstable throughout this run.** It
SIGTERM'd and relaunched the *entire* fleet on this machine three times in
about 15 minutes (`~/.codemyspec/harness.log` `inst=` went
83899→95176→2367→19964→21242), each time stopping and then restoring every
agent on every project on the box, not just this session's. The long-lived
brew `codemyspec` service (pid 20889, separate from the dev-mode `mix run`
harness above) independently logged repeated 403 websocket-upgrade
disconnects from the CodeMySpec server in the same window. Root cause not
established — it did not track cleanly with this session's own
`create_working_copy` calls (one restart happened while this session was
idle). Reported to the team lead live; treat as a standing framework/ops
concern for future QA passes on this box, not specific to story 1014's
code.

Three findings this run (all filed via `create_issue`, ids in
`submit_qa_result`): the harness instability above (framework, high); an
`os_pid`/OS-process framing correction to issue `e9f9a5ab` (framework docs);
and none new on the app itself — all ten criteria are covered by live
behavior this session, either passing cleanly or (3293's full-order half)
falling back to the story's own spex coverage for the exact reason recorded
in that scenario's observation.

Why 3292/3308 needed `/dev/faults` at all: `RestartRepository.spoke_at/1`
counts any `role: assistant` message on the agent's thread since the
restart's `inserted_at`, and a real, healthy `claude-code` agent starts
streaming within seconds of anything sent to it — including the restart's
own injected `"Restarted: <reason>"` message — so it "speaks" (and
self-resolves) almost immediately without the fault. `Faults.active?/2`
short-circuits that read to `nil` for one keyed agent id, which is exactly
the lever needed and nothing more.
