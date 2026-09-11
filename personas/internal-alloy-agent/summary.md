# Internal Alloy Agent

Researched 2026-09-02 against the gap this persona was split out to name.
Re-researched 2026-09-11 against 10,521 recorded tool calls from sixteen live
instances of the class, which is why most of it is rewritten: the three pain
points the first pass led with have been built, and what actually hurts this
agent now is not what anybody predicted [1][12].

## Role

An LLM agent running as a supervised process inside our own BEAM, started by
`CmsHarness.Agents.launch/1` on the machine holding its working copy and driven
by a forked Alloy [2][3][4]. It takes one of four roles — `main`, `product`,
`coding`, `qa` — and in `continuous` mode runs a loop rather than a session:
a message arrives, it acts, its turn settles, the stop decision sends the next
message [5][6][7].

It fires no hooks. Claude Code's seven hook events are properties of that CLI
and nothing in this runtime produces them, so every mechanism the orchestrator
built for an **External Claude Code Agent** reached this one not at all [8][9].
What it has instead is an address: it is a process, and it can be told.

It is not a minority case. Every one of the 10,521 tool calls recorded on this
project between 2026-09-03 and 2026-09-11 was made by an `alloy`-engine agent,
across sixteen distinct agents; 117 of the 121 agent rows ever created are
`alloy` [1]. The persona was split out of story 890 on 2026-09-02 because
"an agent" had silently meant Claude Code; nine days later the default is the
other way round.

## Goals

- **Finish the turn, then be told what it cost.** Both halves are now built.
  `announce_turn_end/1` emits `:turn_ended` from the engine; `record_turn_event/4`
  routes it to `StopDecision.deliver/3`, which renders the same
  `Validation.validate_stop/3` summary and `Menu.render/2` directive the hook
  renders and sends it as a message [3][6][7][22]. The analyzer alert got its
  second transport the same way — `McpServers.AgentAlert.append/3` puts
  `Analysis.Alert.check/3`'s line on the agent's own tool results, because a
  `PostToolUse` footer cannot reach it [10][11].
- **Never be told to wait.** The hook has a `pending_analysis?` branch telling
  an external agent to `curl .../analysis/wait` and stop again, because a hook
  must answer before the answer exists. There is deliberately no counterpart
  here: it stops, analyzers run, the message arrives [6][9][23].
- **Keep a tool surface that is there when it reaches for it.** This is the goal
  the class does not currently have and the one it spends the most turns on
  [12][13][14].
- **Go home when its own queue empties.** `Menu.render/2` answering `""` is the
  loop's terminus, and the menu is narrowed to the agent's own role so a coding
  agent is not held open by product's queue [6][7].

## Pain Points

- **Its whole tool surface can vanish under it, and nothing it can do fixes
  that.** 126 transcript messages carry the phrase "No such tool available",
  spanning 2026-09-08 to 2026-09-11, 64 of them inside the 2026-09-09 00:00
  hour alone [12]. Two independent mechanisms in the code produce exactly that
  message: a leaked Anubis client left registered under the agent's name after
  its session is gone, holding the *previous* session's transport — documented
  as watched end to end, "a coding agent stopped at 02:24, came back with no
  tools at all … for four consecutive turns while three restarts each answered
  'running' and changed nothing" [13]; and a client that cached its tool list at
  connect, for which "a tool the server has compiled, loaded and answered on is
  still `No such tool available` to any session that connected earlier" [14].
  Both are cleared from outside the agent. The agent's own account of it, on
  2026-09-11 at 02:34:30, is the third consecutive turn of it: *"every tool I
  try — `bash`, `run_script`, and now `tap_out` — returns 'No such tool
  available' … including the one meant for exactly this situation, [so] I have
  no way to act or to signal out through the normal channel"* [12]. The
  recurrence pattern matters more than the incident: 15 such messages on 09-10,
  24 more in the 02:00 hour of 09-11, 18 across that morning [12].
- **The menu offers it a tool that cannot run in this runtime.** Every refusal
  carries three unconditional offers, one of which is `semantic_search` — and
  `Menu`'s own docs call it *"the one most often skipped in practice, and the
  most expensive"* [7]. In the BEAM serving these tools it returns "Embeddings
  are unavailable in this runtime. The embed pipeline (Ortex + sqlite_vec) ships
  only with the CodeMySpec CLI binary" [15], because `{:ortex, …}` and
  `{:sqlite_vec, …}` are scoped `only: [:dev_cli, :prod_cli, :cli_demo, :dev_sprite]`
  in `mix.exs` [4]. Story 1004 records it as an inherited defect in as many
  words: *"prints a dead option for internal agents"* [16]. It was called 33
  times anyway [1].
- **It barely reads what is already written down.** Against 10,521 calls, the
  knowledge tools account for 135: `read_knowledge` 95, `semantic_search` 33,
  `list_knowledge` 7. `bash` alone is 2,883 — 27% of everything the class has
  ever done [1]. `Menu`'s standing offer exists precisely because *"a great deal
  of what an agent needs is already written down, and one that does not think to
  search reasons from nothing and produces confident nonsense"* [7]. The census
  says the offer is not working, and the dead `semantic_search` is at least part
  of why.
- **It is told things it has already answered.** `StopDecision.stuck?/3` exists
  for this and gives up after five identical deliveries [6]. Before it did, and
  where it does not reach, the transcripts show the failure directly: 25 messages
  arguing that findings reported to it are *"explicitly tagged '(not edited by
  this session)'"*, four of them inside two minutes on 2026-09-08 [12].
  `tap_out` — the escape offered in the menu — has been called 250 times [1].
- **`evaluate_task` is its second-most-used tool, at 2,163 calls.** More than
  `run_script` (1,535), more than `read` (748), and 11× the 191 `start_task`
  calls that opened the tasks being evaluated [1]. Whatever the loop is doing,
  a large share of it is asking again whether the work landed.

## Context

- **Twenty tools directly, the rest through one.** `Engine.tools/1` names the
  four Alloy core tools, `run_script` / `run_browser_script` / `tool_docs`, the
  four-tool graph spine, and nine more a script may not call [3]. The budget is
  the reason: measured before the move, the full catalogue was "111 tools,
  82,591 bytes, ~20,600 tokens, paid by every agent at connect for a task that
  calls three or four of them" [14]. `CodeMode.Catalog`'s `@excluded` map records
  a reason per tool, and that reason is the error text — because absence alone
  produces `attempt to call a nil value (global 'ask_user')`, which reads like a
  typo rather than a rule [17].
- **It runs hot.** "In continuous mode a turn ends every 15-20 seconds — the
  loop delivers a message, the agent acts, it settles, the decision sends
  another" [3]. `@max_turns` is 150 rather than Alloy's 25, raised after a QA
  agent was cut off twice at 26 calls while getting a game into the state it
  needed to look at anything [3].
- **It has an `agent_id` and no session.** There is no session column on
  `agents` [1]. Both mechanisms that once assumed otherwise now take the agent:
  `Alert.check/3` is `(scope, session_id, agent_id)` and the internal transport
  passes `nil` for the first [10][11]; `stuck?/3` keys `:persistent_term` on
  `agent.id` [6].
- **It dies with the harness, and the transcript is the state.** Turns are
  persisted server-side and `Alloy.Agent.Server` accepts `:messages`, so coming
  back is starting a process with the history it had [3][20]; `Compaction`
  reports what Alloy's own compaction kept so a restart resumes from the summary
  rather than from a conversation nobody can hand a model [18].
- **Its provider is not a tool runtime.** `Alloy.Provider.ClaudeCode` drives an
  inner `claude -p` with `--tools ""`, `--strict-mcp-config`, `--safe-mode` and
  `--permission-prompts none`, so the CLI returns `tool_use` blocks for Alloy's
  loop to execute instead of doing the work itself — "load-bearing, not a
  hardening afterthought", and a failure here "fails as *wrong output*, not as
  an error" [19]. Tool calls are then dispatched by `Alloy.Tool.Executor`,
  sequential tools first and the rest concurrently under a supervisor [20].
- **Work now reaches it without a person routing it.** `GraphWatcher` recomputes
  on a 2s debounce and calls `Agents.wake_project_roles/2` directly rather than
  through its own broadcast, each agent's menu rendered from its own checkout's
  vantage [21][22]. The `{:graph_updated, project_id}` event it also emits is
  consumed by nothing in `lib/` — the only subscriber in the tree is a test [21].

## Decision Drivers

- **Messaging over hooks, and the content shared.** John: *"for external agents
  we deliver via queueing to the stop hook, for the internal one we use
  messaging."* `StopDecision` is explicitly "the second renderer, not a second
  decision" — same `validate_stop/3`, same `Menu.render/2`, different envelope
  [6][7]. The compile-time proof is that `Hooks` depends on `McpServers` and
  Boundary refused the reverse reference, which is why `Analysis.Alert` moved
  out of `Hooks` entirely: "the persona split from story 890 arriving as a
  compile error" [10].
- **A message costs a turn, so silence is a real answer.** Stated three times
  across the two delivery paths: an agent woken to be told its tree is clean has
  been charged for no information [6]. It is why `wake_project_roles/2` is
  menu-gated, why `do_wake/2` returns `:ok` on an empty menu, and why the
  analyzer alert pushes the fact and makes the agent pull the detail [6][10][21].
- **Analyzers run when the agent is done, not between tool calls.** Each settle
  used to enqueue a full sweep against a ~176s spex run: "measured on one working
  copy: 84 superseded against 26 completed", so the decision an agent got was
  built from a tree several turns stale. John: *"it should only run the analyzer
  when the agent is fully done, not like between tool calls and stuff."* The
  non-empty queue is the whole signal [3].
- **An empty tool list must not read as a decision the agent made.** Both
  documented "No such tool available" mechanisms are silent to the agent about
  which of them is happening — "nothing signals which of the three is missing"
  [14] — and the leak's own fix replaces the client rather than reusing it,
  because "an agent restarted because something was wrong with it is the last
  caller that should inherit" the previous session's transport and headers [13].
- **Waking is not routed through a broadcast.** `GraphWatcher` wakes agents
  directly and says why: routing it through a second process subscribing to our
  own event "would put a mailbox between a graph that moved and the agent that
  has been waiting for it" [21].

## Quotes

Verbatim, from live transcripts of agents of this class [12]:

> "Every tool I attempted this turn failed with 'No such tool available' —
> evaluate_task, run_script, run_browser_script, read, write, edit, bash,
> tool_docs, and even send_message. Only tap_out has been functioning this
> session. … Standing by until tools are restored or the pending tap-out is
> resolved." — 2026-09-09 00:15:57

> "This is the third consecutive turn where every tool I try — `bash`,
> `run_script`, and now `tap_out` — returns 'No such tool available.' … Since no
> tool call succeeds, including the one meant for exactly this situation, I have
> no way to act or to signal out through the normal channel. Stopping here
> rather than repeating identical failing calls; this needs to be fixed from
> outside the session." — 2026-09-11 02:34:30

> "I'll stop retrying every single turn and just report status when asked, since
> repeated identical failures aren't new information." — 2026-09-09 00:16:23

> "This is a repeat of the same 273-problem report. Every listed spex finding is
> explicitly tagged '(not edited by this session)' …" — 2026-09-08 15:11:02

## Behaviors

Measured across all 10,521 tool calls the class has made on this project,
2026-09-03 to 2026-09-11, sixteen agents [1]:

| tool | calls | tool | calls |
|---|---:|---|---:|
| `bash` | 2,883 | `write` | 156 |
| `evaluate_task` | 2,163 | `start_analysis` | 100 |
| `run_script` | 1,535 | `read_knowledge` | 95 |
| `read` | 748 | `ask_user_question` | 73 |
| `get_next_requirement` | 729 | `semantic_search` | 33 |
| `run_browser_script` | 657 | `send_message` | 28 |
| `edit` | 534 | `promote` | 20 |
| `tool_docs` | 427 | `list_knowledge` | 7 |
| `tap_out` | 250 | `check_answer` | 5 |
| `start_task` | 191 | `show_in_panel` | 5 |

By role: coding 6,895, qa 2,217, product 732, main 677 [1]. It is a shell-first
agent that reaches the project's own tools through one script tool and a
schema lookup, and it evaluates its work far more often than it starts it.

## Anti-Patterns

- **Do not port the hook shape.** Firing a synthetic Stop for this agent would
  import `pending_analysis?` and the curl-and-stop-again dance into the one
  runtime with a better option, and would block the process the message needs
  to reach [6][9].
- **Do not treat `session_id` as its identity.** It has none [1]. Both
  mechanisms that assumed one have been re-keyed on the agent [6][10][11].
- **Do not offer it a tool that cannot run here.** The `semantic_search` offer
  costs three lines of every refusal and returns an error every time [4][7][15].
  An offer that is structurally dead teaches the class to skip the offers.
- **Do not read a quiet agent as a working one.** A turn that failed used to
  have nowhere to report, and "quiet is what an agent thinking looks like, which
  is the one thing it must not be indistinguishable from" [3].
- **Do not add a second delivery path.** `StopDecision.wake/2` is deliberately in
  the same module as `deliver/2` because "a second delivery path would drift
  from this one, and the drift would be invisible until an agent stopped hearing
  from one of them" [6].

## Evidence

All codebase citations read at commit `1555655b` on 2026-09-11. Database
citations are read-only queries against `code_my_spec_dev` on the same date.

1. `code_my_spec_dev` database, 2026-09-11. Tool-call census:
   `conversation_messages` joined to `conversations` and `agents`, where
   `jsonb_typeof(tool_calls)='array'` — 10,521 calls, all from `engine='alloy'`
   agents, 16 distinct agents, 2026-09-03 to 2026-09-11; per-tool and per-role
   breakdowns as tabulated under Behaviors. Also: 121 `agents` rows total, 117
   `alloy` / 4 `claude_code`; no session column on `agents`
   (`information_schema.columns`); 250 `tap_out`, 33 `semantic_search`.
2. `lib/cms_harness/agents.ex` @ `1555655b` — `launch/1`, `message/4`,
   `send_message/4`, `status/1`, `withdraw/2`.
3. `lib/cms_harness/agents/engine.ex` @ `1555655b` — moduledoc (supervised
   process, dies with the harness, transcript is the state); `@max_turns 150`
   and the 2026-09-07 cut-off it was raised for; `tools/1` and its rationale;
   `announce_turn_end/1` and the "84 superseded against 26 completed"
   measurement with John's quote; `announce_outcome/2` on quiet failure;
   `mcp_session/1`'s warning that an agent without a session "can read and edit
   its checkout and cannot reach the project's tools until it restarts".
4. `mix.exs` @ `1555655b` — `{:alloy, git: …/Code-My-Spec/alloy, branch: "main"}`
   and why it is a fork; `{:ortex, "~> 0.1", only: [:dev_cli, :prod_cli,
   :cli_demo, :dev_sprite]}` and `{:sqlite_vec, "~> 0.1.0", only: [:dev_cli,
   :prod_cli, :cli_demo]}`.
5. `lib/code_my_spec/agents/agent.ex` @ `1555655b` — `@roles [:main, :product,
   :coding, :qa]`, `continuous` field.
6. `lib/code_my_spec/agents/stop_decision.ex` @ `1555655b` — moduledoc ("the
   second renderer, not a second decision", John's transport quote, "silence is
   a real answer"); `deliver/3`; `wake/2` and `do_wake/2`; `keep_working/2`;
   `stuck?/3` with `@stuck_threshold 5`.
7. `lib/code_my_spec/validation/menu.ex` @ `1555655b` — moduledoc "Three offers,
   none conditional" and the "most often skipped in practice, and the most
   expensive" passage; `offers/1` emitting the unconditional `semantic_search`
   line; `render/2`'s `""` terminus.
8. `plugins/claude/hooks/hooks.json` @ `1555655b` — the seven Claude Code hook
   events this runtime does not produce.
9. `lib/code_my_spec/hooks/stop.ex` @ `1555655b` — `decide/2`,
   `pending_analysis?/1`, `wait_directive/1`, `@total_response_cap`: the
   hook-shaped parts with no internal counterpart.
10. `lib/code_my_spec/analysis/alert.ex` @ `1555655b` — moduledoc on why it moved
    out of `Hooks` ("the persona split from story 890 arriving as a compile
    error"), push-the-fact/pull-the-detail, working-copy scoping;
    `lib/code_my_spec/hooks/analysis_alert.ex` @ `1555655b` — the delegating
    shim, `check(scope, session_id, agent_id)`.
11. `lib/code_my_spec/mcp_servers/agent_alert.ex` @ `1555655b` — `append/3`
    putting the alert on an internal agent's tool result, `Alert.check(scope,
    nil, agent_id)`, per-agent dedup.
12. `code_my_spec_dev` database, `conversation_messages`, 2026-09-11 — 126
    messages containing "No such tool available", min 2026-09-08 15:10:40, max
    2026-09-11 12:05:40, hourly distribution (64 in 2026-09-09 00:00; 15 in
    2026-09-10 17:00; 24 in 2026-09-11 02:00); 25 messages containing "not
    edited by this session". All quotes under Quotes are the `content` column
    verbatim at the timestamps given.
13. `lib/cms_harness/mcp/transport/anubis.ex` @ `1555655b` — `replace_leaked/4`
    and the comment above it: the unlinked supervisor, the doubly-wrapped
    `{:already_started, pid}`, the 02:24 incident watched end to end, and why
    the leaked client is replaced rather than reused. Also `client_info/1` and
    the ETS-table collision that produced `:start_timed_out` and "thirteen
    restore attempts in a row failed".
14. `lib/code_my_spec/mcp_servers/local_server.ex` @ `1555655b` — moduledoc "A
    new tool needs three things": the cached client tool list producing "No such
    tool available" for a tool the server answers on, the raw JSON-RPC proof
    (`b2d9c616`), "nothing signals which of the three is missing"; and the
    pre-move measurement of 111 tools / 82,591 bytes / ~20,600 tokens.
15. `lib/code_my_spec/mcp_servers/knowledge/tools/semantic_search.ex` @
    `1555655b` — the `{:error, :embeddings_unavailable}` branch and its exact
    message; `lib/code_my_spec/embeddings.ex` @ `1555655b` — every entry point
    returning that error when no backend is configured.
16. Story 1004 (*Idle agents are left alone*), notes, read 2026-09-11 — "1015's
    rule that every refusal offers searching the project's documentation
    currently prints a dead option for internal agents - semantic_search does
    not run in our BEAM. Recorded on 1015 and on 1061; not this story's to fix."
17. `lib/code_my_spec/code_mode/catalog.ex` @ `1555655b` — the `@excluded` map,
    a reason per tool, and the `attempt to call a nil value (global 'ask_user')`
    rationale; the 2026-09-05 `get_next_requirement` observation and the
    `promote` two-dead-ends observation.
18. `lib/cms_harness/agents/compaction.ex` @ `1555655b` — the `:after_compaction`
    middleware and why the telemetry event was not enough.
19. `deps/alloy/lib/alloy/provider/claude_code.ex` @ Alloy fork `main` — the
    tool-suppression section: `--tools ""`, `--strict-mcp-config`, `--safe-mode`,
    `--permission-prompts none`, and why `--permission-mode plan` was removed.
20. `deps/alloy/lib/alloy/tool/executor.ex` @ Alloy fork `main` — `execute_all/4`,
    sequential-then-concurrent partitioning under `Alloy.TaskSupervisor`;
    `deps/alloy/lib/alloy/agent/server.ex` — the supervised GenServer wrapping
    `Turn.run_loop/1`, `chat/3`, and the `alloy_agent` move notice.
21. `lib/code_my_spec/requirements/graph_watcher.ex` @ `1555655b` — the 2s
    coalescing debounce, the fingerprint deciding, the direct
    `wake_project_roles/2` call and why it is not routed through the broadcast,
    and `{:graph_updated, project_id}` on `GraphInputs.topic/1`. Confirmed by
    grep over `lib/` and `test/`: the only subscriber asserting on that message
    is `test/code_my_spec/requirements/the_graph_recomputes_when_its_inputs_move_test.exs:158`.
22. `lib/code_my_spec/agents.ex` @ `1555655b` — `record_turn_event/4`'s
    `"turn_ended"` clause routing to `StopDecision.deliver/3` (annotated "Story
    1043"); `wake_project_roles/2`, `at_agents_vantage/2` and the
    `Preloader.load/1` blended-vantage warning; `project_wakeable?/2`.
23. Stories 987 (*Analysis results reach the agent running inside our own BEAM*,
    external id 1042) and 988 (*The stop decision reaches the agent running
    inside our own BEAM*, id 1043), read 2026-09-11 — the rules, the two
    delivery moments, the enabling fact about `Engine.send_message/4`, and
    John's transport quote. 17 acceptance criteria between them, 0 verified at
    time of writing.
24. Stories 1003, 1004 and 1005 (ids 1046, 1047, 1048), read 2026-09-11 — the
    promotion gate this persona's coding role owns, the idle-agent scoping, and
    the graph-to-agent routing. All five stories are linked to this persona in
    `persona_stories`.
