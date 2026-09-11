# Sources — Internal Alloy Agent

Re-researched 2026-09-11. Codebase citations are pinned to `1555655b` so each
line is reproducible at the commit it was read at; Alloy's own files are in
`deps/` at the fork's `main` (`{:alloy, git: "https://github.com/Code-My-Spec/alloy.git", branch: "main"}`,
tracking upstream `alloy-ex/alloy` 0.12.4). Database citations name both the
schema the rows live behind and the query that produced the number.

## Codebase — the runtime this agent is

- `lib/cms_harness/agents/engine.ex` @ `1555655b` — the whole persona in one
  file: the moduledoc on being a supervised process rather than a detached `pi`,
  `@max_turns 150` and the 2026-09-07 QA cut-off that raised it from Alloy's 25,
  `tools/1` and the twenty modules it names, `announce_turn_end/1` with the
  "84 superseded against 26 completed" measurement and the 15-20s turn rhythm,
  `announce_outcome/2` on a quiet failed turn, `mcp_session/1`'s warning that an
  agent with no session "can read and edit its checkout and cannot reach the
  project's tools until it restarts". Accessed 2026-09-11.
- `lib/cms_harness/agents.ex` @ `1555655b` — `launch/1` taking a working copy,
  provider, credential and role; `message/4`, `send_message/4`, `withdraw/2`,
  `status/1`. Accessed 2026-09-11.
- `lib/cms_harness/agents/compaction.ex` @ `1555655b` — the `:after_compaction`
  middleware reporting what survived so a restarted agent resumes from the
  handoff summary, and why the `[:alloy, :compaction, :done]` telemetry event
  was not enough. Accessed 2026-09-11.
- `lib/cms_harness/mcp/transport/anubis.ex` @ `1555655b` — `replace_leaked/4`
  and the comment above it: the deliberately unlinked supervisor, the
  doubly-wrapped `{:already_started, pid}`, the 02:24 incident watched end to
  end ("came back with no tools at all … three restarts each answered 'running'
  and changed nothing"), and `client_info/1`'s per-session ETS table name.
  Accessed 2026-09-11.
- `lib/code_my_spec/agents/agent.ex` @ `1555655b` — `@roles [:main, :product,
  :coding, :qa]`, the `continuous` flag, and the absence of any session field.
  Accessed 2026-09-11.
- `lib/code_my_spec/agents.ex` @ `1555655b` — `record_turn_event/4`'s
  `"turn_ended"` clause routing to `StopDecision.deliver/3`;
  `wake_project_roles/2`, `project_wakeable?/2` and `at_agents_vantage/2` with
  the `Preloader.load/1` blended-vantage warning. Accessed 2026-09-11.
- `./mix.exs` @ `1555655b` — the Alloy fork and why it is one; `{:ortex,
  "~> 0.1", only: [:dev_cli, :prod_cli, :cli_demo, :dev_sprite]}` and
  `{:sqlite_vec, "~> 0.1.0", only: [:dev_cli, :prod_cli, :cli_demo]}`, which is
  why embeddings do not exist in the BEAM that serves this agent's tools.
  Accessed 2026-09-11.

## Codebase — how the orchestrator now reaches it

- `lib/code_my_spec/agents/stop_decision.ex` @ `1555655b` — "the second
  renderer, not a second decision"; John's transport quote; `deliver/3`;
  `wake/2` / `do_wake/2`; `keep_working/2` and the `""` terminus; `stuck?/3`
  with `@stuck_threshold 5` and the tag that keeps the decision's and the
  nudge's counters apart. Accessed 2026-09-11.
- `lib/code_my_spec/analysis/alert.ex` @ `1555655b` — why the alert left
  `Hooks` ("the persona split from story 890 arriving as a compile error"), the
  push-the-fact/pull-the-detail shape, working-copy scoping, and the 2026-08-12
  incident it was built for. Accessed 2026-09-11.
- `lib/code_my_spec/mcp_servers/agent_alert.ex` @ `1555655b` — `append/3`
  putting `Alert.check(scope, nil, agent_id)` on this agent's tool result
  instead of a `PostToolUse` footer, and why a human's call gets nothing.
  Accessed 2026-09-11.
- `lib/code_my_spec/hooks/analysis_alert.ex` @ `1555655b` — the delegating shim
  left behind, `check(scope, session_id, agent_id)`. Accessed 2026-09-11.
- `lib/code_my_spec/validation/menu.ex` @ `1555655b` — the transport-blind
  content both agents share; "Three offers, none conditional"; `offers/1`
  emitting the unconditional `semantic_search` line; the passage naming it "the
  one most often skipped in practice, and the most expensive". Accessed
  2026-09-11.
- `lib/code_my_spec/hooks/stop.ex` @ `1555655b` — `decide/2`,
  `pending_analysis?/1`, `wait_directive/1` and `@total_response_cap`: the
  hook-shaped parts that deliberately have no internal counterpart. Accessed
  2026-09-11.
- `lib/code_my_spec/requirements/graph_watcher.ex` @ `1555655b` — the 2s
  coalescing debounce, "writer side events are the way I think", the direct
  `wake_project_roles/2` call rather than a self-subscription, and the
  `{:graph_updated, project_id}` broadcast on `GraphInputs.topic/1`. Accessed
  2026-09-11.
- `test/code_my_spec/requirements/the_graph_recomputes_when_its_inputs_move_test.exs`
  @ `1555655b`, line 158 — the only `assert_receive {:graph_updated, …}` in the
  tree; a grep of `lib/` finds no consumer at all. Accessed 2026-09-11.
- `plugins/claude/hooks/hooks.json` @ `1555655b` — the seven Claude Code hook
  events that are properties of that CLI and that this runtime never produces.
  Accessed 2026-09-11.

## Codebase — the tool surface and its failure modes

- `lib/code_my_spec/mcp_servers/local_server.ex` @ `1555655b` — "A new tool
  needs three things, and two of them are not the server": a client caching its
  tool list at connect means "a tool the server has compiled, loaded and
  answered on is still `No such tool available` to any session that connected
  earlier"; the raw JSON-RPC proof (`b2d9c616`); "nothing signals which of the
  three is missing". Also the pre-`run_script` measurement — 111 tools, 82,591
  bytes, ~20,600 tokens paid at connect. Accessed 2026-09-11.
- `lib/code_my_spec/code_mode/catalog.ex` @ `1555655b` — the `@excluded` map
  with a reason per tool, the `attempt to call a nil value (global 'ask_user')`
  rationale, and the 2026-09-05 and `promote` observations of agents hitting
  exactly that. Accessed 2026-09-11.
- `lib/code_my_spec/mcp_servers/knowledge/tools/semantic_search.ex` @
  `1555655b` — the `{:error, :embeddings_unavailable}` branch and its exact
  agent-facing message. Accessed 2026-09-11.
- `lib/code_my_spec/embeddings.ex` @ `1555655b` — every entry point returning
  `{:error, :embeddings_unavailable}` when no backend is configured. Accessed
  2026-09-11.
- `lib/code_my_spec_web/channels/harness_project_channel.ex` @ `1555655b` — the
  data plane this agent's work travels over, and why it is a channel rather
  than REST. Accessed 2026-09-11.

## Upstream — Alloy, at the fork's `main`

- `deps/alloy/lib/alloy/agent/server.ex` — the supervised GenServer wrapping
  the stateless `Turn.run_loop/1`, `chat/3`, `:messages` at start, and the
  notice that the runtime is moving to the `alloy_agent` package in 0.13.0.
  Accessed 2026-09-11.
- `deps/alloy/lib/alloy/provider/claude_code.ex` — the tool-suppression
  section: `--tools ""`, `--strict-mcp-config`, `--safe-mode`,
  `--permission-prompts none`, why suppression is "load-bearing, not a
  hardening afterthought", why a breach "fails as *wrong output*, not as an
  error", and why `--permission-mode plan` was removed. Accessed 2026-09-11.
- `deps/alloy/lib/alloy/tool/executor.ex` — `execute_all/4`, the
  sequential-then-concurrent partition under `Alloy.TaskSupervisor`, and
  `on_timeout: :kill_task`. Accessed 2026-09-11.

## Observed behaviour — the dev database

All read-only queries against `code_my_spec_dev` on 2026-09-11, each named
beside the schema module the rows live behind.

- `lib/code_my_spec/conversations/message.ex` @ `1555655b` — the
  `conversation_messages` schema behind the tool-call census. Query:
  `select jsonb_array_elements(tool_calls)->>'name', count(*) from
  conversation_messages where jsonb_typeof(tool_calls)='array' group by 1
  order by 2 desc`. Result: 10,521 calls — `bash` 2,883, `evaluate_task` 2,163,
  `run_script` 1,535, `read` 748, `get_next_requirement` 729,
  `run_browser_script` 657, `edit` 534, `tool_docs` 427, `tap_out` 250,
  `start_task` 191, `write` 156, `start_analysis` 100, `read_knowledge` 95,
  `ask_user_question` 73, `semantic_search` 33, `send_message` 28, `promote` 20,
  `list_knowledge` 7, and a tail of five or fewer each.
- `lib/code_my_spec/agents/agent.ex` and
  `lib/code_my_spec/conversations/conversation.ex` @ `1555655b` — the join that
  attributes the census. Query: the same, joined `conversation_messages` →
  `conversations` → `agents`. Result: every one of the 10,521 calls belongs to
  an `engine='alloy'` agent, 16 distinct agents, 2026-09-03 to 2026-09-11; by
  role coding 6,895, qa 2,217, product 732, main 677.
- `lib/code_my_spec/agents/agent.ex` @ `1555655b` — the `agents` schema. Query:
  `select engine, status, continuous, count(*) from agents group by 1,2,3`.
  Result: 117 `alloy` rows against 4 `claude_code`, of which 6 are
  `continuous`. And `select column_name from information_schema.columns where
  table_name='agents' and column_name like '%session%'` returns nothing — this
  agent has no session id.
- `lib/code_my_spec/conversations/message.ex` @ `1555655b` — the outage
  evidence. Query: `select count(*), min(inserted_at), max(inserted_at) from
  conversation_messages where content::text ilike '%No such tool available%'`.
  Result: 126 messages, 2026-09-08 15:10:40 to 2026-09-11 12:05:40; bucketed by
  hour, 64 in 2026-09-09 00:00, 15 in 2026-09-10 17:00, 24 in 2026-09-11 02:00.
  The four quotes in `.code_my_spec/personas/internal-alloy-agent/summary.md`
  are the `content` column verbatim at 2026-09-09 00:15:57, 2026-09-09 00:16:23,
  2026-09-11 02:34:30 and 2026-09-08 15:11:02.
- `lib/code_my_spec/conversations/message.ex` @ `1555655b` — the repeated-report
  evidence. Query: `select count(*) from conversation_messages where
  content::text ilike '%not edited by this session%'`. Result: 25 messages of
  an agent arguing that findings reported to it are not its.

## Stories

- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/987
  — story 987 (external id 1042), *Analysis results reach the agent running
  inside our own BEAM*: the two delivery moments, the enabling fact about
  `Engine.send_message/4` resolving a live pid, John's transport quote, 7
  criteria, 0 verified. Accessed 2026-09-11.
- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/988
  — story 988 (id 1043), *The stop decision reaches the agent running inside our
  own BEAM*: what is reused and what must not be, the "never told to wait" rule,
  10 criteria, 0 verified. Accessed 2026-09-11.
- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/1004
  — story 1004 (id 1047), *Idle agents are left alone*: the recorded inherited
  defect that "every refusal offers searching the project's documentation
  currently prints a dead option for internal agents — semantic_search does not
  run in our BEAM". Accessed 2026-09-11.
- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/1005
  — story 1005 (id 1048), *Work appearing on the graph reaches the agent who can
  do it*: the routing this persona's wake path implements. Accessed 2026-09-11.
- http://localhost:4004/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/stories/1003
  — story 1003 (id 1046), *A story's code is on the running dev copy before QA
  tests it*: the promotion gate the coding role owns, and the Broken Oaths
  2026-09-09 evidence of a QA agent spending ~40 tool calls per ten minutes
  polling git. Accessed 2026-09-11.
- `lib/code_my_spec/analysis/alert.ex` and
  `lib/code_my_spec/mcp_servers/agent_alert.ex` @ `1555655b` — both cite story
  890, the external counterpart whose persona narrowing made this one's absence
  visible, in their moduledocs. Accessed 2026-09-11.

## Upstream reference

- https://modelcontextprotocol.io/ — the client contract this agent's own
  session speaks against the project's server; the tool-list caching described
  in `lib/code_my_spec/mcp_servers/local_server.ex` is a property of that
  contract as Anubis implements it. Accessed 2026-09-11.
- https://docs.anthropic.com/en/docs/agents-and-tools/ — agent tool-use
  patterns behind the two-ways-in-plus-lookup design
  `lib/cms_harness/agents/engine.ex`'s `tools/1` settles on. Accessed
  2026-09-11.

## Self-reflection — still stated as a limit

- `./CLAUDE.md` @ `1555655b` — the author of this research runs under Claude
  Code and is an **External Claude Code Agent**, not a member of this class, so
  the agent-persona guide's allowance for first-person observation does not
  apply here and none is used. What changed on 2026-09-11 is that the class now
  has 10,521 recorded tool calls and 126 first-person transcript messages of its
  own, so its wants are read off its own words and its own behaviour rather than
  off a runtime's capabilities. It is no longer the persona nobody in the room
  has been; it is the persona that speaks for itself in the transcripts.
  Accessed 2026-09-11.
