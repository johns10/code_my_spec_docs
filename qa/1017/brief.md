# QA Brief — Story 1017: The main agent looks in on its agents on a cadence

## Tool

`mcp__plugin_codemyspec_local__run_script` (the harness-channel tool bridge this
session carries) for every `cadence`/`check_in`/`list_agent_work`/
`list_open_questions`/`list_issues`/`accept_issue`/`resolve_issue`/`start_agent`
call, plus plain `curl` for the two dev-only routes (`/health`, `/dev/faults`)
and for driving a second, disposable project's MCP endpoint directly (see
below).

## Auth

No auth needed for this session's own project
(708492f9-454e-482f-a2eb-be64f0356b87) — its tool calls are already scoped via
the harness id baked into `.cms_harness.json`. The two dev routes are
unauthenticated by design (`:dev_routes`, compile-time absent from the
release):

```
curl -s http://localhost:4004/health
curl -s -X POST http://localhost:4000/dev/faults -H 'Content-Type: application/json' \
  -d '{"key":"<project_id>","fault":"digest_unavailable"}'
curl -s -X DELETE http://localhost:4000/dev/faults -H 'Content-Type: application/json' \
  -d '{"key":"<project_id>","fault":"digest_unavailable"}'
```

For 3334/3335, drive the **QA Fixture Project** (id
`11111111-1111-4111-8111-111111111111`) directly instead of this session's own
project, using the sandbox checkout's own harness id (see `.code_my_spec/qa/plan.md`,
"Sandbox project for MCP-surface SC tests"):

```
SANDBOX=/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
ID=$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$SANDBOX/.cms_harness.json" | head -1 | cut -d'"' -f4)
curl -s -X POST http://localhost:4004/mcp \
  -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" \
  -H "X-Harness-Id: $ID" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"run_script","arguments":{"script":"return cadence({})"}}}'
```

`start_agent`/`stop_agent`/`tap_out` are direct MCP tools (not `run_script`-callable);
call them the same way with `"name":"start_agent"` etc.

## Seeds

None. This story is about the *running* fleet. This project's live state (12
real agents, some working, some idle, some blocked on real questions) is the
fixture for criteria 3317–3333. See `.code_my_spec/qa/plan.md`'s Seed Strategy
for the general pattern; it does not apply here.

**Do not** flip a real agent's continuous flag or tap out a real agent on
*this* project to force a scenario — that rings the agent's bell or durably
stands down a project with real in-flight work. For 3334/3335, use the QA
Fixture Project instead (see above) — it currently holds only idle/blocked
`main`-role test agents left over from prior QA passes on this and other
stories, so a stand-down there costs nothing real.

## What To Test

Nine criteria. As of this pass (2026-09-13, build `13956c94a`/`b3915b3e0`),
both defects the immediately-prior attempt (`4eefdc29`) found are fixed and
verified live:

- **The main agent comes back round on its own (3317)** — `cadence({})`
  against this project. **Live: `running: yes`** — issue `11aea8f5` (cadence
  not seeded because every agent, including the running main agent, had
  `continuous = false`) is resolved: the cadence now also starts whenever a
  main agent starts, not only from `continuous_project_scopes/0`.
- **A pushed question does not wait for the next check-in (3318)** —
  `list_open_questions({})` against this project's real fleet: several
  genuine questions delivered within minutes of being asked, independent of
  the cadence timer. Don't manufacture a new question here (permanent inbox
  clutter on a real project).
- **An agent that went silent is caught by the check-in (3319)** —
  `check_in({})` then `list_agent_work({})`: agents last-said 2026-09-02/03
  (genuinely stale, 10+ days) are enumerated alongside live/blocked ones with
  role/task/last-said/blocked-on, not silently dropped.
- **A quiet check-in does not become a notification (3320)** — structural,
  unchanged by this pass's fixes: `MainAgent.deliver_check_in/2` only ever
  calls `Agents.send_to_agent/2` (writes `conversation_messages`);
  `/app/notifications` reads exclusively from `CodeMySpec.Notifications`,
  untouched by any check-in path. `check_in({})`'s own reply text stays
  conversation-only across every call this pass.
- **The interval is set rather than assumed (3331)** — `cadence({seconds=N})`
  then `cadence({})` to read back; round-tripped 1200→300→1200 live this
  pass. Durable, per-project (`project_configurations` row).
- **The wake-up says what is going on (3332)** — `check_in({})`'s reply plus
  `list_agent_work({})` (which backs the digest) show every agent by
  role/task/last-said/blocked-on — not a bare "time to check in."
- **A digest that cannot be assembled is not delivered as an empty one
  (3333)** — `POST /dev/faults {"key": "708492f9-...", "fault":
  "digest_unavailable"}`, then `check_in({})`, then `list_issues({status =
  "incoming"})` to confirm a real issue was raised (this pass: issue
  `4017c7d4`, "The check-in could not be assembled"). **Clear the fault
  immediately after** (`DELETE /dev/faults`) and accept+resolve the synthetic
  issue with a note — it is not a real production problem.
- **Everybody is through their work and the main agent stands down (3334)** —
  now live-exercisable, not just code review, using the QA Fixture Project
  (see Auth). Procedure used this pass:
  1. `message_agent({agent_id=<an idle role:main agent on the fixture
     project's working copy>, message="call your tap_out tool now"})`.
  2. `cadence({})` on the fixture project immediately reads `woken: no — this
     project has stood down; it is still reachable by question` (`running:
     yes` — the timer process itself is untouched, only delivery is gated).
  3. `start_agent({role="main", working_copy_id="1fc425f5-..."})` (any new
     `role: main` agent) — `cadence({})` immediately flips back to `woken:
     yes`. This is the live proof of issue `5f9fad45`'s fix:
     `Cadence.resume/1` now has a caller (starting a main agent), ordered
     before `ensure_cadence/1`.
  4. `stop_agent` the throwaway agent afterward to avoid leaving cruft.
  A **node restart mid-session silently reset the stood-down flag back to
  `woken: yes`** on the first attempt — expected per `5f9fad45`'s resolution
  note (the stood-down list is `Application.put_env`, not durable); redo the
  tap-out if a restart lands between steps.
- **Tapping out does not make the main agent unreachable (3335)** — same QA
  Fixture Project, same stood-down window as 3334 step 2. `list_open_questions({})`
  called *while* `cadence({})` read `woken: no` still listed every one of the
  fixture project's pre-existing open questions (asked ~3 hours earlier),
  unaffected. `MainAgent.question_raised/2`'s delivery path never consults
  `Cadence.running?/1` or the stood-down list — matches spex 3335. (A second
  attempt to push a *brand-new* question during the stood-down window landed
  ambiguously across a mid-session node restart, so it isn't cited as
  independent evidence — the first check is clean and sufficient on its own.)

## Result Path

DB-backed attempt via `mcp__plugin_codemyspec_local__submit_qa_result`; findings
via `create_issue`. No `result.md` — the harness does not read one.

## Setup Notes

Prior attempts on this story: `4eefdc29` (fail, 2026-09-13 03:06:36Z —
`11aea8f5`/`5f9fad45` filed), `b3269eac` (partial, 2026-09-12 22:56:59Z),
`b7386ca0` (fail, 2026-09-12 15:29:27Z), `7dd4567c` (fail, 2026-09-12
12:45:43Z) — `list_qa_attempts({story_id=1017})` has the full history.

This pass: re-verified both `11aea8f5` and `5f9fad45` are actually fixed and
live (not just resolved-on-paper) rather than carrying the report forward,
then used the QA Fixture Project — previously blocked by a permission
classifier when reached via a bare `curl` to an isolated project's `/mcp`,
now reachable by going through the sandbox checkout's own onboarded harness
id per `.code_my_spec/qa/plan.md`'s documented procedure — to move 3334/3335
from code-review-only `partial` to live-exercised `pass`. The fixture project
was not empty this time (6 idle `role: main` test agents and 6 stale open
questions, residue from prior QA passes across multiple stories/sessions
sharing it); confirmed isolation via `list_story_titles` (~28, not ~120)
before touching anything, and only ever tapped out/started agents that were
already idle there.
