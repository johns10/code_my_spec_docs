# Agent liveness from Presence — retire the persisted `status`

## Decision

Whether an Alloy agent is running is a fact about a process on the harness,
not a record. Read it from Phoenix Presence, which is true while the process
lives and false the instant it or its harness dies. Persist only **intent**.

| Fact | Today | After |
|---|---|---|
| Agent exists, role, working copy | `agents` row | `agents` row (unchanged) |
| Someone turned it off | `off_at` / `off_by` | unchanged |
| Retired | `retired_at` | unchanged |
| Process is alive | `status` (`:starting`/`:running`/`:stopped`), polled | **Presence** on the copy's harness channel |
| Turn in flight | `turn_started_at`, written per event | unchanged in this plan (see Phase 3) |

"Starting" becomes derived: on duty (not off, not retired) and not present.
"Stopped" becomes: not present. Neither is stored.

External (Claude Code / hooks-only) agents are out of scope. They have no
process on the harness and will be made first-class separately. Until then
they keep their current "last heard from" display and are never present.

## Why

The server (:4000) cannot call `Process.alive?` on a harness pid — different
BEAM. So today the harness pushes `agents_running` with `Engine.running()`
every 60s (+15s after join, `channel_client.ex:862-918`), and the server
copies it into `status` via `Agents.record_running_on_copy/3`. Agents are
`restart: :temporary`, so a death sends nothing; `status` is up to a minute
wrong. A stack of code exists to manage that staleness: the 15s join delay
(`34e03128`), reap/settle (`settle_against/3`), `@running_afresh` clearing,
the `turn_started` race on a reaped row (`4ce6d903`), and the `Liveness`
module explaining how old its evidence is.

Presence removes the copy. A channel process tracks keys; when the channel
dies (harness exit, socket drop) every key it tracked leaves automatically.

## Design

### Harness side (`lib/cms_harness`)

1. `ChannelClient` monitors each agent it starts or restores
   (`Engine` registry pid). On start confirmed: push `agent_up`
   `%{"agent_id" => id}`. On `:DOWN`: push `agent_down` `%{"agent_id" => id,
   "reason" => ...}`.
2. On (re)join, push the current set once: `agents_present`
   `%{"agent_ids" => Engine.running()}` — the channel is fresh and tracks
   nothing yet. This replaces the 60s `agents_running` timer and the 15s
   post-join delay; delete both.

### Server side (`HarnessProjectChannel`)

3. `agent_up` → `Presence.track(self(), presence_topic(project_id), agent_id,
   %{working_copy_id: ..., since: now})`. `agent_down` → `Presence.untrack`.
   `agents_present` → track each id not already tracked by this channel,
   untrack any this channel tracks that are absent.
4. Topic: `"agents_presence:#{project_id}"`, key: agent id. One topic per
   project so a page or a context function can `Presence.list/1` once.
5. Only track ids that belong to this channel's working copy and project
   (fetch through scope); ignore others with a warning log.

### Agents context

6. New `Agents.Presence` (or functions on `Agents`) that wraps
   `CodeMySpecWeb.Presence` behind the boundary:
   `present_ids(scope) :: MapSet.t()`, `present?(scope, agent_id)`,
   `subscribe(scope)`. The context must not depend on the web app directly —
   follow whatever pattern the boundary allows (a behaviour/callback set at
   boot, or move the Presence module under `CodeMySpec`). Check `Boundary`
   config before choosing.
7. A derived lifecycle for display and decisions:
   `Agents.lifecycle(agent, present_ids) :: :running | :starting | :off | :retired`
   — `:retired` if `retired_at`, `:off` if `off_at`, `:running` if present,
   else `:starting` (on duty, not present: requested, restoring, or crashed and
   awaiting restore).

### Replace every `status` read

Each of these switches to presence + intent. Grep `status` against agents
again before starting; this list is from 2026-10-04.

- `agents/work.ex:163,199,748` — "running and no turn" → present and
  `turn_started_at` nil.
- `agents_repository.ex:51,79,116,190,242,289,298` — queries filtering on
  `status`. Become intent filters (`is_nil(off_at) and is_nil(retired_at)`),
  with presence applied in Elixir where "actually up" matters. Rename
  `list_running` to what it now means.
- `agents.ex:280` `stopped_holder/3`, `agents.ex:1324`
  `reaped_and_continuous?/2` — restart-on-join logic. With presence, the
  harness's restore (`agents_to_restore` → `list_on_duty`) already brings back
  every on-duty agent; check whether these are still needed at all.
- `agents.ex:405,493,1738` — slot occupancy / role filled.
- `agents.ex:2898` (`record_reported/2`), `2941-3000`
  (`record_running_on_copy/3`, `settle_against/3`, `@running_afresh`) —
  delete. `tell_main_reaped/2` moves to the `agent_down` handler (a down the
  operator did not ask for is the "reaped" signal).
- `notifications.ex:231` `stopped_agent_ids/0` — subquery on status; needs a
  different shape (filter in Elixir by presence, or by intent if "stopped"
  there really meant "off/retired" — read the caller).
- `dev_state.ex:414,427`, `agents/wake.ex:218`, `agents/main/digest.ex:124`,
  `agents/main/agent_work.ex:142`, `mcp_servers/agents/agents_mapper.ex:72`.
- Web: `agent_conversation_live/show.ex:330,602`,
  `working_copy_live/show.ex:350`, `working_copy_live/liveness.ex`.
- Writes: `agents.ex:748,2974,3066,3271,3501` — remove.

### Turn-off / stop

`turn_off_agent` today waits for the harness to confirm the process ended,
then writes `:stopped`. Keep the confirmation round-trip; drop the write.
The `agent_down` that follows untracks it. `off_at` remains the intent.

### UI

- `Liveness.agent/2` reads the derived lifecycle. Labels: Running / Starting
  / Off / Retired. No more "since"/"basis" for Alloy agents — presence is
  current, not evidence of an age. Keep "Last heard from" for non-Alloy.
- LiveViews that show agents subscribe to the presence topic and refresh on
  `presence_diff` instead of `:agents_reported`.
- The cockpit's turn indicator (pulsing bubble on `turn_started_at`) is
  independent and stays.

## Phases

1. **Presence tracked alongside status.** Harness pushes `agent_up` /
   `agent_down` / `agents_present`; channel tracks. Nothing reads it yet.
   Verify in the browser and logs that presence matches `Engine.running()`
   across start, crash (kill an agent pid), turn-off, harness restart.
2. **Readers switch.** Replace every `status` read above with presence +
   intent. Delete the 60s timer, `record_running_on_copy/3`,
   `record_reported/2`'s reconcile, `settle_against/3`.
3. **Column goes.** Migration drops `status` (and `stopped_reason` if nothing
   left reads it; check `os_pid`/`os_boot_id` too — they described an OS
   process the supervised GenServer no longer has). Follow the migration
   rules: no defaults, check legacy NOT NULL handling.
   Optional follow-up, not required here: carry turn state in the presence
   meta (`Presence.update` on turn start/end) and stop persisting
   `turn_started_at`. `Work.record_decline/3` reads it at turn end, so that
   needs the start time passed in the `turn_ended` event first.

## Tests

- Channel tests: `agent_up` tracks, `agent_down` untracks, channel exit
  untracks all, `agents_present` reconciles both directions, a foreign
  working copy's id is ignored.
- Harness tests: a monitored agent dying pushes `agent_down`; rejoin pushes
  `agents_present` with the live set.
- `Work` admission: an agent that is on duty but not present is never offered
  work; present + no turn is.
- Existing cockpit/working-copy LiveView tests updated to drive presence
  (track from the test process) instead of writing `status`.
- No sleeps. Presence diffs are async — assert with `assert_receive` on the
  `presence_diff` broadcast before checking the view.

## Risks

- **Presence across nodes.** If :4000 ever runs clustered, Presence is a CRDT
  over PubSub and still correct; a netsplit shows agents as absent, which is
  the honest answer.
- **Restore window.** After a harness restart nothing is present until agents
  come up. Anything that reacted to `:stopped` by restarting (the reap paths
  above) must not fire on mere absence, or it will double-start. The
  harness's own restore is the one restart path.
- **Main agent.** `agents_repository.ex:190` finds the main agent by status.
  Make sure the main agent is tracked like any other lane, or that finder
  breaks silently.
