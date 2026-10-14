# The web layer

The Phoenix side of CodeMySpec: the application supervisor, the router, user
auth, the shared components, and the LiveViews and controllers people and QA
drive day to day (agent conversation, console, intake workspace, working
copies, dev graph, dev agent tools). Code comments point here by section name.

| Module | Role |
|---|---|
| `CodeMySpecWeb.Application` | Supervision tree; gates server-only children on `serving?`. |
| `CodeMySpecWeb.Router` | Pipelines, MCP mounts, APIs, `:dev_routes`, live sessions. |
| `CodeMySpecWeb.UserAuth` | Session tokens, `on_mount` hooks, OAuth bearer plug, signed-in path. |
| `CodeMySpecWeb.ChatComponents` | One message/turn/tool-call component set for every conversation surface. |
| `CodeMySpecWeb.CoreComponents`, `Layouts` | Base UI blocks; app/marketing layouts and nav. |
| `AgentConversationLive.Show` | The cockpit: one agent conversation, composer, panels, team status. |
| `ConsoleLive` | Project console: resources, deploys, secrets, credentials, activity. |
| `IntakeLive.Workspace` | After the intake gate: convert the plan, take payment, bring the workspace up. |
| `WorkingCopyLive.Rows` / `.Show` | The one reading of a working copy; one copy's page. |
| `DevGraphLive` | Dev-only live view of whether the requirement graph keeps up. |
| `DevAgentController` | Dev-only, cross-project agent control over HTTP. |
| `DeviceController` | A machine announcing itself before it has a checkout. |

## Boot

- **`serving?`** (`Phoenix.Endpoint.server?/2`) decides whether children that
  act outside the process start: the promotion queue, agent wakes, the dev
  tunnel, sweeps that write and fetch. `mix run`, a task or a script against
  the same database boots without them (`when_serving/2`).
- **Boot version.** `BootVersion.capture/0` records which commit is answering;
  it is logged at boot and reported by `register_session`. A dev server runs
  the checkout it started from, so a fix can be committed and green yet absent
  from every response.
- **Watchers and cadences are in memory.** A restart loses them, and a deploy
  lands while agents are mid-run, so two `:temporary` tasks re-seed them
  (`GraphWake.watch_active_projects/0`, `MainAgent.wake_active_projects/0`). A
  failed seed does not stop boot but is not self-correcting: nothing watches a
  project until a continuous toggle, a read of an unprojected project, or the
  next restart.
- **Cadence** is supervised here (`CadenceRegistry`/`CadenceSupervisor`).
  `Cadence.running?/1` is intent (not stood down); whether a timer exists is a
  separate question.
- **Embeddings** children are gated on the configured backend, not the env.
  Prod picks the FLAME backend by token: Hetzner, then Fly, then local. The
  Hetzner closures are wired here because `Embeddings` and `Provisioning` are
  separate top-level boundaries.
- **File logger** runs alongside stdout, never instead of it.

## Dev tunnel

- `tunnel_config` in `:dev` is main's own tunnel (hostname, tunnel id, account
  tag). Only the main copy runs its connector: a second copy running it would
  split main's public traffic between two apps.
- `CMS_MAIN_COPY` and `CMS_TUNNEL_HELD_BY_HARNESS` are set by
  `AppInstance.Runner.Local`. Unset (a plain `mix phx.server`) reads as main and
  not harness-held.

## Agent conversation

- **One page, one conversation**, named by `?conversation=`; none opens the
  project's main agent (`MainAgentConversation.ensure/1`, resolved once per
  project, keyed on the project because the LiveView survives navigating
  between projects). Switching agents is a patch.
- **A named conversation that does not resolve is nil**, never the main agent:
  substituting made a missing agent look like a non-working one.
- **Subscriptions follow the conversation**: unsubscribe the previous topic on
  switch, or the old agent's turns append to the new transcript. Project-wide
  subscriptions are taken once per connected mount.
- **Composer.** Shown when this conversation's own agent is neither off nor
  retired (`talkable?/2`). Reachability is deliberately not checked: a message
  to an unreachable machine must be accepted and reported undelivered, and
  `Agents.dispatch_message/3` answers `{:error, :not_running}` rather than
  absorbing it. The view writes nothing itself; `dispatch_message` records the
  message with its delivery outcome.
- **Drafts** belong to the agent, not the screen: cleared on switch and on send,
  kept across unrelated patches.
- **Empty transcript.** `:nothing_yet` for an agent conversation (the agent
  streams its own steps); `:gap` ("turns were not recorded") only for recorded
  lanes keyed by session.
- **Screen state** (`:screen`, open panels, dynamic view) is `assign_new`, since
  `mount_conversation` reruns on every PubSub update. Narrow until the client
  reports its width; a narrow screen holds one panel. Agent offers are taken at
  once on wide screens and wait for a tap on narrow ones.
- **Analysis indicator** is scoped to the agent's own checkout and accumulated
  from events (source, status, `started_at`, copy), not re-queried per event.
- **Working copy chat links** (`WorkingCopyLive.Show.reachable_chats/1`) follow
  the same rule: an on-duty Alloy agent gets a link; reachability is not asked.

## Transcripts

- **Calls and results.** A call is an assistant turn carrying `tool_calls`; a
  `role: :tool` message is a result, rendered inside its call. A result whose
  call is above the page renders on its own.
- **Results are folded in order**, and a call clears any result standing
  against its id: call ids (`call_16`) repeat across runs in one conversation,
  and a map keyed by id alone gave a new call an hours-old answer.
- **Folding.** Runs of two or more calls (counted as calls, not messages) fold
  into one item; back-to-back routine promotion notices fold too.
  `break_after` splits a run after a pending question so its form renders where
  it was asked, not below later work or inside an expander.
- **Plain assign, not a stream**: folding and nesting need neighbours, and
  `stream_insert/3` cannot regroup. One page (50) re-folds cheaply; "load
  older" prepends and re-folds the whole list.
- **Upsert, never append**: a loaded message can arrive again as a broadcast,
  a queued one again on delivery.

## Intake workspace

- Intake conversations run one process per plan
  (`Intake.ConversationRegistry`/`ConversationSupervisor`), so the flow
  outlives any LiveView. Socket-held state was the source of that feature's bugs.
- Both paths are billing-gated: local is a 7-day `:light` trial (SetupIntent,
  card on file), cloud a `:pro` subscription. Nothing is provisioned on the
  shared host until payment succeeds; a project that already has a workspace
  is never asked to pay again.
- A converted plan is shown only to a member of its account: the intake token
  survives login/logout, so a shared browser could otherwise hand over someone
  else's account.
- Every mount subscribes to the workspace (refresh and reconnect included), and
  `boot_workspace` subscribes before re-reading, because an unchanged step is
  never re-broadcast.
- The main agent is asked for once the workspace is `:running` (the harness has
  joined), not at boot, when it would fail `:harness_not_connected`.
- Local onboarding is detected by a working copy existing (`most_recent/1`),
  polled every 5s.

## Dev agent controller

- Behind `:dev_routes`: compile-time absent from the release. Shares no code
  with the `message_agent` MCP tool, which keeps its project scope.
- **`?wait=true` caps the turn**, not the wait: the turn runs inside a
  `GenServer.call` with that timeout, so a long wait made long turns and
  reported survivors as failures. Long work is dispatched and watched in the
  transcript.
- **`answer` without `question_id`** answers the oldest pending question. With a
  non-matching id it 404s listing the pending ids and never falls back:
  answers are permanent (questions have no un-answer path), and QA, the main
  caller, usually has several open.
- `restart` keeps the row, id and transcript; `stop` turns off; `turn_on` is the
  way back. `machine_tools` lets QA set a toolless copy (`[]` is a fault, nil is
  not) without breaking a shared MCP client.
- Staffing must run in the server's VM, where the channel registry lives.

## Device announce

- The one route a harness needs before it has a checkout, so before it has a
  `harness_project:<id>` channel. A device is account-scoped; a working copy is
  project-scoped, so a whole-machine report belongs here.
- Behind `Plugs.DeployKeyOrOAuth`: laptops hold OAuth, sprites only a deploy key.
- The reply carries every copy on the device (`id => root`): a harness only
  learns roots from hooks, so a restarted one would never revisit a copy nobody
  works in, which is exactly the copy whose worktree was deleted.
- Device ids are minted client-side. An unknown id creates the row with that
  id; an id already naming a device the caller cannot reach gets a fresh one
  (a self-picked id from a cloned image must not hand over another account's
  machine).
- Only real booleans count in the presence report; a string "false" is truthy.
- Pending local projects (with a freshly minted deploy key) are offered only to
  a `:local` device with an account.

## Working copy rows

- `Rows` is the single reading used by the working copy Index, Show and Status
  pages and the agent conversation's team panel. It reads and never creates.
- A restarted harness can re-announce the same checkout under a new device id,
  which the `(project, device, root)` unique constraint does not see. Rows are
  grouped by root and device name in first-occurrence order; nothing is hidden
  and every row stays individually offboardable.
- `include_stopped?` is for the team panel only; `WorkingCopyLive.Show` relies
  on stopped agents being absent.

## Lessons

- **A control's direction comes from the row, never from an assign.** A stale
  `@working?` turned a pause click into a start.
- **State attrs on a component rendered twice are required, not defaulted.** The
  wide layout fell back to the default and drew the wrong control.
- **A clause below a `handle_info` catch-all compiles and never runs.** Keep
  specific clauses above it; a hook that `:halt`s a message makes a clause for
  it unreachable too.
- **Never show a substitute for something that does not resolve.** A missing
  conversation, plan or result is shown as missing.
- **A hidden control is still reachable.** Guard the event, not just the button.
- **Tests that start a process themselves prove the loop, not the wiring.**
  Supervise it in the application and check it from outside.
- **`is_number`, not `is_integer`, for browser widths**: `innerWidth` is
  fractional under zoom.
- **Never build atoms from request input**; match names against a known list.
