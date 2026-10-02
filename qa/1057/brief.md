# Qa Story Brief

Story 1015 — The main agent sees the health of the machinery its agents
depend on. Component: `CodeMySpec.MainAgent` (context, no LiveView).

Re-run. The tool-fault trio (3310/3311/3312) is now reachable via a dev-only
route that writes what a harness join writes, and this brief supersedes the
prior one's "verify by code reading" stance for those three.

## Tool

`curl` driving the real MCP surface directly (JSON-RPC over `/mcp/harness` on
the hosted app, or `/mcp` on the local app) — no native `mcp__*` wrapper on
this session reaches `check_machinery`/`restart_agent`/`list_issues`, so they
are called the same way `qa_code_mode.sh`/`qa_spine.sh` already do: initialize
→ `notifications/initialized` → `tools/call` with `name: "run_script"` and a
Lua body that calls the bound tool directly (e.g. `return check_machinery({})`).

`check_machinery`, `restart_agent`, `list_issues`, `get_issue`, `dismiss_issue`
are all reachable this way (`CodeMySpec.McpServers.ScriptableTools`'s
component list includes the `MainAgent` and `Issues` tool modules).

Plus one dev-only HTTP route, per the task background:

    POST /dev/copies/<working_copy_id>/machine_tools   {"tools": [...]}

which writes `working_copies.machine_tools` the same way a harness join does
— this is what makes 3310/3311/3312 stageable without touching a real
machine's MCP client.

## Auth

- **Hosted `/mcp/harness` (port 4000):** `Authorization: Bearer <token>` +
  either `X-Harness-Id: <working_copy_id>` (preferred — sets project AND
  working copy) or `X-Project-ID: <project_id>` (project only; see the
  nil-working-copy crash finding below). Get a token by exchanging this
  checkout's own deploy key:

  ```
  DK=$(grep -E '^CMS_DEPLOY_KEY=' envs/.env | cut -d= -f2- | tr -d '"')
  curl -sS -X POST http://localhost:4000/api/sprite/token \
    -H "authorization: Bearer $DK" -H 'content-type: application/json'
  ```

  The resulting token belongs to `johns10@gmail.com`, who is a member (not
  just via the returned project) of the `QA Account` that owns the QA Fixture
  Project — `X-Project-ID: 11111111-1111-4111-8111-111111111111` works with
  it, and `ProjectScopeOverride` only requires *some* membership in the
  target project's account, not ownership of the deploy key's own project.

- **Local `/mcp` (port 4004):** no bearer token — `X-Harness-Id: <harness_id>`
  is enough (`Plugs.LocalOnly` + `Plugs.HarnessScope`). Use this worktree's
  own `.cms_harness.json` `harness_id` for a live, connected, real-project
  reading (used for the healthy-baseline evidence, 3309/3322-3325).

- `/dev/copies/:id/machine_tools` and `/dev/faults` need no auth at all —
  they are compiled in only under `dev_routes: true` (see
  `config/dev.exs`), which is on for the box this QA runs against.

## Seeds

None from `qa_seeds.exs`. This story's evidence comes from:

1. **Real, live fleet state** for the healthy-baseline and cross-project
   criteria (3309, 3322–3325) — read-only, no seeding.
2. **The QA Fixture Project's existing throwaway working copy**
   (`d1540d93-f639-448a-9dac-5317665e513f`, root under this session's own
   scratchpad) for the mixed-fault case (3311) — already toolless with one
   running agent from prior QA activity; confirmed via
   `select machine_tools, agent status from working_copies/agents` rather
   than re-staged, since it already demonstrates the exact shape needed
   without touching the project's real shared copy
   (`1fc425f5-...`, 5 real running agents — DO NOT blank its tools).
3. **Simpler, preferred re-run method (2026-09-13):** the QA Fixture
   Project's own real shared copy (`1fc425f5-...`, 5 real running agents) IS
   the machine-wide fixture — briefly. `POST
   /dev/copies/1fc425f5-.../machine_tools {"tools":[]}` makes every copy
   with a running agent on that project toolless at once (the pre-existing
   toolless `d1540d93` copy plus the shared copy = the whole fleet), which is
   exactly `:machine`. `check_machinery` immediately reads `tools: FAULTY on
   the machinery`. Restore the shared copy's tools (its 85-tool list, saved
   before mutating) within the same script run — round trip took well under
   a minute in practice — and the 5 real agents are never actually touched
   (this only rewrites `working_copies.machine_tools`, a presentation field;
   it does not stop or otherwise affect a running process). This avoids
   inserting throwaway `projects`/`working_copies`/`agents` rows entirely.
   The throwaway-project method below still works and is kept as a fallback
   if the shared copy is ever unsafe to touch (e.g. its tools list can't be
   captured cleanly beforehand).

3a. **Fallback: a brand-new, fully disposable project** for the machine-wide
   case (3310/3312), because `tool_fault/1` compares a project's copies
   against *each other* — the QA Fixture Project can't show `:machine`
   without also blanking its real shared copy. Created directly (this
   project is nothing but a fault fixture, deleted at the end of the run):

   ```sql
   insert into projects (id, account_id, name, inserted_at, updated_at)
     values ('99999999-9999-4999-8999-999999999999',
             '22222222-2222-4222-8222-222222222222', -- QA Account
             'QA 1015 Machine Fault Fixture (throwaway)', now(), now());
   insert into working_copies (id, project_id, root, device_id, machine_tools, main, inserted_at, updated_at)
     values ('88888888-8888-4888-8888-888888888888',
             '99999999-9999-4999-8999-999999999999',
             '/tmp/qa1015-machine-fault',
             'b0aa9968-ae9f-493a-9b09-451d477a9844', -- the real shared dev-mini device
             '{}', true, now(), now());
   insert into agents (id, engine, provider, working_copy, status, working_copy_id,
                        project_id, account_id, role, continuous, tasks, inserted_at, updated_at)
     values ('77777777-7777-4777-8777-777777777777', 'alloy', 'claude-code',
             '/tmp/qa1015-machine-fault', 'running',
             '88888888-8888-4888-8888-888888888888',
             '99999999-9999-4999-8999-999999999999',
             '22222222-2222-4222-8222-222222222222', 'coding', false, '{}', now(), now());
   ```

   Then the real app route: `POST /dev/copies/88888888.../machine_tools
   {"tools":[]}` (the SQL insert already set it, but hit the route too —
   it's the mechanism the criteria actually depend on).

   **Teardown (do this — it is not optional):** dismiss any issues this
   staging files (`dismiss_issue`), then
   `delete from agents/working_copies/projects where id = ...` for all three
   rows above.

## What To Test

- `check_machinery({})` scoped to a real, connected, healthy project (this
  worktree's own harness) → the report names harness/tools/preview/analyzers/
  machine, and healthy pieces read as positive statements ("tools: working —
  every agent's machine is answering with a usable tool list.", "credo —
  working, and its result is about the code that is here now"), not silence.
  → **3309**.
- `check_machinery({})` scoped to the QA Fixture Project (harness id =
  `1fc425f5-...`, the real shared copy) → the `tools:` line must read "the
  machinery is working" and name only the toolless copy's agent
  (`22227f46-...`) as the one at fault — the 5 real agents on the shared copy
  must NOT appear in that line. → **3311**.
- `check_machinery({})` scoped to the throwaway machine-fault project (harness
  id = `88888888-...`, its only copy, toolless) → the `tools:` line must read
  "FAULTY on the machinery ... one fault underneath them and not N separate
  agent faults", not attributed to the individual agent id. → **3310**.
- `list_issues({})` on that same throwaway project → a "The machinery is
  serving no tools" issue must already exist, unprompted — found and raised
  by `check_machinery` itself. → **3312** (raise half).
- `restart_agent({agent_id = <the throwaway agent>, reason = "..."})` on that
  same project → must be refused (`isError`) on the first attempt with a
  message naming the machinery fault (not a restart-count message). →
  **3312** (refuse half).
- Same `check_machinery` reads above, read the `analyzers:` section → each of
  `compiler`/`credo`/`exunit`/`spex` named individually alongside everything
  else (**3322**), and any `STALE`/`FAILED` state described in words that
  explicitly disclaim being a passing verdict (**3323**).
- Same reads, read the `machine:` section → hostname, load (or "has not
  reported what it is carrying"), a `shared: N other project(s)` count, and
  `agents on it:` limited to this project's own agent ids. Cross-check no
  foreign agent id leaks in. → **3325**. If load is present and over
  threshold (cpu_count×2 for load average, or <512MB free), the line must say
  `SATURATED` and explain what that means for the agents on it. → **3324**.
- `restart_agent({agent_id = <a working copy id belonging to a DIFFERENT
  project>, reason = "..."})` → refused (`isError`), and the issue it raises
  must explain *why* (shared harness, other tenants' in-flight work) well
  enough for a person to weigh the tradeoff — not just "not yours". →
  **3326**.
- Negative/edge check worth doing while you're in there: call
  `check_machinery` via the hosted endpoint with `X-Project-ID` only (no
  `X-Harness-Id`, so `active_working_copy_id` stays `nil`) and see whether it
  degrades gracefully or crashes.

## Result Path

`.code_my_spec/qa/1015/result.md`

## Setup Notes

Findings and their evidence transcripts are saved under
`.code_my_spec/qa/1015/responses/*.txt` (this is a headless MCP/API story —
there is nothing to screenshot). Every issue found was filed via
`create_issue` as it was found; every QA-artifact issue this staging itself
produced was dismissed and its throwaway rows deleted before the session
ended — see `result.md` for the full list and ids.

Criterion 3321 ("what the main agent can fix, it fixes") update (2026-09-13):
the "unverifiable" conclusion above is superseded. `create_working_copy` lets
QA stage a fully disposable agent of its own — the work discarded by
restarting it is nobody else's. Did exactly that (`5bdd5845-...` on a
throwaway `qa-1015-restart-probe` copy): dispatched a long shell command
(`sleep 180 && echo ...`) via `POST /dev/agents/<id>/message` (no-wait),
confirmed the turn open in `list_agent_work`, then called `restart_agent`
well before the sleep would finish on its own.

Result: the fix does not fully hold. `ps` showed the dispatched `sleep 180`
subprocess (parented by the harness's own `erl_child_setup`, not by any
per-agent OS process) still running after the restart call returned `{:ok,
...}` and after the "Restarted: ..." notice had already landed in the
conversation — it ran to natural completion untouched. `agents.turn_started_at`
never cleared (still showed the pre-restart turn's timestamp 2+ minutes
later). And on this run, `end_process/2`'s no-op for `%Agent{status:
:starting}` collided with a genuinely-alive process that the row's status
never confirmed to `:running`: the relaunch failed with
`{:shutdown, {:failed_to_start_child, Anubis.Client, {:already_started,
#PID<...>}}}` (visible in `web.log`), leaving the agent permanently stuck at
`status: starting`, `os_pid: nil`, with no further retry — while
`restart_agent` had already returned success to the caller. Filed as
`4078e7bf-8b34-484e-9b6f-a736e4fc4329`. The disposable working copy was
offboarded afterward; no real project's agents were touched.

**Re-retest (2026-09-13, commit `b2a797013`), attempt `62fc3da0`:** `e010ad5a5`
fixed the two things it targeted — verified live on a fresh disposable agent
(`37dca1b7-...` on throwaway copy `ae4dcbd9-...`) with a genuinely in-flight
Bash tool call (`sleep 150`, confirmed via `ps`): `halt_for_restart/1` really
does ask the machine to stop unconditionally (harness.log: `Engine.terminate/2
... agent 37dca1b7 stopped`, fired while the row still read `:starting`), and
`turn_started_at` really does clear inline (`list_agent_work` read `nothing —
no turn is open` right after, where it used to stay open indefinitely).

But the relaunch collided on `Anubis.Client` again — the *identical* error
signature from the original 4078e7bf report, 30ms after the confirmed stop —
and the agent was still stuck at `status: starting`, `os_pid: NULL` 12+
minutes later with no retry. Root cause is different from what `e010ad5a5`
fixed: `Anubis.Client` is deliberately unlinked from `Engine` (so a dead
browser doesn't kill the agent) and keeps a name stable across restarts;
`Engine.terminate/2` never stops it; and the existing leak-replacement logic
(`anubis.ex`'s `replace_leaked/4`) races its own target's supervisor, which
auto-respawns under the same name via `:permanent`/`:one_for_all` before the
retry lands. Filed as a new issue, `dfa1ee9e-ab2c-4a07-a59a-25f0d940acc9` (kept
separate from 4078e7bf since the root cause and fix surface are different,
even though the externally-visible symptom — permanently stuck, caller told
success — is the same). Also filed a low-severity doc-drift finding,
`d99706c6-161a-4ea8-95d2-f6f3854f6dbf` (`restart_agent/2`'s moduledoc still
says it stops via `end_process/2`; the code calls `halt_for_restart/1`).
**3321 still does not pass.** The disposable working copy was offboarded
afterward (its on-disk checkout intentionally left in place, per
`offboard_working_copy`'s own stated behavior); no real project's agents were
touched.

**Re-retest (2026-09-13, commit `dfeb7aa90`), this pass:** two things changed
since `ef16ae11` (the immediately prior attempt, which failed 3321 solely on
the in-flight-Bash-subprocess gap, believing the Anubis.Client collision
already fixed by `42235f788`). First, `42235f788` is now known (issue
`68e535fd`) to have made no difference — the actual fix is `Engine.terminate/2`
now calling `disconnect_mcp/1`, closing the MCP session the agent's `init/1`
opened, so a relaunch has nothing leaked to collide with (commit `34b7e63cd`,
"A stopped agent takes its MCP session with it"). Second, John made an explicit
product decision on the in-flight-subprocess gap: leave it, the process will
die eventually — so the open question for this pass was whether that alone
means 3321 is unmet.

Verified the Anubis.Client fix live, on a fresh disposable agent
(`85c6a492-205e-48f8-b5bd-2a6f240228d1` on throwaway copy
`a71d9cdc-5d8d-4a3d-b173-58cd5277e3a3`, `roles=coding`, offboarded after —
neither previously used). Dispatched `sleep 170 && echo
QA1015_3321_verify_done` via `POST /dev/agents/<id>/message` (no-wait),
confirmed the turn open via `list_agent_work` and the OS pair alive via `ps`
(bash pid 22864 → sleep pid 22865). Called `restart_agent` mid-turn. Result:
`harness.log` shows `Engine.terminate/2 … agent 85c6a492 stopped` at
`16:35:24.078Z` and `Engine.start/1 … agent 85c6a492 running` at
`16:35:25.762Z` — 1.68s later, **no** `{:already_started, Anubis.Client, …}`
anywhere in `web.log`/`harness.log`, and this on a machine `check_machinery`
itself reported `SATURATED: load_average 21.85, memory_free_mb 278` at the
time — a harder condition than most earlier verifications, not a lucky quiet
window. `list_agent_work` read a **new** turn open at `16:35:25.773725Z`
(matching the restart, not the stale pre-restart timestamp — `turn_started_at`
correctly reset), and `list_issues(status=incoming)` showed nothing
auto-filed. The discrimination `3321` asserts — restart a fixable single-agent
fault silently, raise nothing — held end-to-end on this repro.

The pre-restart `sleep 170` pair kept running untouched, as `4078e7bf`
(status: `accepted`) already documents. New this pass: because a restart
resumes the same conversation thread ("It comes back on the same row and the
same thread, so it keeps what it was doing" — the tool's own reply), the
resumed agent re-issued the identical Bash instruction as its first new turn,
and `ps` showed a **second**, independent `bash`/`sleep` pair start within
~1s of the restart while the first was still alive — one restart left two
live copies of the same command, not one. Filed as a refinement of `4078e7bf`,
low severity: `165a3769-198f-4885-ba80-7983bac5a7b4`. Killed both orphaned
pairs by hand after capturing evidence, to avoid adding load to the already-
saturated shared box.

**Judgment call on the criterion (John asked for QA's, not the fix author's):**
3321 is about discriminating a fixable agent-level fault (restart silently)
from an unfixable machinery fault (raise, don't restart) — the counterweight
to 3312. The orphaned/duplicated Bash subprocess doesn't break that
discrimination: the restart doesn't misfire, doesn't get stuck, doesn't file a
spurious issue, and the agent comes back functional and usable. It's a
resource cost on the side, not a broken fix — and it's a cost John reviewed
and explicitly chose to accept rather than build a custom `bash_executor` for.
Holding 3321 to "zero side effects from every restart, forever" would be QA
overriding a made product decision rather than testing the behavior the
criterion actually describes. **3321 now passes**, with the residual/
compounding subprocess leak carried forward as a known, accepted, non-blocking
issue (`4078e7bf` and its refinement `165a3769`) rather than a criterion
failure. The disposable working copy was offboarded afterward; no real
project's agents were touched.
