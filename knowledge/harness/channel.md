# The harness ↔ server project channel

How a harness serves a working copy over one Phoenix channel per checkout — the
design behind `lib/cms_harness/project/*`, `CmsHarness.Projects`,
`CmsHarness.ProjectIdentity` and `CodeMySpecWeb.HarnessProjectChannel`, and the
lessons that shaped it. Code comments point here by section name.

| Module | Role |
|---|---|
| `CmsHarness.Projects` | Starts, stops and rejoins one subtree per served working copy, keyed on its root. |
| `CmsHarness.ProjectIdentity` | Answers "which project is this directory" from the copy's own files. |
| `CmsHarness.Project.ChannelClient` | The harness end: a Slipstream client per copy; joins, pushes manifests and results, answers server-initiated work. |
| `CmsHarness.Project.Watcher` | Per-copy filesystem watcher; runs only while the channel is joined. |
| `CmsHarness.Project.AnalysisServer` | Per-copy analyzer queue: one run at a time, every request answered. |
| `CodeMySpecWeb.HarnessProjectChannel` | The server end: authorizes, registers the copy's executor, reconciles manifests, decides hooks, relays work to the machine. |

## Projects and working copies

- **One subtree per working copy, keyed on its root**, under the copy's own
  `Copy.Supervisor` beside its agents and app. Two checkouts of one project are
  two subtrees and two channels; the project id names only the channel topic.
- Registry keys (`{:channel, root}`, `{:watcher, root}`, `{:analysis, root}`)
  are all roots. Keying on the project id handed a second checkout the first
  one's channel, queue and watcher while every health check said served.
- Subtrees start on demand: a hook names a harness id and
  `CmsHarness.WorkingCopies` asks the server where that copy is.
  `Projects.start_configured/0` serves `CMS_PROJECT_DIR` at boot for a sprite,
  whose agent waits for an accepted manifest before it starts — no hook would
  ever arrive.
- Only the server's device roster decides which roots are served after a
  restart; a remembered path must not re-onboard a copy removed while offline.
- `stop_serving/1` (offboard) stops the whole copy; `rejoin/1` drops only the
  channel chain and serves again, which re-runs the `agents_to_restore`
  handshake for one copy without touching others.

## Project identity

- Resolution: `project_id` in `.code_my_spec/config.yml`, then in
  `.cms_harness.json`, then refuse. No environment fallback.
- `working_copy_id` and `preview_url` always come from `.cms_harness.json`
  (the only file onboarding writes them to). `nil` working copy id means "not
  issued yet"; the first join mints one and the client writes it down.
- The client never adopts a different id from the server: rows are filed under
  the id on disk, and adopting would orphan them. A disagreement is logged.
- A YAML parse that fails while the VM is stopping is `{:error, :restarting}`,
  not malformed config (`:yamerl` start exits during shutdown).

## Joining

- The join payload carries: `harness_id`, `root`, `preview_url`, `device`,
  `machine_tools`/`machine_tool_docs`/`browser_status`, `instance`
  (`host:os_pid`), `active_runs`, `app`, `app_verbs`, `contract_version`.
  Each additive field's absence means "an older harness", never a failure.
- The server registers the copy's executor in `HarnessRegistry`. A different
  `instance` on the same copy is refused `working_copy_in_use` (one `_build`);
  the same instance takes its own registration. One instance presenting one id
  for two roots is refused `harness_id_collision`, never evicted.
- On join the server fails in-flight runs not claimed in `active_runs`, then
  `Analysis.resume_orphaned/2` reopens claimed ones and re-runs the rest.
- **Backoff** is `[1s, 2s, 5s, 10s, 30s]`, and `attempts` resets only when a
  read model is handed over, not on join. A join followed by a refused push is
  not a working connection.
- A refused join retries forever at the capped backoff; the first
  `@refusal_retries` are quiet (an ordinary restart handover). `:refused` is
  for `/health` only and never gates reconnecting.
- Each dial has a join deadline (`@default_join_timeout`): Slipstream times
  neither the websocket upgrade nor the join reply.
- A missing credential is recorded (`no_credential?`) so hooks report it rather
  than "channel down"; it is not retried.

## Contract version

- `@contract_version` exists on both ends; a test compares the two functions,
  never a literal.
- Bump only for a change to the join payload, the `handle_in` set, or their
  shapes. Additive events need no bump: the other side answers
  `unknown_event`, which names the skew.
- A mismatch is refused at join with both numbers. A harness that sends no
  version is allowed and logged once.
- Verbs newer than the contract (`reload_app`) are declared in `app_verbs`; the
  server pushes them only to a harness that declared them.

## Unmatched topic and silence

- A reply of `unmatched topic` while the client believes it is joined means the
  server lost the channel without a close. The client drops the **socket**,
  not the topic: Slipstream still thinks the topic is joined, so `join/3` would
  be a silent no-op. `handle_disconnect/2` then runs the normal reconnect.
- Two consecutive unanswered hook decisions (`@silence_limit`) drop the socket
  the same way; nothing else would report a channel carrying no traffic.
- A read-model refusal as unmatched stops the refresh timer until the next
  join and is logged loudly once, quietly after.
- An `observations` reply of unmatched topic is ordinary shutdown, logged at
  info.

## Manifests

- The harness sends the whole manifest, never a delta: a delta cannot tell a
  deletion from an omission. No file content crosses; only the validation
  verdict.
- An empty manifest is never sent and is refused by the server: reconciling it
  would delete every file row, and "found nothing" looks like "did not run".
- The server validates the whole manifest before writing (unknown roles,
  unparseable or non-microsecond mtimes) and rejects it whole with reasons.
- The server replies `accepted` immediately and reconciles in a task: one in
  flight, one pending, newest wins. Two at once would delete each other's
  files. `reconcile_and_project/2` also writes `component_id` onto File rows,
  in one transaction.
- `terminate/2` kills the in-flight reconcile; `ReconcileRegistry` catches an
  orphan from a channel that died without terminating, and the new reconcile is
  skipped (with a warning) rather than stacked.
- A manifest received is proof of life (`WorkingCopies.mark_alive/1`).
- Manifests and results produced while disconnected are dropped, not queued;
  the rejoin's rescan and re-run recover them.
- The read model refreshes every 60s; a refresh scans only if the read model
  changed. The join's read model always triggers a scan.

## File watching

- The watcher runs only while joined: a disconnect stops the underlying
  `FileSystem` process, and `resume/1` (synchronous, before the post-join scan)
  starts a fresh one so no write falls between stream and scan.
- Watched: `lib/`, `test/`, `.code_my_spec/`. Root files (`mix.exs`, etc.) are
  picked up by the next sync. Paths are screened with `Scanner.ignored_path?/1`.
- Events debounce into one scan (2s). There is no periodic sync.
- The liveness check only logs when a watching stream delivers nothing for 5
  minutes; it never scans. A file event from an untracked pid is logged.

## Analysis queue

- One run at a time per copy (shared `_build`), machine-wide slots from
  `AnalysisSlots`. The kill timer arms on `:slot_acquired`, not dispatch.
- Order: cheapest first among entries that arrived together
  (`compiler < credo < exunit < spex`), never ahead of an entry already
  waiting (`settled`), so cheap requests cannot starve spex.
- At most two entries per source: the running one and the next. A request for
  a queued source ties onto it; the next run's args become the union (empty =
  whole suite). Every tied run id receives the same real result; `tied_to`
  marks non-owners so Problems are reconciled once.
- A run id already held is ignored (the server re-sends joined runs).
- Every request is answered: success, error, timeout, task death, `:busy` and
  `cancel/2` all push a result. Results carry `args` actually run,
  `completed_commit`, and `analyzer_staleness`.

## Server-initiated work

- Server → harness pushes: `run_analysis`, `cancel_analysis`, `rescan`,
  `offboard`, `interrupt_turn`, `fs_request`, `create_working_copy`,
  `start_agent`, `stop_agent`, `mailbox_delivery`, `request_work_turn`,
  `ensure_app_running`/`restart_app`/`reload_app`/`stop_app`, `tool_call`.
- Each request carries a `ref`; the harness answers on a `*_result` push and the
  server replies to the parked `from`. Unknown refs are dropped.
- `fs_request` is scoped to the channel's own root and answered inline.
  `promotion_*` ops name a root in the payload, checked against
  `Projects.list/0`, and run in a task. There is no general `cmd`.
- Anything slow (launches, app verbs, tool calls, checkout creation, promotion)
  runs in a task on the harness: the channel process carries every hook
  decision.
- Unknown events and fs ops are answered with an error, never ignored.

## Deferred replies

- Server handlers that can take long or read files run via `reply_async/4`:
  `hook_decision`, `skill_start`, `analysis_result`, `analysis_run`,
  `analysis_wait`, `promotion_run`.
- Reason: their work reaches back into this channel with
  `{:fs_request, …}`; doing it inline is `:calling_self`, which a caller reads
  as a missing file.
- `Task.Supervisor.async_nolink/2` monitors at spawn. The result message is
  delivered and the entry removed; a `:DOWN` that still finds an entry is
  answered `handler_died`. One reply per request, decided in the channel.

## Reconnect sweep

- `agents_present` on join and the copy's first `agent_up` after it each
  trigger one sweep (`consider_once/2`): `Work.consider_copy`,
  `resume_held_tasks`, completion handoffs, refusal wakes and the main agent's
  cadence. Work triggers are edge-based and a restart is no edge.
- Run in a task: the sweep reaches this copy's holder, which is this channel.
- Presence: the channel tracks agents in `Agents.Presence` while the harness
  says they are up; Presence drops them when the channel dies.

## Lessons

- **Key per-copy state on the working copy, never the project.** Two checkouts
  resolve the same project id.
- **Identity comes from the copy's own files, never the environment.** An
  inherited variable belongs to whatever launched the daemon and answers for
  every root it serves.
- **Reset backoff on proof of work, not on join.** Resetting on join produced a
  once-a-second join loop that rotated away the logs needed to debug it.
- **When the server says the topic is gone, drop the socket.** A topic rejoin
  is a no-op while Slipstream believes it is joined.
- **Nothing on the channel process may wait on the channel.** Any handler that
  reads files or calls back into the channel runs in a task.
- **Every request gets exactly one answer.** Silence reads as latency; a second
  answer contradicts the first.
- **Never call a success a rejection, or vice versa.** Match "accepted" before
  the catch-all, and do not guess causes in a rejection message.
- **A refusal that clears on its own must be retried forever.** Giving up made a
  harness stay dead across a server restart.
- **Additive fields need no coordinated rollout.** Absence means older peer;
  bump the contract only for breaking shape changes.
- **Encode for the wire defensively.** Raw binaries and structured error maps
  must be encoded explicitly; a raise in an encoder kills the channel and looks
  like a transport failure.
