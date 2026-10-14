# Agent coordination

How the pieces around the agents core fit together: the agent row and its
repository, how a team holds a story, how offers and the stop menu tell an
agent what to do next, role profiles, credentials and launch requests, the tool
index, conversations, sessions and task ownership, notifications (questions,
permissions, tap-outs), staffing, epic dispatch and intake. The core lifecycle
(start, stop, restart, turn admission, the decline damper, questions held by
main) is in `knowledge/agents/index.md`; this doc does not repeat it. Code
comments point here by section name.

| Module | Role |
|---|---|
| `Agents.Agent` | The agent row: key, process handle, intent (off/retired), team binding, embedded tasks. A schema leaf. |
| `Agents.AgentsRepository` | Project-scoped reads and writes of agent rows, continuous mode, model settings. |
| `Agents.Assignment` | The story and epic a copy's team holds; claims, landing, moving stories. |
| `Agents.Offers` | Every nudge recorded as an offer with an observed outcome; turn requests; escalation ladders. |
| `Agents.Menu` | The "what next" appended to a stop refusal. |
| `Agents.StopDecision` | The stop-hook decision delivered as a message to an agent we run. |
| `Agents.AnalysisReport` | Pushes finished analysis runs to internal agents. |
| `Agents.RoleProfile` | One data definition per role. |
| `Agents.Credential` | Turns a stored integration into an `auth.json` entry. |
| `Agents.LaunchRequest` | The wire map a machine receives to bring an agent up. |
| `Agents.ToolIndex` | The names of every tool an agent can reach, by route. |
| `Agents.Phase` | A goal/tools/commit/evaluate step runner for intake-style conversations. |
| `Conversations`, `Conversations.Message` | Support threads, agent transcripts, resume history. |
| `Sessions` | Claude Code sessions and their embedded tasks. |
| `TaskOwner` | One API over the two task owners (session, agent); blockers and their release. |
| `Notifications` | Push, question requests, permission requests and tap-outs, the inbox. |
| `Staffing` | Copy and agents changed together: mint, designate main, offboard. |
| `EpicDispatch` | Propose/approve an epic, place its stories, staff the copy. |
| `Intake`, `Intake.Conversation` | Pre-signup plans and the process that owns each intake conversation. |
| `Transcripts` | Parsing Claude Code JSONL transcripts. |

## The agent row

- **Key.** `working_copy_id` plus `role`: one agent per role per copy. Nothing
  joins on the reported `working_copy` path — symlinks, trailing slashes and
  `/private/tmp` vs `/tmp` make reported strings disagree, and two harness rows
  can share a root.
- **Process handle.** `os_pid` is a process *group* id: the harness makes each
  agent a group leader, so one signal takes the agent and every tool it
  spawned. `os_boot_id` is written and read with it; group ids are reused
  across reboots, so a pid from another boot is not ours to signal. A null
  `os_pid` means it never started, distinct from started-and-exited.
- **Recorded, not looked up.** `model` is the model it started on (changing a
  role's setting must not move a running agent mid-transcript). `tools` is what
  it launched with; enforcement derives tools per call. `credential` and
  `history` are virtual: the row is never a second home for a subscription or a
  transcript.
- **Intent.** `off_at`/`off_by`/`off_reason` (off, holds its seat) and
  `retired_*` (gone, seat freed, row kept). `stopped_reason` says whether a
  stop was asked for (`:stopped`) or nothing confirmed it (`:reaped`).
- **`declined_offer` fingerprint.** An agent that ends a turn claiming nothing
  clears every in-flight mark and is instantly eligible again; without a record
  of the refusal it is re-offered the same work every few seconds. A
  fingerprint (not a flag) wakes it when the work changes; the timestamp keeps
  it from wedging.
- **Tasks are embedded on the agent** (the same `Task` a session embeds). An
  agent we run has no session.
- `working_copy_id` is required only on insert: the FK nilifies on checkout
  delete and a nulled row must stay writable. `config_dir` must sit outside the
  copy, because copies are committed and pushed.
- Only a story-scope role (coding, QA) may hold `story_id`. Product holds an
  epic; main holds neither.

## Repository reads

- Every read is project-scoped except `list_every_agent/1` (dev route only) and
  the boot-time scope listings.
- `list_running_main/1` and `main_agent_project_scopes/0` are by intent (on
  duty), not process presence, so a restore window never reads as "no main"
  and the cadence watches a main that is still coming up. The cadence is keyed
  on a main agent existing, not on continuous mode: a project whose agents were
  all non-continuous once had a main fielding questions that nothing woke.
- `fetch_agent/2` answers `:not_found` for a non-UUID (surfaces print truncated
  ids and agents pass them back; a database error reads to an agent as broken
  tooling) and resolves an agent conversation id to its agent.
- `sync_working_copy_root/3`: the row's `working_copy` is the path a restore
  sends, so it follows a corrected `working_copies.root`.
- Model settings are user-scoped, because the provider credential is.

## Teams and assignment

- The team is a copy's story-scope agents. A story is assigned to the whole
  team at once, held on each member's `story_id`; that is the only record.
  `stories.working_copy_id` is the checkout reservation.
- Story work happens on feature copies. `assign_team/3` refuses the main copy;
  a claim there is allowed but assigns nobody.
- Routes in: `set_active_story` (`assign_team/3`); the first claim while the
  team holds none (`claim/3`); a joining member inherits (`inherit/1`).
  Claiming another story while the team holds one is refused.
- A team keeps its story until it lands (`stories.promoted_version`).
  `notify_team_free/3` releases it under the project lock (shared with the
  issue bag, since a final issue and story can land together) and tells main
  only when nothing else is assigned. Reading never moves a team.
- Product's `epic_id` is the epic it is designing (set on claim); placing the
  epic on a working copy takes it from every agent not on the destination.

## Offers

- Every nudge is an offer with an observed outcome, settled at turn end from
  the turn's tool calls; recording never changes what is sent.
- **Turn requests.** `dispatch/3` stamps `turn_requested_at` under the agent's
  row lock; an open one inside the TTL (300s) is "a turn is on its way". It
  must lapse because what closes it needs a live process: a harness that dies
  after accepting leaves it open, and an open turn request blocks every other
  wake. A lapsed request is noted "never started" so re-offers to a harness
  that swallows turns are reported as a stall, not as fresh hand-overs.
- **Serialized per agent** with a Postgres advisory lock, not a transaction
  (callers may be inside one). A released task is offered from two processes;
  unserialized, both opened offers side by side.
- **Queuing is not delivery.** An offer whose message is still pending is
  neither claimed nor ignored by the turn that preceded its pickup.
- **Claimed then cancelled is declined**, or the claim resets the ladder and an
  agent can take and drop the same work forever.
- `standing/1` filters laddered kinds in SQL (an agent can hold hundreds of
  offer rows); each row is read by its own kind's ladder.
- `unreported_held_back/1` is not a time window: a refusal is settled earlier
  in the same turn than the turn-end timestamp.
- Bump a kind's template version when its prompt text changes.

## The stop menu

- A **class** is countable state in this working copy the hook can rank: open
  problems, the agent's own open task, actionable requirements, in that order.
  An **offer** is printed regardless: the open-question count with
  `list_user_questions`/`check_answer`, `ask_user_question`, `semantic_search`,
  and `tap_out` inside the loop.
- A pending question is an offer, never a class: as a class, one stale row held
  the top of the menu permanently.
- Issues are not a class: the graph counts them per role. As a class, three
  agents on one copy were all sent to the same incoming issues only product
  could triage.
- Problems count only for roles that hold them (`holds_problems?`), and only
  what the gate blocks on (`Blocking.enforceable/2`). A QA agent was once held
  open by spex findings it could neither read nor fix; a coding agent was told
  "133 problems" that were unwritten features.
- The requirements count is `Work.actionable/3` with the owner, the same list
  the agent would be offered, so count and list never disagree.
- One directive; the rest tallied as counts. The open task named is the newest
  active one, with its id and why its requirement is still open.
- Tools reachable only through a script are named that way (`run_script` with
  `list_tasks({})`); named bare, agents called them directly, got "no tool",
  and stood down.
- No work, no menu: `render/4` answers `""` and the agent stops. `tap_out` is
  not offered on an empty queue, because a granted tap-out must be undone by
  hand before later work can reach the agent.

## The stop decision

- Same content as the Stop hook (`Validation.validate_stop/3` + the menu),
  delivered as a message to an agent we run, which fires no hooks.
- Never "wait for analysis": results are pushed when they exist.
- Silent when there is nothing to say. Outside the loop the agent is told
  nothing (a message costs a turn); inside it, an empty menu is the terminus.
- Stuck detection: the same blocking key more than 5 times per agent goes
  silent (`:persistent_term`, so a restart costs one duplicate). A continuing
  menu that repeats byte-for-byte is counted in its own slot.
- The conversation is opened before anything is recorded:
  `record_sent_to_agent/2` silently records nothing for an agent with none.
- The turn request runs off the harness channel's process (a call back into it
  would deadlock).

## Analysis reports

- Internal (Alloy) agents get a push when a run lands; Claude Code sessions
  pull the digest on `PostToolUse`. Pushing to both would tell a session twice.
- A clean run is silent to agents that did not ask. The requester and any
  waiter are answered either way: an agent holding an open task is not
  runnable, so silence once left one waiting on a green run for most of half an
  hour. The asker is answered whatever its role (`:own_reply`); the role filter
  for unsolicited findings is `Wake`.
- A push carries counts and the next step; the hook's alert is capped because
  it rides every tool call.
- A telemetry handler, so `Analysis` does not depend on `Agents`. It must
  rescue: `:telemetry` permanently detaches a handler that raises.
- `requested_by["agent_id"]` may be a Claude Code subagent id; only a UUID is
  queried.

## Role profiles

- One entry per role; every role-conditional site reads it. Its own boundary
  with no deps, and pure data (a compile-time dependency of `Ecto.Enum`
  schemas).
- A grant names scriptable or direct tools; `tool_sets_test` checks every name
  against `ScriptableTools` and `LocalServer`. A name matching nothing reads as
  a bigger grant than it is. `browser` is a capability, not a tool name.
- **Every task a role receives must name tools that role carries.** Product
  told to triage without accept/dismiss had to tap out with the work done; a
  coding agent sent to install Credo checks without the tool cancelled and the
  chain stopped; QA without file tools could satisfy none of its own
  file-existence requirements.
- QA edits nothing about the story (it could make a failing run pass); it reads
  problems but never clears or is held by them. Coding resolves issues (QA
  re-tests) but never accepts or dismisses them. Main carries everything.
- Model preference: the first provider the account holds wins; QA leads cheap.

## Credentials

- `fetch/2` answers an `auth.json` entry, `:not_connected` (connect a
  provider) or `:reconnect_required` (reconnect one; includes a refresh the
  provider refused). The remedies are opposite.
- OpenAI rotates the refresh token on every refresh. Every agent holds a copy,
  so the first to refresh on startup burns it for the others and for our row.
  `refreshedAt` (→ `last_refresh`) is sent so `codex` does not refresh on
  start; both `DateTime` and `NaiveDateTime` are accepted (a guard on the wrong
  one once dropped the field silently).
- `idToken` is required by `codex exec`; `accountId` is decoded from the access
  token's JWT so a refreshed token brings its own. `expires` is milliseconds.
- The platform credential is ours, for a visitor who has connected nothing;
  off unless configured, capped by turns, no token budget or expiry.
  `source/2` is derived, never stored, so connecting a provider lifts the cap
  at once. A `:local` provider is always the user's.

## Launch requests

- One definition for start and restore. Three copies once drifted, and the
  restore map carried no credential: an API-key agent came back after a harness
  restart and failed its first turn.
- History travels: an agent dies with its harness and the transcript is its
  state. Credential and history are hydrated onto virtual fields.
- The oauth clause in `credential_fields` matters: without it agents silently
  ran on whatever CLI login the machine held, until that aged out.
- `demo_turns` seeds two calls the agent has already made. Roughly one turn in
  ten once made no call and fabricated a failing one; rewriting the prose did
  not move it, demonstration did.
- `continuous` is on the wire so a restore does not unpause a paused agent.
  `app_url` is the main copy's preview; without it a QA agent refused to guess
  while the app was up. `project_brief` is omitted when unwritten.

## The tool index

- Names only, grouped by route (direct, `run_script`, `run_browser_script`).
  Agents could see what they carried but not what they could reach: one called
  a tool it lacked and stopped; another concluded epic tools were unreachable
  when `run_script` had them all along.
- The direct section is the direct server less `@not_carried`, never the
  `tools` column; listing scriptable names as direct produced "Unknown tool".
  `carried/1` feeds the engine's tool list, so the index cannot name a tool
  the engine lacks.

## Conversations

- An agent's conversation is keyed on the agent, never the copy (one thread per
  copy interleaved a whole team). A Claude Code lane with no agent row uses a
  session-keyed thread. The first agent of a project born from intake adopts
  the `"intake:"` thread.
- **Empty messages are refused centrally**, judged by the rendered parts. Empty
  rows read as a model returning nothing and once cost a day of looking in the
  wrong place; guarding input shapes one at a time missed a `[]` from the
  harness. `Message.agent_changeset` logs the writer's stack if one slips
  through.
- Stored text is never trimmed: the record is what the model received.
- Everything sent to an agent is `:operator`; resume hands it to the model as
  "user". A role excluded from the provider context is visible to the watcher
  and invisible to the model.
- `resume_messages/1`: latest checkpoint plus every message after its anchor
  (or its own time, never the whole conversation again). Each tool call is
  paired with its result, or a result saying the outcome is unknown. Pending,
  withdrawn and failed deliveries are excluded.
- `get_agent_conversation_by_id/2` scopes by account and project.
- Generated names are unique per project: a collision renders two identical
  links to different transcripts.

## Sessions

- One session per Claude Code conversation; tasks embedded. "Active" means
  touched within `active_window_seconds/0`, since status never goes stale.
- `concurrent_sessions/2` detects (never refuses) two sessions on one project:
  a second agent once used the first's session id and every task it touched was
  attributed to the other.
- `record_git_rewrite/2`: after a rebase/pull/reset since the task started,
  unattributed dirty files may be inherited history, not this session's work.

## Task ownership

- `TaskOwner` is the one API over sessions and agents. A task is in exactly one
  owner's list.
- An agent holds one active task; a promotion task awaiting its queue
  (`await_promotion/3`) does not hold that slot.
- Claims are checked under an advisory lock per (project, copy): another agent
  on the same copy holding the same requirement refuses the claim. Agents with
  no copy are each other's neighbours.
- **Blockers.** `block_task/6` accepts an active or blocked task (re-blocking
  names the new blocker). `blocker_resolved/4` is the one release path for
  issues, questions and tap-outs: it sets `blocker_resolved_at` on every
  waiting owner, never reactivates, and wakes the holder with the task named in
  the turn. An approved tap-out and a withdrawn question wake nobody; a busy
  holder is told, and offered the task once its active one is done.
- Issues below the fix threshold release their waiters
  (`update_configuration/2` is the write that can change the threshold).

## Notifications

- Questions have a holder; only `holder == "user"` questions reach the user's
  pending inbox. A teammate's tap-out is main's to decide until escalated;
  main's own and a Claude Code session's go to the user.
- The pending list hides requests whose asker is off or retired (once 41
  pending, none with a live asker, burying two real blockers). Agentless
  requests stay. The badge counts what the list shows.
- **Denying a tap-out** clears the agent's decline, releases the blocked task
  (or, with none, wakes the agent), and puts the notice in the turn prompt
  together with the decider's reason and any issues the agent's own request
  named that are now resolved. Woken without the notice, an agent read its own
  "waiting on my tap-out" and spun; told only as a transcript line or without
  the reason, it reached its old conclusion again.
- Dismissing a permission marks it `"expired"` and releases its task. A
  question is answered or withdrawn by its asker, never dismissed.
- An identical question on the same story or task, pending or answered within
  two minutes, is reused. A pending tap-out on the same task is reused.
- A user may overrule main's or product's answer (history kept); nothing else
  overwrites an answer. An all-blank answer is refused for every route in.
- Answer delivery: mid-turn the answer joins the turn; idle with nothing
  released, a continuous asker is offered a turn if `Wake` allows; otherwise it
  collects with `check_answer`. Delivery happens outside the row lock.
- `Notifications` sits below `Agents`: it announces telemetry events and
  `Agents.Events` delivers.

## Staffing

- `mint/2` makes a copy on a host (main checkout first), sends the generated
  id and deploy key to the harness, records the copy and staffs it. A copy that
  cannot be staffed is still a copy. The promotion gate copy is minted with no
  roles.
- `offboard/2` is an act a person takes, never a sweep on elapsed time (that
  read busy harnesses as idle). Agents are retired first, best-effort, so a
  copy whose machine is gone stays offboardable. A shared preview must be
  released first, or the offboard is refused: the row is the only record of a
  live ingress rule and DNS record. The checkout on disk is never touched.

## Epic dispatch

- `propose/2` (the agent) and `approve/2` (a person) are two acts; only approval
  starts work. An epic with nowhere to go is still dispatched and reported as
  waiting.
- Destination: the copy carrying the project's most recent dispatched epic (not
  main, must report a root), else a newly minted one. Never the main checkout,
  which holds only main and product.
- Placement is written on the stories (the graph is grained on stories), with
  `update_all` and skipping stories an agent holds. Then the copy is staffed and
  the epic assigned. A dispatch that only set a status once started nobody.
- `progress/1` reports from records; a failed epic is its own status.
- A dispatched agent's questions go on the `epic:<id>` conversation.

## Intake

- One process per conversation owns the flow, not the socket: a reload or
  dropped connection loses nothing, and the mailbox serialises racing turns.
- `resume/1` restarts a call stranded by a deploy or crash (the row says
  `:thinking` with nothing behind it); a watchdog marks a call that neither
  returns nor crashes as failed.
- Conversion copies the intake transcript onto an `"intake:<plan id>"` thread
  and records the visitor's "who uses it" as a proto persona (stories need one
  before rules can be added). Neither failure blocks the project.

## Lessons

- **Every prompt names only tools its reader carries, by the route it reaches
  them.** An agent told to call a tool it lacks reports the failure and stops.
- **Check each role's tool set against the requirements that name it**, not
  against the last agent that complained.
- **Say the correction as the turn prompt.** A line recorded ahead of the turn
  is history the agent reads past its own last conclusion.
- **Name the agent's stale claim back to it.** A generic reason contradicts
  nothing in particular.
- **Silence is an answer only to someone who did not ask.** The requester of
  any async result is answered either way.
- **A count and the list it counts come from one source.**
- **A decision a person made must survive a restore** — paused stays paused,
  approved stands even when nothing could be staffed.
- **Guard the output, not the input shapes.** Refuse what renders empty, once,
  centrally.
- **One definition of anything sent to a machine.** Copies drift and the
  restore path is the one nobody exercises.
- **Intent is not presence.** Answer "who should be running" from intent and
  "can it be reached" from the process, and never confuse the two.
- **Never trust a reported path as an identity.**
