# QA Brief — Story 1004: Idle agents are left alone

## Tool

`curl` against the local MCP surface (`http://localhost:4004/mcp`, code-mode `run_script`), plus `curl http://localhost:4000/dev/state` and `curl http://localhost:4000/dev/agents` for read-only fleet/graph-watcher status, and `Read`/`Grep` on `~/.codemyspec/{web,harness,server}.log` for corroboration.

`CodeMySpec.Agents` is a server-side context with no LiveView/browser surface of its own — the observable behavior is entirely messages pushed into an agent's conversation (`read_agent_conversation`) and the requirement graph's own state (`list_requirements`). There is nothing to click.

**Do not run `mix spex`, `mix compile`, or any other `mix` invocation while `:4000`/`:4001`/`:4003`/`:4004` are live** — a mix compile contends the BEAM's compile lock with the live dev server. The one exception is `mix cms.seed <script>`, which is explicitly DB-only (no endpoint boot) and safe to run alongside a live server — that is what provisions the fixture below.

## Auth

- `/mcp` (port 4004, the light harness proxy): `X-Harness-Id` header. For this worktree's own harness, read it from `.cms_harness.json` in the repo root. For the dedicated QA fixture project (see Seeds), use its own harness id instead — sending the wrong one routes the call to the wrong project.

  Handshake (per the QA plan's curl section): `initialize` → `notifications/initialized` → `tools/call` with `name: "run_script"`, echoing the returned `Mcp-Session-Id` header on every subsequent call. `Accept: application/json, text/event-stream` is required or the server 406s.

- `/dev/state`, `/dev/agents` (port 4000): no auth, `:dev_routes`.
- `tool_docs({ name = "<tool>" })` must be called directly (not from inside a `run_script` script) for each tool's exact argument shape — several tools reject a first guess (`accept_issue` wants `issue_id`, not `id`; `list_requirements` filters by `requirement_name`).

## Seeds

**Use the dedicated wake fixture — `mix cms.seed priv/repo/qa_wake_seed.exs`.** This is the single most-missed fixture across four prior QA passes on stories 1004/1009 (see `.code_my_spec/qa/plan.md`, "The agent sandbox"). Idempotent; safe to re-run.

It provisions (all on one project, one working copy, `continuous: true`, `status: :running`, **rows only — nothing is a real process, nothing spends tokens**):

```
Project:      d7f466a1-591e-4f36-8319-42633f59411e  (Math Test Project)
Working copy: 56f5bf62-9cf8-400d-abcd-6c796afd3437  (root: /Users/johndavenport/Documents/github/math_test_project)
Harness id:   56f5bf62-9cf8-400d-abcd-6c796afd3437  (same as working copy id — read from math_test_project/.cms_harness.json)
Agents:
  product  e9dce99a-9512-457d-b613-3baa49c387a7
  coding   25d67c11-f590-4e8e-a00d-6d3fb6bf08eb
  coding   59596b8a-1a5d-44b8-8f38-9bf1b570442d
  main     4e98e2a8-f674-4a10-9592-a1468e4b64ac
```

**Before trusting any conversation-reading result**, confirm the harness actually holds this copy: `curl -s localhost:4004/health | grep math_test_project` must show `connected: true, onboarded: true, watching: true` — `dispatch_message/3` calls the transport before it records anything, so an unheld copy makes every wake undeliverable and indistinguishable from a story defect.

No qa-role agent exists on this fixture, deliberately — criterion 3179 needs QA work left *outstanding*, and a real qa-role agent would claim it and remove the premise. Both coding agents share one working copy, deliberately — 3179's own spex moduledoc: "wrong-role wakes are only observable where the two agents share everything except the role." Getting a **second working copy** (needed for 3184's literal claim — two agents on *different* checkouts) is not provisioned by this seed and was judged out of proportion for a QA pass this cycle (would mean a second `cms.harness.onboard` on the shared box); 3184 stays spex-only.

Secondary, real-fleet state (read-only, do not mutate anything that is not yours): the real project's own agents, reachable via `list_qa_attempts({story_id = 1004})` for prior attempts' recorded evidence (four to date) and via `list_issues({story_id = 1004})` for issues already on record, including the already-filed, still-open `6f1bd3af` (duplicate wake-in-burst).

## What To Test

Cross-reference `.code_my_spec/spec/code_my_spec/agents.spec.md` and the twelve spex under `test/spex/1047_idle_agents_are_left_alone/`.

1. **3178 — Coding work appears and the coding agent is told.** Do NOT try to drive a full Three Amigos workshop live to reach `bdd_specs_exist` (`start_three_amigos_session` only returns a protocol prompt for a real multi-turn workshop — driving one unilaterally as QA is out of scope). Instead use the **issues chain**, which reaches a coding-role node (`issues_resolved`, prerequisite `issues_triaged`) in two tool calls:
   - `create_issue` (severity high) + `accept_issue` on it and on any other `incoming` issues on the fixture project — this satisfies `issues_triaged` (product) and makes `issues_resolved` (coding) newly unsatisfied/actionable in the same move.
   - Confirm the transition directly: `list_requirements({requirement_name = "issues_triaged"})` → `[x]`; `{"issues_resolved"}` → `[ ]`.
   - Confirm the recompute fired: `curl localhost:4000/dev/state?project_id=d7f466a1-...` — `graph_watcher.last_recompute` should move; corroborate in `~/.codemyspec/web.log` (`[Requirements] recomputed ...` / `[GraphWatcher] accounted for N observation(s)`).
   - Then `read_agent_conversation` on all 4 fixture agents and look for a **new** message (not a stale harness-restart notice) naming the newly-actionable item.

2. **3179 — QA work waiting does not wake the coding agent.** Same fixture, watch the coding agents specifically while only `issues_triaged` (product-role) is outstanding — before accepting anything, confirm neither coding agent receives anything.

3. **3180 / 3196 — One nudge per turn / no second message beside the menu.** Compare message *count* per agent immediately before and after one discrete trigger (one accept-issue batch = one recompute = at most one wake attempt per agent). Cross-reference the already-filed `6f1bd3af` (task-completion-driven `wake/2` delivering 2-3 byte-identical copies 128ms apart in the *real* fleet) — a different delivery path than the graph-watcher-driven one this fixture exercises, so check both independently rather than assuming one bug covers the other.

4. **3182 / 3183 — The nudge names the open task / problems are named as the work.** Read the message text itself (fixture or real fleet) for a concrete task name + task_id + reason, folded into one line rather than a separate generic "there's a problem" message.

5. **3181 / 3186 / 3187 / 3195** — best exercised against the **real fleet's own idle agents** (not this fixture, which is rows-only and has no real process to show "the turn ends, the process does not" against). `read_agent_conversation` / `/dev/agents` over a multi-minute idle window; look for silence-when-idle, `status: running` persisting, and "already done" recovery after a stale nudge. See prior attempts (`list_qa_attempts({story_id = 1004})`) for the exact agents/timestamps already used — pick a fresh idle window rather than re-citing a consumed one if re-verifying.

6. **3184 — Two coding agents, only the assigned one is woken.** Not independently constructible with the current one-working-copy fixture (the mechanism gates on `working_copy_id`, not on which specific agent process is idle vs busy — see `CodeMySpec.Agents.wakeable?/3`). Would need a second onboarded checkout for the same project; judged out of proportion this pass. Cite spex + source.

7. **3185 — A story interview reaches the main agent.** Needs a project **past kickoff with no stories yet** (`stories_exist` unsatisfied) — the wake fixture already has 3 stories, so it can't reproduce this premise. Cite spex + the resolved regression `a0780389`, found while this exact criterion was made green.

8. **Beyond the 12 criteria**: if `wake_project_roles`-driven delivery (this brief's step 1) does not land, that is a live, reproducible defect in the story's central mechanism — file it (`scope: app`, `story_id: 1004`) with exact timestamps, the confirmed before/after requirement state, and log grep results, rather than reporting the criterion as merely "not observed."

## Result Path

No `result.md` file — per `qa_story/workflow.md` this project's QA loop has no result-file artifact. File every finding via `create_issue` as it's found, hold the returned ids, and end with one `submit_qa_result` call carrying `task_id`, `status`, structured `scenarios`, and every `issue_ids` collected **this run** (not issues inherited from a prior attempt — those are already linked to their own attempt). Build on `list_qa_attempts({story_id = 1004})` rather than re-deriving already-settled scenarios from scratch.

## Setup Notes

- The shared dev box's harness and fleet restart under other sessions without warning — `/dev/agents` showing far fewer agents than an earlier check, or all-`starting` status, is environmental churn, not a story defect. Re-check rather than conclude.
- `math_test_project`'s deploy key and harness id are in `/Users/johndavenport/Documents/github/math_test_project/.cms_harness.json` — re-derive rather than hardcode, it can be re-onboarded.
- After the issues-chain trigger (item 1 above), the fixture project's `issues_triaged`/`issues_resolved` state is *consumed* — a re-run of this exact repro needs a fresh `create_issue` first, since accepting an already-accepted issue does nothing.
