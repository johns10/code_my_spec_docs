# QA Brief — Story 1004: Idle agents are left alone

## Tool

`curl` (dev-only HTTP control surface + local MCP server) and `psql` (direct read of `conversation_messages`/`agents`), with `mix spex` file-reading (not execution) for contract cross-reference.

This story has no LiveView/browser surface of its own. `CodeMySpec.Agents` is a server-side context whose observable behavior is push messages into an agent's conversation and the stop-hook HTTP response — there is nothing to click. Three real, non-mutating-of-other-work surfaces exist and are all in scope:

1. **`GET/POST http://localhost:4000/dev/agents*`** — a `:dev_routes`-gated (compile-time, present on this dev box's `:4000`), unauthenticated JSON control surface built explicitly for this kind of debugging (`lib/code_my_spec_web/controllers/dev_agent_controller.ex`). Lists every agent on the box, its status/role/working copy, pending questions, and can message/stop/restart/staff an agent or an epic's working copy.
2. **`http://localhost:4004/mcp`** (this worktree's own local MCP server) — the typed `mcp__plugin_codemyspec_local__*` wrappers for `list_agents`, `read_agent_conversation`, `list_issues`, `get_issue`, `create_issue`, `list_qa_attempts`, `submit_qa_result`, `assign_epic_to_working_copy` are **not** in this session's frontmatter (story 971 moved them behind `run_script`/code-mode), so reach them the way `qa-tooling.md`'s curl section documents: `initialize` → `notifications/initialized` → `tools/call` with `name: "run_script"`, `arguments: { script = "return <tool>({ ... })" }`, echoing `Mcp-Session-Id`. `tool_docs({ name = "<tool>" })` must be called directly (not from inside a script) for each tool's exact argument shape.
3. **`psql -d code_my_spec_dev`** — read-only queries against `conversation_messages` (columns: `role`, `sender_id`, `content` (jsonb), `origin`, `delivery`, `delivery_ref`, `inserted_at`) and `agents`. Safe against the live `:4000` server (no compile, no lock) and gives microsecond-precision ordering that the conversation-reader tools round away — this is how the duplicate-nudge finding below was caught.

**Do not run `mix spex`, `mix compile`, or any other `mix` invocation while `:4000`/`:4001`/`:4003`/`:4004` are live** — confirmed all four are up (`lsof -i -P -n | grep LISTEN`) — a mix compile contends the BEAM's compile lock with the live dev server. Read the spex `.exs` files with `Read`/`cat` for the exact assertions instead; they are the contract-level backstop, not something to execute here.

## Auth

- `/dev/agents*` (port 4000): none. `:dev_routes` scope, `:api` pipeline, no auth plug — confirmed live (`curl -s -o /dev/null -w '%{http_code}\n' http://localhost:4000/dev/agents` → `200`).
- `/mcp` (port 4004, this worktree's own harness): `X-Harness-Id` header from this worktree's own `.cms_harness.json`:

  ```
  HID=$(python3 -c "import json;print(json.load(open('.cms_harness.json'))['harness_id'])")
  ```

  (Resolves to `9f77b922-9810-4b49-931d-b073012bc317` for this worktree as of this session — re-derive it, don't hardcode, since `.cms_harness.json` is per-checkout.)
- `psql`: local trust auth, no password — `psql -d code_my_spec_dev -c "<query>"`.

No login flow, no seeded user credentials, no Vibium browser session applies to this story.

## Seeds

No new seed data is needed. Three pre-existing pieces of live-fleet state carry this story's testing, all already present on the shared dev box:

1. **The dedicated story-1004 QA fixture**, minted by a prior QA attempt on this exact story specifically so state-mutating scenarios (assigning work, checking for a nudge) would not touch anyone else's real work:
   - Working copy `f63414b4-a744-4e94-8aa3-6213ca4a5f9e`, root `.claude/worktrees/1004-qa-idle-agent-nudge`
   - Coding agent `763f3f20-3ecc-4327-84d3-db1413b00e5f`
   - **Consumed state, check before reusing**: this fixture's coding lane is *not* currently idle — it already carries a real 47-criterion story (1020, `bdd_specs_exist`, 22–40+/47 missing across recent checks) as open work, so it cannot currently demonstrate the "nothing to do → work appears" transition (3178/3180) without first draining that backlog, which is out of QA's scope. Re-verify its current `list_tasks`/`read_agent_conversation` state before trusting anything above holds — the box's harness has restarted repeatedly today and re-synced state each time.
2. **Two prior real QA attempts on this exact story** (`b1164b82`, `b918e008`, both `status: partial`) are already on record via `list_qa_attempts({ story_id = 1004 })`. Read them first — they name a real fixed regression (issue `a0780389`, resolved: "switching a copy on wakes against an uncomputed graph") and a dismissed-duplicate framework gap (`b75bd3f4`: the `:qa` agent role's `ScriptableTools` grant carries none of `list_agents`/`read_agent_conversation`/`assign_epic_to_working_copy` — by design, per `CodeMySpec.Agents.ToolSets.@qa`). **This session's own harness identity is registered role `coding` (agent `880c7713`, this worktree), not `qa`, and does *not* hit that refusal** — `list_agents`/`read_agent_conversation`/`list_qa_attempts` all answered normally when probed. That asymmetry between a spawned `:qa`-role subagent and a top-level Claude Code session driving the same MCP server directly is itself worth a line in the result — future QA subagents spawned with `role: qa` will hit the refusal this brief's tester did not.
3. **The live fleet itself** (`list_agents` / `GET /dev/agents`) — read-only unless you are the one who started a process. Do not message, stop, restart, or otherwise mutate any agent that is not `763f3f20` (the story-1004 fixture) or your own harness's agent (`880c7713`) — every other running agent (`math_test_project`, `broken_oaths`, `963-main-agent-nontechnical`, the top-level `code_my_spec` main agent, the `qa_sandbox` mains) is somebody else's real, live work.

Do **not** call `POST /dev/copies/:working_copy_id/staff` to mint a *new* coding agent for this pass — that is real provisioning (a live Alloy/Claude process against a real API key) and this story's own prompt is explicit that QA should not do unauthorized provisioning. Everything below is reachable with agents that are already running.

## What To Test

Cross-reference against `.code_my_spec/spec/code_my_spec/agents.spec.md` and the twelve spex files under `test/spex/1047_idle_agents_are_left_alone/` for exact assertions; each scenario below names the criterion.

1. **3187 — The turn ends, the process does not.** `GET http://localhost:4000/dev/fleet` and `GET /dev/agents` for `763f3f20` and `880c7713`; confirm `status: "running"` (not `"stopped"`/absent) across at least two checks several minutes apart while no real coding work is completing. Corroborates the prior attempt's pass (verified on a different agent, `0067d652`).

2. **3181 — A turn ends with nothing to do and nothing is sent.** `psql` `conversation_messages` for an agent currently idle (check `list_agents`/`read_agent_conversation` first for one with no open tasks) over a multi-minute window with no `git`/`mix` activity from that agent; confirm zero operator-role messages that are not either a harness-restart notice or a direct answer to that agent's own question.

3. **3182 — The nudge names the open task.** `psql` on `conversation_messages` where `role='operator'` for `763f3f20` or `0067d652`, most recent rows. Confirm the message text names a specific open task (title/id), e.g. `"Next: you have N open tasks, most recently — `<task_name>`. It is open because: <reason>"` with a concrete `task_id`. Already observed live on `0067d652` (task `implementation_file`, task_id `6440ac51-b560-4d15-aa29-95e275d11a2a`) — re-verify current state, it will have moved on.

4. **3178/3180/3196 — Coding work appears and the agent is told / one nudge per turn / no second message beside the menu.** These need a genuine transition, not steady-state reading. Two paths, try both:
   - **Passive**: watch `conversation_messages` for any agent for a `role='operator'` wake (`"Work of your kind is available"` or similar) that is **not** immediately preceded by a `"harness restarted"` row for the same agent within the prior few seconds, and check whether more than one such wake lands within a short window (sub-second to low-single-digit-second apart) for what should be one triggering event. **A concrete lead**: on 2026-09-17 12:18:53 UTC, agent `0067d652`'s conversation received **three byte-identical `"Work of your kind is available"` operator messages 128ms apart** (`12:18:53.559248`, `.567288`, `.687537`), all naming the same task (`implementation_file`, task_id `6440ac51-...`), with no real turn boundary between them. If this reproduces (or is still visible in the history — the rows should still be there), it is a live counter-example to 3180/3196's "one nudge" contract even though the in-process spex for those criteria pass; file it as a real `scope: app` finding with the exact timestamps and message ids, distinct from the already-resolved `a0780389`.
   - **Active** (only on the dedicated fixture `763f3f20`, only if its current backlog is small enough that this is proportionate): `tool_docs({ name = "list_working_copies" })` then `assign_epic_to_working_copy` a small epic to working copy `f63414b4` once its existing backlog is otherwise clear, then `read_agent_conversation({ agent_id = "763f3f20-..." })` for a fresh nudge naming the newly-assigned work.

5. **3183 — Problems on the agent's own work are named as the work.** In the same operator wake text as (3), check whether a *reason* a task is open (e.g. `"implementation file missing"`, `"22 of 47 criteria missing bdd_spec file"`) is folded into the task line itself rather than delivered as a separate, generic "there's a problem" message. Confirm no standalone message exists that names a problem without naming which task it belongs to.

6. **3179 — QA work waiting does not wake the coding agent.** Find (via `list_issues`/`list_qa_attempts`/`list_tasks` across the fleet, or by reasoning from story state) a project/story with QA-role work outstanding but no coding-role work, and confirm no coding-role agent on that project received a wake in that window. This is the hardest to construct live without touching someone else's project; if no clean live instance exists, say so explicitly and cite the passing spex (`criterion_3179_*`) rather than fabricate a pass.

7. **3184 — Two coding agents, and only the assigned one is woken.** Project `708492f9` (the real CodeMySpec project) currently has exactly two coding-role agents: `763f3f20` (the fixture) and `880c7713` (this session's own worktree). Messaging or observing `880c7713` as a test subject is not meaningful (it is this QA session). Do not attempt to mint a second disposable coding agent to force this scenario (see Seeds — no new provisioning). Record this as **not independently live-verifiable this pass** and cite the passing spex.

8. **3185 — A story interview reaches the main agent.** Only one main-role agent exists on project `708492f9` (`b49cb24a`, the top-level `code_my_spec` checkout) and it is real production work — do not message or observe-and-act on it beyond a passive `read_agent_conversation` check for whether a recent story-interview event produced exactly one nudge. If nothing recent to observe, cite the spex and issue `a0780389` (found and fixed while making this exact criterion green) as contract-level + regression-history evidence.

9. **3186 — The main agent with nothing assigned is left alone too.** Passive `read_agent_conversation`/`psql` check on any idle main-role agent (e.g. one of the `qa_sandbox` mains on project `11111111-...`, which is QA's own sandbox and safe to read) for the same "no spurious message" pattern as (2), scoped to the main role specifically.

10. **3195 — A nudge names work that has already been done.** Passive: look for any operator wake in the fleet's recent history that names work, followed by the agent's own turn finding it already done (assistant text like "already landed"/"no change"/"already deployed") **and** confirm the agent was not immediately re-nudged with the same stale instruction. The `0067d652` "No change since the last check" sequence at 12:19:05–12:19:30 (following the 12:18:53 triple-wake) is a candidate — the agent correctly declined to invent new work across four consecutive checks, which is the "it is allowed to stop" half of this criterion holding even though the wake delivery itself (finding 4, above) did not.

11. **Every scenario**: note explicitly which were live-verified (with psql/curl evidence quoted) vs. which fall back to spex-only coverage, and say why for each spex-only one. Do not report `pass` on a scenario this session could not actually observe.

## Result Path

No `result.md` file — per `priv/knowledge/qa_story/workflow.md`, this project's QA loop has no result-file artifact. File every finding via `create_issue` as it's found (reached through `run_script` over curl per the Tool section, since the typed wrapper is not in this session's frontmatter), hold the returned ids, and end with one `submit_qa_result` call (also via `run_script`) carrying `task_id`, `status`, structured `scenarios`, and every `issue_ids` collected. Build this attempt as a continuation of the existing history (`list_qa_attempts({ story_id = 1004 })`) rather than re-deriving already-settled scenarios from scratch.

## Setup Notes

- The shared dev box's harness has restarted many times during this investigation (visible as repeated `"The harness restarted"` operator rows across multiple agents' conversations within the same hour) — this is environmental churn from other sessions on the shared box, not something this QA pass caused or should try to fix.
- `list_qa_attempts`, `create_issue`, `get_issue`, `list_issues`, `submit_qa_result` were all reachable from this session without the `:qa`-role refusal documented in `b75bd3f4`/`50eac6ab`. Re-confirm this still holds at the start of the test phase — if a fresh session hits the refusal, that itself is the finding (file it referencing `50eac6ab`, don't rediscover it from zero).
- `run_script` requires calling `tool_docs({ name = "<tool>" })` **directly** (not from inside a script) to get exact argument names/types — several tools (`get_issue`'s `issue_id` vs `id`, `list_qa_attempts`' integer `story_id`) reject on the first guess.
