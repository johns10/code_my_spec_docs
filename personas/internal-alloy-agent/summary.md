# Internal Alloy Agent

## Role

An LLM agent running inside our own BEAM, supervised by `CmsHarness.Agents`
and driven by Alloy [1][2]. It is started on a working copy by the server over
the harness channel, runs turns against a model, and idles between them as a
live process with a queue.

It fires no hooks. Claude Code's seven hook events are properties of that CLI,
and nothing in this runtime produces them — so every mechanism the orchestrator
uses to speak to an **External Claude Code Agent** reaches this one not at all
[4][7]. What it has instead is an address: it is a supervised process, and it
can simply be told.

That is the distinction the persona exists to make. It was merged with the
external agent until 2026-09-02, and stories 890 and 894 were both written "As
an agent" and built external-only. Their criteria are all true. With one
persona there was no gap to see [6][7].

## Goals

- Be told what its own turn broke, while it can still act on it — the same value
  the external agent has, and currently unmet for this one [6].
- Be told when it ends a turn with problems outstanding or a task still open, so
  it closes its own work rather than walking away from it [7].
- Not be asked to wait. It has no reason to poll for an answer that can be
  delivered when it exists, and no reason to end a turn a second time to find
  out what the first one broke [7].
- Reach the project's tools cheaply. It carries four core tools plus
  `run_script`, `run_browser_script`, `tool_docs` and the three it may not
  script — not the ~186 a script can call [3].

## Pain Points

- **It gets no stop decision and no nudge.** Both are produced inside
  `Hooks.Stop.decide/2`, whose only caller is the external HTTP controller.
  `Validation.validate_stop/3` has exactly two callers, `Hooks.Stop` and
  `Hooks.SubagentStop`; `CmsHarness.Agents.Engine` calls neither. A turn that
  would have been blocked for a failing compile just ends [4].
- **It gets no analyzer alert.** Delivery is a `PostToolUse` footer, and it
  fires no `PostToolUse` [6].
- **Nothing even starts the analyzers for it.** `ensure_stale_runs/3` is reached
  only through `Validation`, and the engine's `on_stop` is agent *termination*,
  not turn end. So there is not merely no delivery — there is nothing to
  deliver [1][4].
- **Its identity does not fit the mechanisms that exist.** `AnalysisAlert`
  dedupes on `session_id` and R8's stuck-escape counts a streak on the session;
  this agent has an `agent_id` and no session at all. Both would have to be
  keyed on the agent to serve it [5][6].
- **Its transcript shows only what it did.** The handover is shared because
  `start_task` records it for whoever calls it, but the decision and the nudge
  are not, so the orchestrator half of its conversation is missing [4].

## Context

Started through `CmsHarness.Agents.launch/1` with a working copy, a provider and
a credential; supervised, so a shutdown asks it to finish before insisting [1].
It holds one MCP session of its own against the project's server — named after
the agent, so two agents on one machine cannot read each other's [8].

What it carries is small and deliberate: `Read`, `Write`, `Edit`, `Bash`, then
`run_script`, `run_browser_script`, `tool_docs`, and `start_agent`, `stop_agent`,
`assign_subagent` — the last three direct because a script may not call them [3].
Everything else is reached by script. Browser tools reach it only if its row
grants them, and only for the `main`, `qa` and `coding` roles [9].

Reachable while idle: `Engine.send_message/4` resolves its pid and decides
started-or-queued without running a turn, so it can be given work after a turn
ends. `{:error, :not_running}` for a halted agent is a correct answer rather
than a delivery failure [1].

## Decision Drivers

- **Messaging over hooks.** John: *"For external agents we deliver via queueing
  to the stop hook, for the internal one we use messaging."* The hook shape is
  an inversion forced by not owning the Claude Code binary; this runtime is ours
  [4].
- **The answer is delivered when it exists, not when it was asked for.** The
  external path must answer at turn end, before analysis has finished, which is
  why it offers a `curl .../analysis/wait` and a second stop. This agent has no
  such branch, and the one-turn-late problem does not exist on its path [5][7].
- **The same words, both agents.** The content is already transport-blind —
  `validate_stop/3`, `Menu.render/2`, `record_orchestrator_action/3`. Only the
  envelope, the response cap and the wait directive are hook-shaped, and none of
  them carries across [5][10].
- **A message can cause work, so it must be able to stop.** Waking a stopped
  agent is the point, and it is also the only delivery that can run away. The
  external escape (R8) is session-scoped; this one counts against the agent.
- **Polling is fine for everything else.** It is a model in a loop and can call
  `devops_status` or `check_answer` exactly as the external agent does. The stop
  decision is the only case where polling is impossible by construction, because
  the agent has ended its turn and will not ask.

## Evidence

1. `lib/cms_harness/agents/engine.ex` @ 921a8859 — `tools/1`, `send_message/4`
   resolving a live pid, `terminate/2` running `on_stop` at agent termination
   rather than turn end. Accessed 2026-09-02.
2. `lib/cms_harness/agents.ex` @ 921a8859 — `launch/1`, `message/4`,
   `send_message/4`, `status/1`, `withdraw/2`. Accessed 2026-09-02.
3. `lib/cms_harness/agents/engine.ex` @ 921a8859, `tools/1` — the ten modules
   this agent carries. Accessed 2026-09-02.
4. Issue `f0cc65ab`, *An internal agent gets no stop decision and no nudge* —
   the caller analysis, and John's direction on transport. Closed as superseded
   by stories 987 and 988. Accessed 2026-09-02.
5. `lib/code_my_spec/hooks/stop.ex` @ 921a8859 — `pending_analysis?/1`,
   `wait_directive/1`, `block_with_reason/4`, `maybe_terminate_stuck/5`: the
   external-shaped parts that have no counterpart here. Accessed 2026-09-02.
6. Story 890 and `lib/code_my_spec/hooks/analysis_alert.ex` @ 921a8859 — the
   `PostToolUse` delivery surface and its `session_id` dedup key. Accessed
   2026-09-02.
7. Stories 987 and 988, sealed 2026-09-02 — the rules and scenarios written for
   this persona, including "the agent is never told to wait for the analyzers".
   Accessed 2026-09-02.
8. `lib/cms_harness/mcp.ex` @ 921a8859 — one session per agent, named so two on
   one machine cannot read each other's. Accessed 2026-09-02.
9. `lib/code_my_spec/agents.ex` @ 921a8859, `machine_tools/3` — browser tools
   granted only for the `main`, `qa` and `coding` roles. Accessed 2026-09-02.
10. `lib/code_my_spec/validation/menu.ex` @ 921a8859 — transport-blind content,
    shared with the external persona. Accessed 2026-09-02.
11. `mix.exs` @ 921a8859 — `{:alloy, "~> 0.12"}`, the dependency this agent
    class runs on. Accessed 2026-09-02.

## Anti-Patterns

- **Do not port the hook shape.** Firing a synthetic `Stop` for this agent would
  import `pending_analysis?` and the curl-and-stop-again dance into the one
  runtime that has a better option, and would block the very process the message
  needs to reach.
- **Do not treat `session_id` as this agent's identity.** It has none. Two
  mechanisms already assume otherwise, and issue `927c2b78` is what that
  assumption costs when it is wrong even for the external agent.
- **Do not give it a durable job ledger it does not need.** It polls for
  long-running tool calls exactly as the external agent does; the only delivery
  it genuinely cannot poll for is the stop decision.
