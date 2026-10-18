# Terminal agents as first-class agents — one Agents seam, Agent as identity

Status: in progress. Three amigos with John 2026-10-18; stories 1122 (joins),
1123 (is told), 1124 (state reads right), built by the operator copy.

## Decisions (2026-10-18)

- **The seam is Agents, on the harness.** The server knows agents only
  through the channel and Presence; it never knew about Alloy. An agent on
  the harness is a process registered as `{:agent, id}` answering the agent
  contract in `CmsHarness.Agents` (`{:send, …}`, `{:work_available, …}`,
  `:status`, `:interrupt`). `Engine` is the Alloy one; a terminal agent is a
  second kind, watched by `Liveness` like any agent, so Presence, Wake, Work
  and the mailbox stay as they are. This replaces the server-side Driver
  below.
- **Waking** an idle terminal agent: as today, only when `continuous`.
- **Roles:** a terminal agent joins as any role on any copy, even one already
  held; default main, chosen by the agent with the person. Alloy agents keep
  one-per-role. When the session exits, nothing else changes.
- **Sessions are deleted** before release, as removal work, not a story.
- **No inbound setting is written.** Repo settings may only tighten
  `crossSessionInbound`, and a normal or auto-mode session accepts our
  messages by default (probe below). A session that holds them falls back to
  the stop hook and says why.

## What the probe found (Claude Code 2.1.302, 2026-10-18)

- Frames are newline-delimited JSON on the socket: an optional
  `{"type":"auth","token":…}` first line (required on Windows), then
  `{"type":"user","message":{"role":"user","content":"…"}}`. Nothing is
  written back, so the harness settles the mailbox on a successful write.
- An unauthenticated, unattested message woke an idle auto-mode session; it
  arrives framed as "Another Claude session sent a message" — a teammate's
  request, not the user's.
- A bypass-permissions session holds unattested messages (from the code; not
  probed).
- The SessionStart hook can pass the socket path as an HTTP hook header
  (`allowedEnvVars`); Claude Code will not interpolate a credential into a
  header, but a session publishes its inbox key beside its socket for peers
  of the same OS user, so the harness reads the token there. The token never
  reaches the server.
- `--messaging-socket-path` wants a private (700) real directory and a path
  under ~104 bytes.

## Scope

**Terminal users only**: a person running `claude` in their own terminal on
their own Claude Code subscription, in a working copy CodeMySpec serves.

Spawned agents are already covered. Desktop users get agents CodeMySpec runs
through Alloy in the harness, with Alloy's providers (`claude-code`,
`openai-codex`, and the rest). Nothing here changes them; no Agent SDK or ACP
driver is needed.

## Decision summary

Every agent is an **Agent row** with an `engine` and a **Driver** chosen by
that engine: `Driver.Alloy` for the agents CodeMySpec runs, and
`Driver.ClaudeCodeAttached` for a person's terminal session. The shared
machinery stays common: offers, the mailbox as durable storage, Wake policy,
Work admission, `TaskOwner`, conversations, Main and `Agents.Events`. Only the
part that delivers a turn and reports on it varies.

The attached driver is built on Claude Code's **cross-session messaging**
(v2.1.224+; v2.1.234 on native Windows;
https://code.claude.com/docs/en/cross-session-messaging): every interactive
session has an inbox socket other processes on the machine can write to.

**Sessions go.** A terminal agent self-registers to create its Agent row.
Claude Code's own `session_id` becomes an attribute of the agent.
`register_session`, session-scoped tasks and the Session schema are removed
once the Claude Code plugin moves to `register_agent`.

## Why

A terminal Claude Code session is a second-class citizen today:

- **Presence means a harness process exists.** `Wake.running/1`,
  `Work.present?/1` and the mailbox delivery gate (`mailbox.ex`) refuse an
  agent Phoenix Presence is not tracking, and only the harness channel
  tracks Presence, for its own engines. A terminal session always reads as
  not running, so offers and wakes are held.
- **Delivery assumes the harness engine.** `Transport.request_work_turn`,
  `Mailbox.pump` → `Transport.dispatch_message`, `interrupt_if_busy/2`.
- **Turn boundaries come only from the harness.** `turn_started_at` is
  written only by the engine's `turn_started` event; Wake, decline handling
  and Main's stall detection read it.
- **Hard-coded `engine == :alloy` branches**: `ensure_conversation` (a
  Claude Code agent gets no conversation), `analysis_report`,
  `WorkingCopyLive.Liveness`, `WorkingCopyLive.Show`.
- **Tasks split across Session and Agent**, so Main's digest, which iterates
  Agents, does not see a Session's tasks.
- **Delivery today is only the stop hook**, and only while the session is
  mid-work; an idle session cannot be reached.

`Agents.Transport` is the nearest seam, but it is one global module
(`Application.get_env(:code_my_spec, :agent_transport)`) that mixes
per-machine operations with per-agent driving, and nothing dispatches on
`agent.engine` except display and conversation branches.

## What the attached driver can and cannot do

| Capability | Alloy (today) | Terminal Claude Code (cross-session messaging) |
|---|---|---|
| Identity | Harness reports its engines | `SessionStart` hook self-registers: session id, plus `CLAUDE_CODE_MESSAGING_SOCKET` and `CLAUDE_CODE_MESSAGING_TOKEN` (exposed to hooks and Bash) |
| Deliver a message | Engine `send_message` → `:started` / `:busy` | The harness (same machine, same OS user) writes to the session's inbox socket |
| Wake when idle | Yes | Yes — a message to an idle session starts a new turn |
| Mid-turn delivery | Send-now interrupts and resumes | Read between tool calls; running tools are not interrupted |
| Interrupt | Yes | No — no "now" option |
| Turn boundaries | Engine events | `UserPromptSubmit` / `Stop` hooks, plus idle notices |
| Presence | Phoenix Presence | `claude agents --json` (`--cwd`): pid, status, waiting-for, session id |
| Conversation / usage | Engine stream | Tail the session transcript `~/.claude/projects/<cwd>/<session>.jsonl` |
| Restart | Harness Keeper | No — it is the person's process |
| Tool rewriting (`mix test` routing) | `Tools.Bash` | PreToolUse hook (already in place) |
| Precondition | — | `crossSessionInbound: accept` for the project (onboarding writes it into `.claude` settings); otherwise each message waits on an approval dialog |

### What does not line up

1. **"Busy" and the mailbox handshake.** The mailbox's generation and
   ready/consume handshake (`mailbox.ex`) assumes one engine that pushes
   `mailbox_ready` and consumes synchronously. A terminal session queues
   messages itself and reads them at a tool boundary or on going idle.
   Delivery has to collapse to *deliver; the driver queues or holds*. This
   is the riskiest coupling — get it wrong and messages double-deliver or
   strand. Design it first.
2. **Send-now is weaker.** Delivered at the next tool call, so a
   long-running tool finishes first. `send_now` should say so.
3. **No restart.** If the session exits, the agent is absent until the person
   starts one; Main sees it as gone, not stalled.
4. **Conversation and usage are reconstructed** from hooks and the
   transcript, not streamed.

## Identity: self-registration replaces Sessions

| Session today | Becomes |
|---|---|
| `register_session` | `register_agent(working_copy, role, engine, engine_session_id, socket, token)` → agent id; MCP calls carry it as `x-agent-id` (`plugs/agent_scope.ex` already reads it) |
| Session-scoped tasks | Agent-held tasks only; `TaskOwner`'s Session branch and the Session/Agent branching across ~47 files go |
| `session.continuous` | `agent.continuous` (exists) |
| `session.subagents` | Child agents (`parent_agent_id`), or ignored |
| `external_conversation_id` | `agent.engine_session_id` |
| `state`, `eval_feedback_count`, `last_eval_feedback_hash`, `git_rewrite_at` | Move to the agent if still needed, otherwise drop |

Rules:

- **Idempotent.** Registering with an `engine_session_id` already on a row
  returns that row (and refreshes the socket and token). A resumed session
  (`claude --resume`) must not mint a new agent, or Main's digest fills with
  ghosts.
- **Two terminal windows on one copy are two agents.** Each registers.
- **The conversation belongs to the Agent**, filled from hooks and the
  transcript. The `engine == :alloy` conversation branch goes.
- **The socket token is a credential.** Store it like one, scoped to the
  machine that registered it.

## The Driver behaviour

```elixir
@callback deliver(Agent.t(), ref :: String.t(), text :: String.t()) ::
            {:ok, :started} | {:ok, :queued} | {:error, term}
@callback interrupt(Agent.t()) :: :ok | {:error, term}          # optional
@callback presence(Agent.t()) :: :live | {:recent, DateTime.t()} | :absent | :gave_up
@callback supports?(:interrupt | :restart | :push) :: boolean
```

`Driver.Alloy` keeps today's start/stop/restart through the harness.
`Driver.ClaudeCodeAttached` answers `supports?(:push) == true`,
`supports?(:interrupt) == false`, `supports?(:restart) == false`.

Both feed `Agents.record_turn_event/4` with the existing turn events
(`turn_started`, steps, `turn_ended` with usage, `turn_failed`), so Wake,
decline handling and stall detection work unchanged.

The harness owns the attached driver's machine side — it is on the same
machine as the terminal, already serves the copy, and is where the socket
and `claude agents --json` are reachable.

## Steps

1. **Split `Agents.Transport`** into a machine transport
   (`create_working_copy`, `call_machine_tool`) and the per-agent Driver
   dispatched on `agent.engine`. `Transport.Harness` becomes `Driver.Alloy`;
   the test transports move with it. *Medium* — ~20 test files set
   `:agent_transport`.
2. **Simplify delivery** to *deliver; the driver queues or holds*, replacing
   the mailbox generation/ready/consume handshake. Keep the mailbox as durable
   storage. *Medium; riskiest — design first.*
3. **Presence becomes `Driver.presence/1`** in `Wake.running`,
   `Work.present?`, the mailbox gate and `Agents.lifecycle`. *Small–medium.*
4. **`register_agent`** beside `register_session`, idempotent on
   `engine_session_id`; switch the Claude Code plugin's `SessionStart` to it,
   passing the messaging socket and token. Onboarding sets
   `crossSessionInbound: accept`. *Small–medium.*
5. **`Driver.ClaudeCodeAttached`**: deliver over the inbox socket (from the
   harness), presence from `claude agents --json`, turn events from
   `UserPromptSubmit`/`Stop` and idle notices, conversation and usage from
   the transcript. *Medium.*
6. **Capabilities stated, not silent**: `send_now`, restarts and Main's
   restart tool consult `supports?/1` and say why something cannot be done
   for this agent. *Small.*
7. **Move tools off Session**, one at a time; then delete Session,
   `register_session`, and the `engine == :alloy` branches. *Large* — the
   long tail.

Ordering: 1 → 2 → 3 → 4 land with Alloy unchanged. 5 needs 2–4. 7 waits until
no tool needs a Session.

## Risks

1. **The socket wire format is undocumented** beyond an auth line
   (`{"type":"auth","token":...}`): no message schema, framing or reply
   format. Build behind the driver so it can be swapped. The documented
   alternative is **Channels** (https://code.claude.com/docs/en/channels): an
   MCP server — ours — pushes events into a session started with
   `--channels`; research preview, claude.ai sign-in, and the person must
   launch with the flag.
2. **Version gate**: Claude Code v2.1.224+ (v2.1.234 on Windows). Below that,
   the agent registers but `supports?(:push) == false`, and delivery falls
   back to the stop hook.
3. **Inbound policy**: a person or managed settings can set
   `crossSessionInbound` to `hold` or `refuse`. The driver must report that
   as a refusal with its reason, not leave offers silently held.

## References

- Claude Code cross-session messaging: https://code.claude.com/docs/en/cross-session-messaging
- Agent view (`claude agents --json`): https://code.claude.com/docs/en/agent-view
- Channels: https://code.claude.com/docs/en/channels
- Hooks: https://code.claude.com/docs/en/hooks
- Survey of `CodeMySpec.Agents` (2026-10-13): Transport behaviour and implementations, `Agent.engine` (`[:alloy, :claude_code]`), the Presence / turn-start / Keeper assumptions listed above.
