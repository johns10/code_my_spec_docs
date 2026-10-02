# Qa Story Brief — Story 896: Agent sees the questions it has open

## Tool

MCP (via `qa_as_agent.sh` and direct curl to the sandbox harness) + `web` (Vibium, `/app/questions/:id` and `/app/projects/:id/agent-conversation`)

## Auth

- **Browser (hosted app, port 4000):** Log in as `qa@codemyspec.local` via the magic-link flow (no password is set for this seed user):
  1. `vibium go http://127.0.0.1:4000/users/log-in`, fill `input[name="user[email]"]` with `qa@codemyspec.local`, submit the magic-link form (`#login_form_magic`).
  2. Fetch the link from the local mailbox: `curl -s "http://127.0.0.1:4000/dev/mailbox/<message-id>/html" | grep -o 'href="[^"]*log-in[^"]*"'` (or drive `/dev/mailbox` in the browser). `/dev/mailbox` is listed at the top of the page after navigating there.
  3. Rewrite the host to `http://127.0.0.1:4000` before navigating to the `/users/log-in/:token` link (it is minted against `dev.codemyspec.com`).
  4. Switch active account/project so you land on the sandbox, not "Code My Spec": `GET /app/accounts/picker` → click "QA Account", then confirm the active project is "QA Fixture Project" (it auto-selects since the account has only that one project).
  - **Use an isolated Vibium session** (`vibium --session qa-896 <cmd>`, or the equivalent `VIBIUM_SESSION` env var). The default session's cookie jar is shared with every other concurrently-running QA agent on this box (qa-1004/1005/1009 were live during this pass) and was already logged in as `qa@codemyspec.local` with a different active account — switching it would have corrupted their in-flight state. `--session <name>` gets its own browser context / cookie jar and login, confirmed via `window.location.href` redirecting to `/users/log-in` on first navigation.
  - **Vibium's native `fill`/`click`/`type` commands timed out (`element not found` / `waiting for element`) against every element tried this session**, including plainly visible, enabled, unobstructed inputs and buttons (confirmed via `elementFromPoint`, `getBoundingClientRect`, machine load 2.07 — not saturation). Worked around with `vibium eval`, setting the native value setter + dispatching `input`/`change` events for fields, and `element.click()` for buttons/radios. This is a QA-tooling finding (see Issues below), not a story defect — every interaction produced the correct LiveView side effect once dispatched this way.
- **MCP as an agent:** `.code_my_spec/qa/scripts/qa_as_agent.sh <agent-id> <tool> '<json>'` with `QA_WORKTREE=/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` exported first (so the script reads the *sandbox's* `.cms_harness.json`, harness id `1fc425f5-7b88-4e32-86a3-c16c3317408c`, project `11111111-1111-4111-8111-111111111111` — **not** this worktree's own `.cms_harness.json`, which names the real "Code My Spec" project 708492f9 and must never be used for `ask_user_question`). Tools not in the direct list (`list_tasks`, etc.) go through `run_script({script = "return tool({...})"})`.
- **MCP as a legacy/external session (no agent_id):** raw curl to `http://localhost:4004/mcp` with `X-Harness-Id: 1fc425f5-7b88-4e32-86a3-c16c3317408c` and no `X-Agent-Id`, following the `initialize` → `notifications/initialized` → `tools/call` handshake in `.code_my_spec/qa/plan.md`'s curl section.
- **Never** call `ask_user_question` from this worktree's own bound MCP tools, or with `QA_WORKTREE` unset — both resolve to the real dev harness and write into the real project owner's inbox (issue `08d4d7bd`).

## Seeds

No new seeds required. Uses existing fixtures:
- QA Fixture Project `11111111-1111-4111-8111-111111111111` (account `22222222-...` "QA Account", owned by `qa@codemyspec.local`) — already onboarded at `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`.
- Pre-existing stopped, non-continuous fixture agents on that project, picked because each one had never asked a question before this pass (to keep `list_user_questions` evidence clean): `6c016d95-7e13-49e4-b86f-34d2109adb1a` (coding, agent A), `bce7b8f6-1979-4e07-88a2-b50c79be5432` (coding, agent B — already had a `Conversation` row `82c9cea7-5edc-4f5d-9a0f-943c11bb8ba7`, used for the agent-conversation host), `79de3a9e-37bc-4061-bfe7-8cbb803fcff7` (coding, agent C, free-text case), `1a219c61-9265-4f2f-9163-873757e72cb4` (product — used only to reproduce the `start_task` crash below), `5d65b4d0-95d9-4e5b-915b-cc012f4d91ff` (coding, has a non-nil `working_copy_id` — used to file the issue).

**Blocking discovery — do this check first on a re-run:** every "product"-role fixture agent on the QA Fixture Project has `working_copy_id = nil`, and the only actionable requirement in the project (`personas_complete`, project-scoped) requires the "product" role. Calling `start_task` for it **crashes** (`CodeMySpec.TaskOwner.check_requirement_claim/2`, Ecto `ArgumentError` comparing `nil` unsafely — see issue `29a86945`). This blocks every task-claim-and-block scenario below from being exercised live until either that bug is fixed or a product-role fixture with a real `working_copy_id` is seeded. Confirm with:
```
psql -qtA code_my_spec_dev -c "select id, role, working_copy_id from agents where project_id='11111111-1111-4111-8111-111111111111';"
```
Any product-role row with `working_copy_id` empty will still crash `start_task` on `personas_complete`.

## What To Test

Live/browser-checked this pass:

- **3574 — Invalid task links leave no orphan question.** `ask_user_question` with `task_id` set to a well-formed but non-existent UUID, from an agent with no active task. Expect a tool refusal (`Could not reach the user: :task_not_found`) and `list_user_questions` unchanged before/after (no orphan row). Uses agent `6c016d95`.
- **2418 — Question visibility respects agent ownership.** Two agents (`6c016d95`, `bce7b8f6`) each ask one task-free question. `list_user_questions` as agent A shows only A's question, as agent B shows only B's, and as an uninvolved third agent (`79de3a9e`) shows none. (This pass exercises the agent-vs-agent half only; the session-vs-agent half is covered by the spex, criterion 2418's fixture needs two durable agents *and* two external sessions sharing one checkout, which the live surface has no seam for.)
- **2422 — Both question hosts support choices and one free-text question.**
  - Choice question (`817f7f6e-a979-42c9-87f1-72292eed7d74`, no existing conversation) renders on the standalone host `/app/questions/:id`.
  - Choice question (`5a294138-fbf1-4d19-bb69-04e20001e133`, agent `bce7b8f6` has a pre-existing conversation) renders inline on `/app/projects/:id/agent-conversation?conversation=...#question-...` — same `data-test="question-form"` markup, same fieldset/options/Send-answer structure.
  - Free-text question (`e288717f-b0fd-43bd-ab03-0407198196fe`) renders a bare `<textarea>` (no options) on the standalone host, submitted and collected correctly via `check_answer`.
- **The two fixes just shipped in v2.0.75 (called out explicitly by the story owner as worth exercising):**
  - Submitting a question form with nothing selected and nothing typed is refused (`{:error, :empty_answer}` → the LiveView's generic error branch shows "Failed: :empty_answer") and the question stays pending — verified on `817f7f6e`, then a real answer ("Blue") was submitted immediately after and succeeded normally, proving the refusal doesn't wedge the form.
  - Typing into the "Other…" text box without clicking its radio is read as the answer, not as blank — verified on `5a294138` (agent-conversation host): typed `"Triangle (typed correction)"` with all radios (including "Other"'s own) left unchecked, submitted, and `check_answer` / the DB row both show the typed text, not `""`.
- **3576 — Legacy external questions support polling without a task.** Raw curl to the sandbox harness with `X-Harness-Id` and no `X-Agent-Id` (a Claude-Code-shaped session): `ask_user_question` succeeds with no task, no agent listing; answered via the `/app/questions/:id` browser form; a **second, independent** MCP session (fresh handshake, same no-agent shape) calls `check_answer` and gets the answer back — confirming polling needs no task and no session continuity.

Spex-only this pass (reasoning, not held open):

- **2414 / 2415 / 2419 / 2421 — any scenario needing a real claimed-and-blocked task.** Blocked by the `start_task` crash above: no fixture agent combines (a) a role with actionable work and (b) a non-nil `working_copy_id`, so no task can be claimed live without hitting the crash. The spex drive this through the fixture bridge instead and are unaffected. Once issue `29a86945` is fixed, or a product-role fixture with a real working copy exists, this becomes reachable — re-check `get_next_requirement` role/`working_copy_id` combinations first.
- **2417 — Open questions survive an internal agent restart.** Requires restarting a real, durable engine process under the same identity — deliberately not attempted from QA (would spend real tokens/spawn a live Claude run against fixture data, per the agent-sandbox notes in `.code_my_spec/qa/plan.md`).
- **3575 — A failed question write does not block the task.** Requires injecting a DB insert failure for a specific user, which is a test-only seam (no live fault-injection surface exists).
- **3577 / 3578 — Answer queuing / dedup while the agent is busy.** Both require a held/paused provider supplying a real in-flight turn — no such double exists outside the spex harness.
- **3579 — Resuming an answered task is an explicit revalidated claim.** Depends on the same task-claim path blocked above (valid resume / withdrawn requirement / another agent's claim all need a real active task to resume).

## Result Path

DB-backed attempt via `submit_qa_result` (task id `16c7e602-39da-4007-9d2f-75ea1291c625`). Screenshots: `.code_my_spec/qa/896/screenshots/`.

## Setup Notes

- The QA Fixture Project's account (`22222222-...`, "QA Account") is owned by `qa@codemyspec.local`, distinct from the real "Code My Spec" account (`0f27281c-...`, owned by `johns10@gmail.com`) that both this worktree's own harness and the standing "parked" fixture agent (`5e603bd6-...`, documented in `.code_my_spec/qa/plan.md`) belong to. **Do not use that standing fixture, or any `math_test_project` agent, for `ask_user_question`** — both resolve to the real account and would write into the real owner's inbox exactly like issue `08d4d7bd`. Only agents on project `11111111-...` are safe for this story.
- One issue filed against the QA-tooling itself: Vibium's native interaction commands (`fill`, `click`, `type`) timed out against every element this session while `eval`-based DOM manipulation + native `.click()` worked every time and produced correct LiveView round-trips. Not story 896's bug; flagged so the next QA pass doesn't lose time on the same thing.
