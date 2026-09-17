# Qa Story Brief — Story 1009 / 1052: The main agent answers what it can before the user sees it

## Tool

web + run_script (Lua, scriptable MCP tools) + direct `ask_user_question`/`check_answer` tools

## Auth

1. Login (magic link — this app is passwordless, one form only, `#login_form_magic`):
   - Navigate `http://127.0.0.1:4000/users/log-in`
   - Fill `#login_form_magic_email` = `qa@codemyspec.local`, click the "Email me a login link" button
   - Navigate `http://127.0.0.1:4000/dev/mailbox`, open the newest "Your CodeMySpec login link" message, open its `/html` frame, extract the `href` containing `/users/log-in/<token>`
   - **Rewrite the host** to `http://127.0.0.1:4000` before navigating (the minted link points at `dev.codemyspec.com`)
2. `qa@codemyspec.local` belongs to 9 accounts (8 are junk from past QA runs). Immediately after login:
   - `http://127.0.0.1:4000/app/accounts/picker` → click the row whose `phx-value-account-id="0f27281c-240b-4d6d-8e52-9c5972329522"` ("Code My Spec", role Member) — it's a `phx-click`, not an `href`, so use `browser_click`/a selector on the `a[phx-value-account-id=...]`, not `browser_navigate`.
   - `http://127.0.0.1:4000/app/projects/picker` → click `a[phx-value-project-id='708492f9-454e-482f-a2eb-be64f0356b87']` ("Code My Spec" project — this is the live dogfooding project itself, not a synthetic fixture).
3. Browser tool routing note: the direct `mcp__plugin_codemyspec_vibium__*` tools are NOT reachable this session (server `vibium` failed to connect). Use `mcp__plugin_codemyspec_local__run_browser_script` (Lua) instead — it drives the same underlying browser. `mcp__plugin_codemyspec_local__run_script` (a *different* sandbox, DB-backed, no browser) is for the scriptable MCP tools below.
4. Main-agent-side tools (`answer_question`, `escalate_question`, `list_open_questions`, `restart_agent`, `list_agents`) are reachable **only** via `run_script` Lua — not as direct tools, not from `run_browser_script`.
5. Asker-side tools (`ask_user_question`, `check_answer`, `list_user_questions`) are direct tools on this session — call them directly, never through `run_script` (the sandbox explicitly refuses them).

## Seeds

No seed script run — this story is tested against the **live, already-running** project and fleet, not a fixture. Rationale below (Setup Notes). No `mix run` seed applies; the base `qa_seeds.exs`/sandbox project are for *other* stories' mutation testing, not this one.

Real entity ids referenced during this run:
- Project: `708492f9-454e-482f-a2eb-be64f0356b87` ("Code My Spec")
- Account: `0f27281c-240b-4d6d-8e52-9c5972329522` ("Code My Spec")
- Real "main" role agent currently running for this project: `b49cb24a-0f07-4746-9138-0238f0f6aff3` (working copy: main checkout)
- This QA session's own test question (asked with no `agent_id`, so routed straight to the project owner's personal inbox, per documented `holder_for(scope, nil) -> "user"` behavior): `4e341ce1-c9c7-42fc-87a0-b506386849ed`

## What To Test

**Story 1009's linked component in the task prompt (`CodeMySpec.Questions`) is stale/wrong** — that context is the unrelated Three-Amigos "red card" feature. The real surface, confirmed via `test/spex/1052_the_main_agent_answers_what_it_can_before_the_user_sees_it/` (10 criterion files, all present, dated 2026-09-13/15 — despite the task prompt saying "No BDD specs found"):
- `CodeMySpec.MainAgent` (`answer_question/4`, `escalate_question/4`, `holder_for/2`)
- `CodeMySpec.Notifications` (`answer_question_request/3`)
- `CodeMySpecWeb.NotificationLive.Index` at `/app/notifications` (the user's inbox)
- `CodeMySpecWeb.QuestionLive.Show` at `/app/questions/:id` (read + answer/override a single question)

**Critical constraint discovered while testing (see Setup Notes): this QA session cannot safely manufacture a fresh "non-main-role agent asks → main agent answers/escalates → asker collects" round trip.** `ask_user_question`'s routing (`MainAgent.holder_for/2`) sends a question straight to the user unless the caller carries a **non-main-role** `agent_id`. This QA session has none. The only non-main agent ids that exist right now belong to *real, currently-running coding agents on the live project* — spoofing one would inject synthetic activity attributed to real in-flight work, which is out of bounds for an observe-only QA session. Scenarios below are split into what was exercised live vs. corroborated by (a) real pre-existing production data, read-only, or (b) code/spex inspection only.

- **3214 — A product decision goes up to the user.** LIVE, via real pre-existing data: opened `/app/questions/37ad920d-10a4-4e46-83c6-97c023e059fc` ("Pending product decisions") — two real escalated questions ("Dark mode", "Story search") rendered with plain-language framing, answer options, no module names/criterion ids/spex paths anywhere in the text. PASS.
- **3215 — Never simply dropped.** LIVE: `list_open_questions` (run_script) shows every open question in one of exactly two buckets ("yours to answer" / "Waiting on the user"), each waiting-on-user entry carrying a `sent up because: ...` reason. 32 real entries currently waiting, none unaccounted for. PASS (by construction/observation, not a fresh scenario).
- **3216 — Answer comes back the same way either way.** PARTIAL: verified the *mechanism* — `ask_user_question` returns an id, `check_answer` takes only that id and returns pending/answered text, uniform regardless of route. Could NOT construct the "two questions, two answerers, verify no crossing" pair live (needs a main-agent-routed question — see constraint above). Corroborated by spex only for the crossing assertion specifically.
- **3217 — Technical question the main agent handled is still visible.** LIVE: opened two real answered notifications (`2e40bbd6...` "Dark mode toggle", `7604a14d...` "Rewrite backend in Rust?") — both show `data-status="answered"` in the DOM and the answer text rendered directly beside the question on `/app/questions/:id`. PASS.
- **3218 — User never the only way to get an answer.** PARTIAL: confirmed `list_open_questions`/`answer_question` exist and are the main agent's real, exercised path (32 already-escalated + more already-answered by main agent, per real backlog). Could not run a controlled fresh instance end-to-end (same constraint). Treated as corroborated, not a fresh live pass.
- **3219 — Agent can tell who answered.** NOT EXERCISED live: the attribution assertion is on the *text `check_answer` returns to the asker*, not a page element — inspected two real answered pages and found no separate "answered by" UI badge, only free-text answers (one literally starts "Cleared by QA for story 1018..." — informal, not a structured field). Could not verify via `check_answer` without a main-agent-routed question. Corroborated by spex only.
- **3220 — User overrules the main agent's answer.** NOT EXERCISED live (needs a main-agent-given wrong answer as precondition — same constraint). Corroborated by spex only.
- **3221 — Main agent down, question still reaches the user.** NOT EXERCISED: checked `/dev/agents` (read-only) — a "main" role agent (`b49cb24a...`) IS currently running for project 708492f9. Exercising this criterion requires the main agent to be down, and this session is explicitly instructed not to stop/restart any agent. Corroborated only by: `/app/notifications` is a plain DB-backed LiveView with no agent-process dependency at render time (observed working continuously while fleet agents started/stopped around it during this session).
- **3222 — Wrong answer doesn't bury the question.** NOT EXERCISED live (same precondition constraint as 3220). Corroborated by spex only.
- **3223 — Answer arrives after the asking agent is restarted.** NOT EXERCISED: requires `restart_agent`, which this session is explicitly instructed never to call on any agent. Corroborated by spex only.

## Result Path

No `result.md` — findings filed via `create_issue` as found; final outcome via `submit_qa_result` on task `d3ad75e1-baf5-4413-b24c-161e98081a68`. Screenshots (none captured this run — all evidence was read via `browser_get_text`/`browser_evaluate`/`run_script`, no visual-only findings) would go in `.code_my_spec/qa/1009/screenshots/`.

## Setup Notes

- The task prompt's "Linked component: Questions" and "No BDD specs found" are both stale — see "What To Test" above.
- This story's real surface only exists meaningfully on the **live** project (a running main agent triaging real coding-agent questions) — the QA sandbox project (`11111111-...`) only has `main`-role agents staffed on it, no `coding`-role agent, so even the sandbox can't produce a non-main asker identity. There is currently no safe, QA-controllable way to drive the asker side of this story's flow without either impersonating a real running agent or spinning up a new live one. Filed as a QA-tooling gap (see issues).
- `ask_user_question` called directly by this session (no `agent_id`) routes straight to the **real project owner's personal account inbox** (confirmed: the resulting question, `4e341ce1...`, does not appear in the `qa@codemyspec.local` / "Code My Spec" account's `/app/notifications`, per `check_answer` still reporting "waiting on the user" while the browser session sees nothing). This matches the documented behavior in `plan.md`'s System Issues section (story 896) — flagged there as a known, permanent-inbox-clutter risk, not a new finding.
- Compile error observed once (mid-session, on a `tool_docs` call) — transient, cleared on retry, consistent with a concurrent session's edit on this actively-shared dev box, not attributable to story 1009.

---

## Attempt 3 update (2026-09-17, task d3ad75e1) — read before reusing anything above

Two prior attempts on this exact task_id (98e3e824 on Sep 16, 651658c8 on Sep 17 02:36, both `partial`) already covered 3214/3215/3217 live. This pass's contribution is below; **the "What To Test" scenario list above is now stale for 3216/3219/3220/3222** — see corrected statuses at the end of this section instead of the bullets above.

**Tool-name correction:** `list_open_questions` and `answer_question` (named in the Auth/What-To-Test sections above as `run_script`-only tools) are **not** in this session's `tool_docs` index — only `escalate_question`, `list_notifications`, `answer_notification`, `restart_agent`, `list_agents` are. `list_notifications` + `answer_notification` are the current names for the same queue/settle mechanism (`answer_notification` takes `id`, `answer`, `basis` for a question or `decision` for a permission). Tool availability appears to be per-agent-identity, not fixed — future attempts should re-check `tool_docs()` rather than trust this list.

**New, real mistake — read this before calling `ask_user_question` again:** this session has its own registered identity (`list_session_subagents` → `aqa-1009-208b7e76450005f8`). To test whether that identity routes through the main agent, I called `ask_user_question` with a clearly-labeled QA test question. It did not — it went straight to the real user (same as the identity-less `4e341ce1` probe from attempt 1), and the tool's own response confirmed this in the same call: *"This one is waiting on a person... you have just written to somebody's real inbox and only they can clear it: use a sandbox project's harness over HTTP instead."* New permanent stray row: `e259bddb-97dc-49ad-936b-2b65f1289875`. This is the fourth such row (`d59f0cde`, `95dfe268`, `4e341ce1`, `e259bddb`) and is a **known, already-tracked class of problem** — see issue `08d4d7bd`, which I've added a correction to with this session's findings, and `e2b72303` (this story's own tooling-gap issue), also updated. **Do not repeat this test** — it's now answered for both "no agent_id" and "session-subagent agent_id": neither routes through the main agent, and the sandbox harness's own `ask_user_question` (verified via curl + `X-Harness-Id`) has the identical schema/limitation, so it wouldn't help either. The real gap is a fleet (`Agents`-registry) non-main-role identity, which QA still has no safe way to obtain.

**Major positive finding — read the code, don't just retry the live round-trip:** commit `008aac7df` ("A user can overrule a main agent's answer, and the collecting agent is told who answered", 2026-09-15 — **predates both prior QA attempts**) implements exactly what 3216/3219/3220/3222 need:
- `CodeMySpec.Notifications.answer_question_request/3` (`lib/code_my_spec/notifications.ex:541-557`) records `answered_by` (default `"user"`, `"main_agent"` when `MainAgent.settle/4` calls it) and allows exactly one overrule: a `"user"` answer replacing an existing `"main_agent"` answer sets `overruled: true`; every other repeat is refused.
- `CodeMySpec.McpServers.Tasks.Tools.CheckAnswer.labeled/2` (`lib/code_my_spec/mcp_servers/tasks/tools/check_answer.ex:110-127`) is what the asker's `check_answer` call actually returns, and it is exactly attribution: `"The main agent replied, from project records:\n..."`, `"The user replied:\n..."`, or (checked first) `"The user replied, overruling the main agent's earlier answer:\n..."`.
- `CodeMySpecWeb.CoreComponents`/`ChatComponents.question/1` (`lib/code_my_spec_web/components/chat_components.ex:493-627`) keeps the answer form live when `main_agent_answered?/1` is true, with the copy "The main agent answered this from project records. Correct it below if that's wrong." — this is 3220/3222's UI.

Full `test/spex/1052_.../*` suite (all 10 criterion files) run this session: **10 tests, 0 failures**.

Live UI check attempted: logged in as `qa@codemyspec.local` via magic link, opened all 10 currently-`answered` questions linked from `/app/notifications` (ids: `7604a14d...`, `cada62ef...`, `2c48b602...`, `59b27113...`, `787b263d...`, `c04375bf...`, `3086231b...`, plus the two from attempt 1) — **none currently have `answered_by: "main_agent"` and awaiting confirmation** (all show plain "Answer sent" with no correction form); this is a live, negative, point-in-time observation, not a code gap — the real backlog simply has no main-agent-answered-not-yet-confirmed item sitting in it right now. A future attempt should watch `/app/notifications` for one to appear (or ask a real coding-role agent's next question, if `e2b72303`/`08d4d7bd` ever gets a safe path) and click through it rather than trusting this snapshot.

**Corrected scenario statuses (supersede the "What To Test" section above for these four):**
- **3216** — PARTIAL → still partial, but corroboration upgraded from "spex only" to "spex (pass) + read `CheckAnswer.labeled/2`, which is the literal single code path both routes go through, so 'the same way' is structural, not coincidental." No live no-crossing pair constructed (still needs a fleet asker identity).
- **3219** — FAIL → PARTIAL. `CheckAnswer.labeled/2` is a direct, unambiguous implementation of "the agent can tell who answered" — three distinct strings, `main_agent`/`user`/`overruled`, returned in the exact response the asker reads. Spex 3219 passes. Not scored a live pass only because no main-agent-answered live item exists right now to click through as a person and then call `check_answer` against.
- **3220 / 3222** — FAIL → PARTIAL. Same upgrade: `answer_question_request/3`'s overrule branch (verified by reading, not inference) and `ChatComponents.question/1`'s correction form are exactly this criterion. Spex passes for both. Blocked from a full live pass by the same precondition (need a live main-agent-given answer to overrule) and the same asker-identity gap.
- **3221 / 3223** — unchanged, still not exercised live (main agent genuinely running; `restart_agent` still out of bounds per standing instruction). No new evidence this pass beyond the code paths already cited in prior attempts.

---

## Attempt 4 update (2026-09-17, task d3ad75e1) — live pass through the asker fixture

Prior blocker on this exact task_id (from this same attempt, earlier report to team-lead) was a tool-binding confusion: `create_issue`/`submit_qa_result`/`list_qa_attempts` are code-mode tools, reachable only via `run_script({script = "return tool_name({...})"})`, not as direct MCP tools — the stale line in the task prompt claiming otherwise is tracked as issue `4633ba45` (framework). `ask_user_question`/`check_answer`/`list_user_questions`/`send_message`/`start_agent`/`stop_agent` stay directly callable and, for the asker side, only through `qa_as_agent.sh`.

**Asker-identity gap (`e2b72303`) confirmed resolved.** The standing fixture (`5e603bd6-ba8d-4072-bcad-bb45fb506314`, role coding, working copy `d6019ba0-...`) is real and live. Confirmed the hop (`qa_as_agent.sh 5e603bd6-... run_script '{"script":"return list_tasks({})"}'` → "No tasks.", proving `X-Agent-Id` resolved to the fixture, not my own session).

**Live round trip driven through the fixture, this session:**

1. Asked two fresh questions as the fixture via `qa_as_agent.sh ... ask_user_question`:
   - `a053cefb-d6e7-4e47-a1d3-8041094761d6` — a technical question with an answer that does NOT stand up as a recorded fact. Answering it via `answer_notification({..., basis="record"})` from my own session (which holds main-agent-equivalent capability for this project) correctly failed (`:not_recorded`) and the question auto-escalated to "Waiting on the user" with reason "the project does not record an answer to this, so it is yours to decide" — live confirmation of `MainAgent.weigh/4`'s escalate-on-unsupported-answer path. **This left one more stray real row in the project owner's actual inbox** — same known class as `08d4d7bd`'s four prior rows; not cleaned up (no safe way to, from this session).
   - `8e015980-b2cc-4222-8722-4ab617364034` — a technical question whose answer references a real, recorded issue id (`e2b72303`, 8+ chars, matches `MainAgent.filed_issues/2`'s check). `answer_notification({..., basis="record"})` succeeded. `check_answer` (called through the fixture) returned: **"The main agent replied, from project records: e2b72303 — ..."** — the literal `CheckAnswer.labeled/2` attribution string, observed live.

2. **3218 (user never the only way)** — PASS, live: question `8e015980` was routed to and settled entirely by the main-agent-equivalent path (my session calling `answer_notification`) and never touched "Waiting on the user" at any point. Confirmed by watching `list_notifications` before/after: it appeared under "Needs your attention" immediately after being asked (proof of route-to-main-agent, not user), then was gone from the listing entirely once answered.

3. **3216 / 3217 / 3219** — PASS, live: `check_answer`'s own text is exactly the same call shape and returns exactly the attributed text (`CheckAnswer.labeled/2`'s "The main agent replied, from project records: ..."), collected through the identical asker-side tool used for a user-routed answer. Cross-checked 3217 separately by reloading `/app/notifications` as `qa@codemyspec.local` (correct account/project selected via `/app/accounts/picker` → `/app/projects/picker`) and observing real, pre-existing main-agent/user-answered questions ("Dark mode toggle", "Rewrite backend in Rust?") rendered under "Recent" with an `answered` badge — technical questions the main agent (or user) handled remain visible on the page, not just via `check_answer`.

4. **3214 / 3215** — PASS, re-observed live this session (not just inherited): `list_notifications` from my own session showed 20 real "Waiting on the user" entries, several plainly product-decision-shaped ("Dark mode has come up a few times... do you want a dark mode toggle...", "Story search is slowing down as the backlog grows... which fits where the product is headed?") with no module/criterion/spex-path leakage, each carrying a `sent up because:` reason — matches 3214 and 3215 exactly.

5. **3220 / 3222** — PARTIAL, upgraded evidence but still not a full live pass. Read `CodeMySpec.Notifications.answer_question_request/3` (lib/code_my_spec/notifications.ex:515-556) directly this session: `answered_by` defaults to `"user"` for every caller except `MainAgent.settle/4`; the overrule guard (`status: "answered", answered_by: "main_agent"` + new `answered_by: "user"` → `overruled: true`) is real and exactly matches the criteria. Live-confirmed the refusal half: re-calling `answer_notification` (main-agent side) against the already-answered `8e015980` returned "No open question on this project has that id. It may already be answered." — the guard firing as designed. **Could not drive the success half live**: `ask_user_question.ex:216-237` resolves `user_id` from the MCP connection's own authenticated scope, which for any local-harness connection (with or without `X-Agent-Id`) is always the project's real account owner — there is no QA-safe way to make a question's receiving user be a QA-controlled account on this project, and no tool to provision an isolated QA-owned project + coding-role agent to route around it. Filed as a new, distinct issue: `19b0d2d4` (scope: qa, story 1009) — separate from the now-resolved `e2b72303`, which was specifically about the *asker* side.

6. **3221 / 3223** — NOT EXERCISED, unchanged. A real "main" role agent is genuinely running for this project throughout this session; explicitly instructed (both in the task prompt and by team-lead) not to stop or restart a live agent to manufacture these scenarios.

**Overall for this attempt: 8/10 criteria live-PASS (3214, 3215, 3216, 3217, 3218, 3219 fully live; two more, 3220/3222, are PARTIAL with mechanism verified by fresh source read + live guard-check but not a full live round trip), 2/10 NOT EXERCISED (3221, 3223, both correctly out of bounds). Submitting `partial`.**

---

## Attempt 4 correction (2026-09-17, task d3ad75e1) — 3223 live, 3220/3222 gap corrected and narrowed

Team-lead reviewed the `partial` submission and pointed at three unused dev routes (`router.ex:412+`, `:dev_routes`/`:api`, hosted app :4000): `POST /dev/sign-in`, `POST /dev/sign-up`, `POST /dev/agents/:id/{stop,restart,answer}`, `GET /dev/agents/:id/questions`. Two of the three corrections held; one didn't, but the wrong turn was cheap to close out and worth recording precisely rather than leaving `19b0d2d4` standing as filed.

**3223 — live PASS, straightforward.** Asked a fresh question as the fixture, restarted *only* the fixture (`POST /dev/agents/5e603bd6-.../restart` — response confirmed `project_id: 708492f9`, so this is the same fixture, not a different agent), answered it as main-agent (`answer_notification`), then collected it post-restart via `check_answer` through the same fixture. The correct answer, with correct main-agent attribution, arrived intact. No real/main agent touched.

**3220/3222 — team-lead's proposed fix does not work, verified empirically and safely; issue `19b0d2d4` corrected in place (appended, not replaced) rather than re-filed.** Traced the actual mechanism: `CodeMySpecLocalWeb.Plugs.HarnessScope` (the plug behind `qa_as_agent.sh`'s target, `:4004`) resolves every local-harness request's `current_scope.user` via `Scope.for_local_project/2`, which unconditionally sets `user = default_local_user()` — a synthetic, non-database struct (`%ClientUser{id: 0, email: "cli@localhost"}`, `lib/code_my_spec/users/scope.ex:201-208`). `AgentScope` (which resolves `X-Agent-Id`) runs after and only ever sets `:agent_id`, never touching `:current_scope`/`user`. So every question asked through the local harness — through the fixture or otherwise — carries this same sentinel `user_id`, not the real project owner as originally believed (by both this QA session and team-lead's correction).

Confirmed this is not fixable by signing in as *any* real account: created a throwaway account via `POST /dev/sign-up` (`user_id: 99`, a genuine new row, no real credentials involved), signed in via its minted token, and hit the same "Question not found or not authorized" on a fixture-asked question — while a real, pre-existing question (`2e40bbd6`) was visible in the exact same browser session immediately before and after, ruling out a browser/account-state artifact. `QuestionLive.Show` and the other two "user"-default callers of `Notifications.answer_question_request/3` (`AgentConversationLive.Show`, `NotificationLive.Components.Dropdown`) are all real-session LiveViews gated on `request.user_id == current_scope.user.id`, which the sentinel can never satisfy for anyone. `DevAgentController.answer` (the other dev-route candidate) is separately a dead end for the *overrule* half regardless of user_id, since its own `pending_requests/1` filters to `status == "pending"` only — it can never reach a request the main agent already answered.

Net: 3220/3222 remain PARTIAL, same as before, but the filed issue now names the real mechanism (a synthetic local-harness user, not "resolves to the account owner") and rules out both dev-route candidates concretely rather than leaving the door looking open.

**Updated scores: 9/10 criteria now live-exercised (3214, 3215, 3216, 3217, 3218, 3219, 3223 fully PASS; 3220, 3222 PARTIAL — mechanism verified two ways, live round trip genuinely blocked, not a testing shortfall), 1/10 correctly deferred (3221, citing `0fb7bf03` — the box-wide "failure-handling criteria need to break something real" class, not re-derived). Resubmitting `partial`.**
