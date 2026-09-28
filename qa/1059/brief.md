# Qa Story Brief

Story 1017 — "The main agent looks in on its agents on a cadence"
(`CodeMySpec.MainAgent` cadence/recovery: `Cadence`, `Work`, `Digest`, tap-out).

## Tool

script + curl

`qa_as_agent.sh` (code-mode `run_script` for scriptable tools; direct call for
`tap_out`, `ask_user_question`, `start_task`) against the math_test_project
harness, plus `curl` against the `/dev/faults` seam and `/dev/mailbox`, plus
the `vibium` CLI (headless) for the one browser-authorized step. The Vibium
MCP server itself is down this session; the `vibium` CLI substitutes per the
team's note.

## Auth

No product login needed for the agent-surface tools — `qa_as_agent.sh` drives
the harness proxy directly with `X-Harness-Id` + `X-Agent-Id`.

```
QA_WORKTREE="/Users/johndavenport/Documents/github/math_test_project" \
  .code_my_spec/qa/scripts/qa_as_agent.sh <agent-id> <tool> '<json-args>'
```

`QA_WORKTREE` **must** point at `math_test_project`'s own checkout (it has
its own `.cms_harness.json`) — pointing it at this worktree sends the *real*
CodeMySpec project's harness id instead and silently returns the wrong
project's data. Confirmed this the hard way on the first two calls
(`get_next_requirement`, `list_notifications` both came back with the real
project's rows) before fixing `QA_WORKTREE`.

For the one LiveView step (approving a permission), signed in as
`qa@codemyspec.local` via the magic-link flow (no password is set for this
user, so `/dev/sign-in` doesn't apply):

1. `vibium go` to `http://127.0.0.1:4000/users/log-in`, set
   `#login_form_magic_email` and click "Email me a login link" (via `vibium
   eval`, not `vibium fill`/`click` — both timed out finding an element that
   `eval` could see fine; JS-level `dispatchEvent`/`.click()` worked every
   time).
2. `curl http://127.0.0.1:4000/dev/mailbox/<message-id>/html`, extract the
   `/users/log-in/<token>` link, rewrite the host to `127.0.0.1:4000`.
3. `vibium go` to that URL.
4. `/app/accounts/picker` → click the `Code My Spec` account link
   (`a[phx-value-account-id]`, not the enclosing `<li>`).
5. `/app/projects/picker` → click `Math Test Project`
   (`a[phx-value-project-id="d7f466a1-591e-4f36-8319-42633f59411e"]`).

## Seeds

```
mix cms.seed priv/repo/qa_wake_seed.exs
```

Targets math_test_project (project `d7f466a1-591e-4f36-8319-42633f59411e`,
working copy `56f5bf62-9cf8-400d-abcd-6c796afd3437`). Sets four agents to
`status=running, continuous=true`:

| role | agent id |
|---|---|
| main | `4e98e2a8-f674-4a10-9592-a1468e4b64ac` |
| coding | `25d67c11-f590-4e8e-a00d-6d3fb6bf08eb` |
| coding | `59596b8a-1a5d-44b8-8f38-9bf1b570442d` |
| product | `e9dce99a-9512-457d-b613-3baa49c387a7` |

**These rows are reaped back to `status=stopped` on the next harness report
— observed at ~6 minute spacing via `settle_against/3` log lines in
`~/.codemyspec/web.log` this pass, not "within seconds" as prior notes
warned; either way, re-seed immediately before anything that depends on
`status=running`.** Reads that don't depend on runnable state (`check_in`,
`cadence`, `list_notifications`, `list_tasks`, `tap_out`, `start_task`)
are unaffected by the reap and can be run any time.

`GET /dev/faults` / `POST /dev/faults` / `DELETE /dev/faults` (dev-only,
scoped by `key` = project id or agent id) is the sanctioned seam for
criterion 3333 (`digest_unavailable`) and the adjacent silent-agent fault
(`agent_stays_silent`). Always clear an injected fault after use — it does
not expire on its own.

## What To Test

- **3320 / half of 3317 (quiet check leaves everyone alone):** with all
  fleet agents idle (no eligible graph work, no open question held by
  main), call `check_in` as main. Confirm: `list_tasks` for every agent
  stays "No tasks.", `list_notifications` count is unchanged, and no
  agent row's `work_request_id`/`turn_started_at` changes. Repeat — it
  must be a no-op every time, not just the first.
- **3317 (positive: admits a turn only for genuinely runnable+eligible
  work):** find a role with real eligible graph work via
  `get_next_requirement` (this pass: `product` had `personas_complete`
  available). Re-seed so that agent is `running`+`continuous`, then call
  `check_in` immediately and watch for a reservation
  (`work_request_id`) or a change in response latency versus the
  all-idle baseline.
- **3318 (question work reconsidered without waiting for the timer):**
  `ask_user_question` as a coding-role agent, then immediately (no
  delay, no cadence tick) call `list_notifications` as main — it must
  already show under "Needs your attention," not "waiting on the next
  check."
- **3319 (silent agent observed, no automatic intervention):**
  `list_agent_work` as main over a fleet with idle/stopped agents;
  confirm it only reports state (no restart fires from a read). Every
  `check_in` response also asserts this in its own text ("no process
  was started or restarted").
- **3331 (interval configures checks, not turns):** `cadence({seconds =
  N})` as main; confirm the report changes and nothing else does
  (`list_tasks` stays empty, notification count unchanged).
- **3332 (recovery exposes evidence without selecting a task):**
  `check_in`'s own response text plus `list_tasks` staying "No tasks."
  immediately after.
- **3333 (failed digest stays an observable failure):** `POST
  /dev/faults {"key": "<project-id>", "fault": "digest_unavailable"}`,
  call `check_in`, confirm an issue titled "The check-in could not be
  assembled" (severity high, scope framework) is created — not a silent
  empty digest. `DELETE /dev/faults` afterward.
- **3334 (task tap-out is local):** `start_task` for a real requirement
  to get a task id, `tap_out({task_id = "..."})` on that agent. Confirm
  the task is now `[blocked]` on that tap-out, while `cadence({})` and
  the agent's `continuous` flag are unchanged before/after.
- **3335 (whole-agent tap-out preserves reachability):** `tap_out({task_id
  = nil})` on an agent with no active task — confirm the response text
  ("asks to turn off continuous work upon approval") and that a pending
  permission of `tool_name: "tap_out"`, `task_id: nil` now exists.
  Approving it and observing `continuous` flip to `false` while the
  agent stays reachable needs a session belonging to the permission's
  `user_id` — see Setup Notes.

## Result Path

`.code_my_spec/qa/1017/result.md` (evidence only; findings and the pass/fail
record go through `create_issue` + `submit_qa_result`, not this file).

## Setup Notes

**A structural QA-tooling gap, not a story defect:** a `tap_out` permission
request raised through the local harness is owned by `scope.user.id`, which
resolves to the real project's account owner (`user_id: 1`), not to
`qa@codemyspec.local` or any other QA-mintable identity. `PermissionLive.Show`
refuses anyone else with "Permission request not found or not authorized." —
confirmed live after correctly switching the QA session to the `Code My Spec`
account and the `Math Test Project` project. This is the same class of gap the
plan already documents for locally-asked *questions* (issues `19b0d2d4` /
`7ba12775`), extended here to *permissions*. No sanctioned dev seam exists to
approve as the real owner or to mint a session as user id 1. The spex for
3335 covers the approve-and-observe half directly (it drives
`PermissionLive.Show` through a test-privileged `conn`), so that half is
spex-covered rather than QA-blocked; filed as its own issue since a plain
grep for the existing question-ownership issues would not surface it.

**An unexplained extra `main`-role agent** (`27417912-73f9-4572-a572-52b0faf7ba64`,
`continuous: false`) appeared on math_test_project partway through this pass,
alongside the seeded fixture main agent. Did not interfere with any
observation (it carried no eligible work and nothing acted on it), and its
`continuous: false` means it could not have absorbed any of the turn-admission
evidence above. Left unresolved — plausibly from unrelated project-onboarding
machinery reacting to the QA session's account/project switch — worth a
one-line mention to whoever next touches this fixture.
