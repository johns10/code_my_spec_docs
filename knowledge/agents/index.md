# Agents core

Main's resource access is separate from its runtime home: see [working-copy attachments](attachments.md).

How the server runs the agents that work a project: which agents exist and on
which checkout, how they start, stop and restart, how the main agent watches
the fleet and settles questions, and how work is offered and admitted as
turns — the design behind `lib/code_my_spec/agents.ex`,
`lib/code_my_spec/agents/main*` and `lib/code_my_spec/agents/work.ex`, and the
lessons that shaped it. Code comments point here by section name.

| Module | Role |
|---|---|
| `Agents` | The context: agent rows, start/stop/restart/retire, messaging, turn events from the harness, the harness's running-agents reconcile, model settings. |
| `Agents.Main` | The main agent's position: fleet view (`list_agent_work`, `check_machinery`), restarts with reasons, question holding, answering and escalation, conversation reads. |
| `Agents.Main.Cadence` | One timer per project that wakes the main agent with a digest. |
| `Agents.Work` | Eligibility and atomic turn admission: what an agent may be offered, the decline damper, `work_for/4`. |
| `CmsHarness.Agents` | The other half, on the device: the OS process, reached over the harness channel. |

## Starting and restarting

- **Credential first.** `start_agent/2` resolves the credential before it
  creates anything. `:not_connected` (connect a provider) and
  `:reconnect_required` (reconnect one already connected) stay distinct
  because their remedies differ.
- **Rows are intent.** A row is recorded `:starting`; it reads as running only
  when its process is present (`Agents.Presence`). `launch/2` is best-effort:
  an offline machine leaves the row `:starting` and returns `{:ok, agent}`,
  because copies are staffed before they join the harness and the machine
  reconciles to rows afterwards (`agents_to_restore`).
- **The conversation is opened at start**, keyed on the agent id — never on
  the working copy, which runs several agents. A new row is a new, empty
  thread.
- **A stopped holder is resumed, not replaced.** Starting a role on a copy
  where a stopped (not present, not retired) agent of that role still holds
  active or blocked tasks restarts that agent instead. Task ownership is which
  row's embedded list a task sits in; moving tasks between rows mints new ids
  (`embeds_many ... on_replace: :delete`) and orphans the blockers keyed on
  them (`question_requests.task_id`). Promotes restart the shared dev server
  and so routinely kill agents mid-task.
- **`restart_agent/2` re-runs only the launch half** on the same row: fetch a
  credential, hydrate the recorded history, ask the machine to run it. It
  recomputes `tools`, so a grant added since start reaches the agent; it
  clears `turn_started_at` and `stopped_reason`; and a turn that was open
  carries on (`Mailbox.carry_on/2`) before anything queued.
- **A restart stops the live process first** (`halt_for_restart/1`). The
  harness answers a start for an already-running agent with the live process,
  so without the stop a restart of a hung agent changed nothing while
  reporting success. The stop asks unconditionally — not through
  `end_process/2`, whose result is ignored for an agent that is not present:
  row status and Presence can lag a real process, and launching beside a
  survivor collides and strands the row at `:starting`.
- **Destination before guards.** Where the agent will run is resolved before
  any seat check (`put_destination/2`). An id is authoritative and must belong
  to the project; a root resolves to its copy's id; an unknown root (a checkout
  that has not joined) falls back to the caller's copy with a logged warning,
  since the stop decision and analyzer alerts are computed from that id.
- **Seats.** One agent per role per checkout. The main copy holds only the
  roles that live there (main and product), one each. An off agent holds its
  seat; a retired one does not.
- **A machine serving no tools is refused.** `machine_tools: []` means the
  machine answered with nothing and every call would fail; `nil` means the copy
  has not joined yet and is allowed.
- **Tools are derived per call** (`tools_of/2`) from the role's grants plus,
  for roles that browse, the tool names the copy's machine reported. The row's
  `tools` is a record of what it launched with, not what is enforced.
- **Coming up.** `came_up/2` (from `agent_up`) resumes a held task or offers
  work; `Work.consider_project/2` is edge-triggered and a process coming up is
  not one of its edges. `process_ended/3` acts only on the harness's Keeper
  giving up on a crash loop, telling main.

## Timeouts

- `@message_timeout_ms` (15s) is how long a send waits for admission before
  answering `:still_working`; the agent is not interrupted.
- `message_agent` is reachable only through `run_script`, so every call runs
  inside the code-mode sandbox's 30s wall clock (`Task.shutdown(:brutal_kill)`).
  The HTTP side is not the cap: `/mcp/harness` carries a 5-minute
  `request_timeout`. A 25s wait left too little margin and surfaced as a raw
  sandbox kill, indistinguishable from a broken tool.
- `@start_timeout_ms` (15s) bounds asking a machine to start an agent;
  `@stop_timeout_ms` (10s) bounds asking it to stop one.

## Stopping

- **Off is the only deliberate stop**, and it is intent: `off_at`/`off_by` are
  recorded before the process is asked to end, so an unreachable agent is still
  off — `Transport` delivers nothing to it and nothing restarts it until
  `turn_on_agent/2`. Start, restart and message refuse an off agent; they never
  turn it on implicitly.
- **`end_process/2` always asks the machine.** An agent not present has no
  process to end, so an unreachable machine does not fail the stop; for a
  present agent the machine's answer stands. `:not_running` is a satisfied
  stop. `:harness_not_connected` on a copy that no longer resolves (offboarded,
  scratch path) is also stopped — nothing can hold a process there.
- **`record_stopped/3` only after the process is confirmed gone**: until then
  `os_pid`/`os_boot_id` are the handle. It clears `turn_started_at` and
  abandons turn requests (left standing, a returning agent is unadmittable),
  and never touches tasks — a claim is about work, not a process.
  `stopped_reason` tells `:reaped` (a report stopped mentioning it) from
  `:stopped` (somebody asked).
- **Retire** is permanent: open tasks are cancelled on the retired row (they
  would keep requirements claimed against the seat's next agent), pending
  questions move to a successor (same role on the main copy, else any on-duty
  same role, else main) with a schemaless update because `Notifications`
  depends on `Agents`, and the seat is freed even if the machine is
  unreachable (`{:ok, agent, {:unreachable, machine}}`).

## The harness reconcile

- `record_reported/2` takes the device's `agents_running` report as the
  authority: it is a projection of Presence on the lane topics, so a dead
  process is simply absent. No report is not a report of absence.
- Reported agents with no row are adopted, keyed on the reported working copy
  id (reported paths drift; the device knows the id it holds) and the role,
  compared as strings — `agents.role` is an `Ecto.Enum`, the wire carries a
  string.
- Listed agents the report omits are reaped, and main is told once per sweep.

## Turn events

- Steps are written on arrival, so a failed turn has already left everything
  it did. Textless events are dropped; tool calls are recorded as
  `tool_calls` and results paired by call id; compactions go to their own
  checkpoint table, never the transcript.
- `turn_started` sets `turn_started_at` (a duplicate keeps the first) and
  writes the step. `turn_ended` clears it (read first), records the decline
  before the stop menu runs, settles offers, reports held-back work, then
  either pumps the mailbox or runs `StopDecision.deliver/3`. A turn ending
  starts no analysis.
- Deaths, step-limit cut-offs and failed turns are told *to* the agent as
  operator lines, never written as the agent speaking. A failed turn that was
  neither a provider refusal nor a timeout is re-offered once with its request.
- Sends from inside the harness channel go through a task: a send is a call
  into that same channel, which the transport refuses rather than deadlock.
- Only `write` and `edit` calls are recorded as the agent's edits, on the call
  (an agent under Alloy fires no PostToolUse, and a stop's in-process
  validators read these files).

## Messaging

- `dispatch_message` checks `Wake`, then the turn cap, then commits message,
  offer and mailbox entry in one transaction before any transport work. A
  timeout leaves delivery pending; only a definitive failure marks it failed.
- `send_now` moves a queued message to the front and interrupts a busy turn.
- The turn cap applies only on the platform's credential (asked by provider,
  not engine), per turn at dispatch, counting the operator's messages.

## Continuous mode

- Set per copy (`set_copy_continuous/3`); each agent keeps its own column.
  Stopped agents are left alone.
- Switching on ensures the graph watcher and the main cadence, asks the copy's
  harness to rescan, and offers the copy's agents a turn. Nothing polls, so the
  flag alone would leave idle agents idle. The rescan matters because the
  project chain gates on verdicts decided at scan time (`personas_complete`
  gates `stories_exist`), so an unscanned copy has an empty actionable set for
  every role; only the harness has the files.
- `set_agent_continuous/3` also clears the agent's last decline: a person
  switching it on is telling it to work. Its answer distinguishes a turn
  admitted from no work found.

## Providers and models

- An explicit model setting wins and its model is recorded on the row. A
  setting naming a provider no longer connected falls back to the defaults;
  settings are never deleted on disconnect.
- With no setting, the main agent takes the first connected provider in
  `@provider_preference`, flat-rate before metered, so an always-on agent does
  not bill per token by default. `Defaults.for_role(:main)` leads with
  `anthropic` instead. The disagreement is deliberate pending a per-location
  answer: a subscription credential is not licensed for server-run agents, so
  a cloud-run agent needs an API key while a local one should spend the
  subscription.
- `connected_providers/1` asks `Credential.fetch/2`, the same question the
  launcher asks.

## The cadence

- One `Cadence` GenServer per project, started on demand (main agent start,
  continuous switch-on, boot seeding from on-duty main agents, the cadence
  tool). Timers are in memory; boot re-seeds them.
- Each tick builds the digest and calls `Main.cadence_check_in/3`. A
  continuous, idle main gets a turn only for eligible work or something needing
  attention; every other agent gets the recovery check. Main is excluded from
  the recovery check, so one tick is at most one turn for it.
- The interval is a floor, not a schedule: questions are pushed when raised.
  It is a per-project configuration row.
- `running?/1` is intent (not stood down); `alive?/1` is whether a timer
  exists. They disagree in exactly the case worth catching.
- Standing down stops main's turns from the timer, not question delivery.
  `resume/1` runs when a main agent starts, before `ensure_cadence/1`, so the
  timer that comes up will deliver; boot never resumes.
- A digest that cannot be built is raised as a fault, never rendered as an
  empty all-quiet report.
- Stalls are announced on the transition into stalled, once.

## Questions

- A question has a holder (`main_agent`, `product_agent`, `user`). An agent's
  question goes to the answerer it names (`to:`, or `about: "criteria"` for
  product), main by default, the other answerer when that one is not on duty,
  and the user when neither is. Main's and product's own questions go to the
  user.
- Escalating moves the holder and records the reason; it never closes the
  question. Deleted, main would see its own escalations forever; answered, the
  person's question would vanish while they read it.
- Escalation sends the asker nothing: a message to an idle agent starts a
  turn. The asker learns through `check_answer`.
- The open queue unions questions and permissions; permissions are settled
  only by `decide_permission/4`.

## Answering questions

- Every basis is verified, because main is rewarded for answering:
  `record` — the answer names something the project records (a ready story
  without an epic, a checkout root or id, an issue title or short id, a
  resolved question on the asker's story), with needles of at least 8
  characters; `precedent` — the cited id is an answered question (its text need
  not match); `inspected` — the citation appears in the answerer's own session.
- An answer that does not stand up escalates to the user and still returns the
  error, so main does not believe the asker is unblocked.
- The product agent answers the questions it holds as their owner, unweighed.
  A question routed straight to the user is refused unless main escalated it.
- `on_behalf_of` + `tool` is refused when that role does not carry the tool.
- `worked_around` records a capability gap per role and files one issue, with
  the count in its description (an issue update cannot change its title).
  Gap bookkeeping failures are logged, never returned.

## Restarts and faults (main)

- `Main.restart_agent/3` requires a reason. It refuses a non-project id
  (raising an issue: a harness restart would take every checkout on the
  machine), refuses when the machinery serves no tools, and refuses after
  `@restart_limit` (3) unresolved attempts for the same reason.
- Faults are framework issues, filed once while an issue with the same title is
  open; the reason is in the title because `list_issues` shows titles.
- Reading `list_agent_work` settles restart records and raises a fault for a
  restart that changed nothing — looking is when it is noticed.

## Offering work

- `request_turn_if_runnable/4`: re-read the agent, admit (idle and `Wake`
  allows the event), compute the offer, skip a damped repeat, take the turn
  request under a row lock (`Offers.dispatch/3`), recompute the offer under
  that lock (a stale subject withdraws), record the prompt on the transcript,
  then hand the turn to the harness. A turn the harness will not take leaves its
  offer undelivered.
- Idle means present, no turn open, no turn in flight, a copy, and no active
  task — except a promotion task waiting on its queue candidate.
- Offer subject order: a released task (only once the agent holds no active
  task), then the head of `get_next_requirement`, then main's questions.
- Each kind has an escalation ladder in `Offers`: requirement work
  `[:detail, :alternatives, :held_back]`, a released task
  `[:remind, :held_back]`, questions and a denied tap-out `[:held_back]`. Work
  held back is withheld from that agent alone and main is told once.
- A correction must be the turn prompt (`offer_turn_with/5`), not a recorded
  message: an agent reads its history as something said earlier and answers
  past it.
- Prompts name only tools on the agent's direct surface, and say when a tool
  is reached through `run_script`. An agent told to call a tool it does not
  carry reports the failure and stops.
- An agent holding a task with no turn open is stranded; `resume_held_tasks/2`
  (on reconnect) and `resume_held_task/2` (on `agent_up`) offer it the task
  back.
- `subject_key` for a story uses its public number, never the database id.

## The decline damper

- `record_decline/3` runs at turn end. A turn declined only if the agent holds
  no task, closed no task during the turn (a cancel does not count), and was
  not refused by the provider. No turn start time counts as having worked.
- Only questions-only offers are damped by the fingerprint: held after one
  decline for as long as the set is unchanged. Graph work goes through the
  ladder instead.
- The fingerprint is a hash of the sorted offer; `@max_repeats` (5, matching
  `StopDecision`) and `@decline_ttl_seconds` (600) bound graph-work repeats in
  `already_declined?/3`, read by `work_offered?` and `damped/3`.
- Only refusals count — delivery failures are undelivered offers.
- A person answering a gate (a denied tap-out, switching continuous on) clears
  the decline.

## Story binding

- `work_for/4` is the one answer to "what can this role do next here", read by
  the turn offer, the stop menu, `get_next_requirement` and `start_task`.
- Issue work (the copy's assigned issues, the agent's own issue, or a freed
  issue team) bypasses the graph. `story_actionable/4` skips that bypass for
  resume checks on existing story tasks.
- A team member (coding, QA) holding a `story_id` is bound: offered that
  story's work only. Main reads none; product and sessions read their copy's
  team story.
- Reading never moves a team. A team keeps its story until it lands; the
  landing tells main the team is free, and main assigns the next story
  (`set_active_story`). `Assignment.advance/4` still locks the team's rows so
  an explicit assignment moves the team once.

## Lessons

- **Never report a remedy that did not happen.** A restart that handed back
  the live process, a stop that only rewrote the row, a turn cap asked about
  the engine — each passed every check while changing nothing.
- **Row status is not evidence of a process.** Ask the machine, or read
  Presence; nothing rewrites `status` when a harness restart takes a process.
- **Never clear the only handle before the process is confirmed gone.** A stop
  that nulled `os_pid` first made a surviving agent unreachable.
- **Compare enums to wire strings as strings.** An atom-vs-string match that
  never fires inserts a fresh row per report, and duplicates withhold work.
- **Turn-level state must be cleared wherever a process goes away** — restart,
  reap, stop, interrupted turn. A stale `turn_started_at` or turn request makes
  an agent unadmittable with nothing left to clear it.
- **Anything edge-triggered needs an edge for every way an agent becomes
  admissible** — coming up, a restart, a stranded task — or the agent sits
  idle holding work.
- **Damp refusals, never delivery failures.** Folding a missed delivery into
  the damper silenced every reader of it.
- **A question's state has a holder, not just a status.** Closing on escalate
  hides it from one reader or the other.
- **Say things to an agent, never as it.** An operator line written as the
  agent speaking reads downstream as the agent working.
- **Intent is not health.** A flag that answers "meant to be running" reads as
  fine for a timer nobody started; keep a separate question for fact.
