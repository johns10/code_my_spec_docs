# Qa Story Brief — Story 1009 / 1052: The main agent answers what it can before the user sees it

## Tool

web (vibium CLI, MCP vibium server unavailable this session) + `run_script` (code-mode MCP tools) + the sandbox harness's own `/mcp` endpoint via curl (`qa_as_agent.sh`)

## Auth

Login as the QA sandbox project's real owner, `qa@codemyspec.local` (magic link — passwordless, one form):

1. `vibium go http://127.0.0.1:4000/users/log-in`
2. `vibium fill` the `#login_form_magic_email` input with `qa@codemyspec.local`, click "Email me a login link"
3. `vibium go http://127.0.0.1:4000/dev/mailbox` — the mailbox auto-opens the newest message; confirm it names `qa@codemyspec.local` before trusting the link (the mailbox is shared across every concurrent QA session on this box)
4. Extract the `/users/log-in/<token>` path and navigate to it on `http://127.0.0.1:4000` (the minted link points at `dev.codemyspec.com` — rewrite the origin)
5. No account/project picker step needed: `qa@codemyspec.local` now **owns** `qa-account`, which owns the QA Fixture Project outright (fixed in `b4ed31b4f` for issue `cd6f9eda`) — login lands correctly scoped.

Agent-identity calls (asking as a coding agent, answering/escalating as the main agent) go through `.code_my_spec/qa/scripts/qa_as_agent.sh <agent-id> <tool> '<json>'` with `QA_WORKTREE` pointed at the **sandbox** checkout, never this worktree:

```
export QA_WORKTREE=/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
.code_my_spec/qa/scripts/qa_as_agent.sh <agent-id> <tool> '<json-args>'
```

`answer_notification` and `escalate_question` are code-mode only (moved off the direct tool list) — wrap them: `run_script({script = 'return answer_notification({...})'})`. `ask_user_question` and `check_answer` stay direct.

## Seeds

No `mix run` seed needed. This story's asker/main-agent routing was driven against the **QA sandbox project** (`11111111-1111-4111-8111-111111111111`, harness `1fc425f5-7b88-4e32-86a3-c16c3317408c`), never the real project — questions cannot be un-asked, and the real project's owner inbox already carries stray probes from earlier sessions (issue `08d4d7bd`). Fixture agent pairs were minted per pass via `create_working_copy` against the sandbox harness (roles `coding,main`), then each working copy was offboarded at the end of its run (`offboard_working_copy` + `rm -rf` the scratch directory). None of the ids below still resolve — a future attempt mints its own pair the same way.

**Correction to prior attempts' finding:** the QA plan (and issue `7ba12775`) state that any question raised through the local harness carries a synthetic `user_id: 0` that no real account can ever match, permanently blocking the browser side of this story. That is **stale for the currently running build**. Empirically this session, every question asked against the sandbox harness recorded `user_id` = the real, positive DB id of `qa@codemyspec.local` (confirmed via `psql`), and `/app/questions/:id` rendered correctly for that account with no "not authorized" error. Whatever resolves this differs from what's in either checked-out worktree's `Scope.for_local_project/2` (still reads as synthetic id 0 in source) — the live behavior, not the static source, is what QA measured and what this brief reports. Worth re-confirming on a future pass rather than trusting either the old finding or this one indefinitely.

## What To Test

Ten criteria, tested via the full agent → main agent → user round trip on the sandbox project:

- **3218 / 3219** — Ask (as coding agent) a question the sandbox project's own fleet records answer (cite a real working-copy id/root — `answer_question`'s `record` basis is checked against `WorkingCopies.list_harnesses`/`Issues`/`ready_stories_without_epic`, needle ≥ 8 chars). Answer it (as main agent) via `answer_notification` with `basis: "record"`. Collect with `check_answer` (as coding) and expect `"The main agent replied, from project records: ..."`.
- **3215** — Attempt an answer with `basis: "record"` that cites nothing real. Expect the tool call itself to refuse (`:not_recorded`) and `check_answer` to then read `"Still waiting on the user"` rather than "not found" — a failed answer auto-escalates rather than stranding the question.
- **3214** — Ask a values/product question phrased in implementation terms (fictitious module name). Escalate it (as main agent) via `escalate_question` with `reason` and `as` (plain-language translation). Confirm on `/app/questions/:id`, logged in as the owner, that the rendered question is the **translated** wording, with the original preserved as `asked_as` (not shown as primary).
- **3221** — With no `main`-role agent ever actually started (row status `stopped` throughout), confirm an escalated question still reaches `/app/notifications` for the real logged-in owner, and `check_answer` still reports "waiting on the user" rather than nothing.
- **3217** — After a main-agent record-basis answer, confirm the question is listed on `/app/notifications` (status "answered") and the answer text renders on `/app/questions/:id` beside the question.
- **3222 / 3220** — On an already main-agent-answered question, log in as the real owner, open `/app/questions/:id`, select the "Other" radio, fill a correcting free-text answer, submit. Confirm: (a) `check_answer` now reads `"The user replied, overruling the main agent's earlier answer: <new text>"`; (b) the DB row's `answer_history` retains the original `{answers, answered_by: "main_agent", at}` entry; (c) a **second, independent** question answered by the main agent in the same session is untouched (`overruled: false`, `answered_by: "main_agent"`, `updated_at` unchanged) — override touches only its own row.
  - Also cover the two malformed-submission edges (regression coverage for issue `c9ef54b4`, resolved this pass, fix commit `5806043cc`): typing into "Other…" **without** clicking its radio must still land the typed text as the answer (previously recorded blank/empty and silently overrode a good answer); submitting with **nothing** selected and nothing typed must be refused (`Failed: :empty_answer`) with the prior answer left intact.
- **3216 / 3223** — Structurally spex-only: both need a real `start_task`-claimed, three-amigos-satisfied story (via `StoryHelpers`/`ProjectStateFixtures`, spex-only fixtures), and 3223 additionally needs a running/restartable engine (`Machine`/`HeldProvider`), which exists only inside the spex harness. Not reachable from plain MCP QA calls on any project, sandbox or real. `criterion_3216_..._spex.exs` and `criterion_3223_..._spex.exs` are present and passing per repo state.

## Result Path

No `result.md`. Findings filed via `create_issue` as found; outcome recorded via `submit_qa_result` on task `d84093bf-06a0-4c12-89cf-8a6dfdcad087`. Screenshots in `.code_my_spec/qa/1009/screenshots/`:
`4000_question_pending.png`, `4000_notifications_inbox.png`, `4000_question_answered.png`, `4000_escalated_translated.png`.

## Setup Notes

- Every question id created this session is on the **sandbox** project and already resolved (answered or overruled) — none are reusable repros. First pass: `ed0e58c4` (record answer, then spent by an accidental empty-override test), `54c13fa5` (record answer → correct override, `answer_history` verified), `2cafbfe4`/`3ea2b6f8` (independence controls), `0c94c05a` (product decision, escalated with `as` translation). Fix-verification pass: `e8e26251` (other-without-radio, now records the typed text correctly), `a0cba7c6` (genuinely empty submit, now refused, original answer intact).
- Filed and **resolved** issue `c9ef54b4-ab89-4d4c-9904-6aca5d5172c2`: the answer-override form used to accept a submission with the "Other" radio unchecked but its paired text field filled, silently recording an **empty** answer and setting `overruled: true`. Fixed in `5806043cc` (text typed into "Other…" with no radio checked is now read as the choice; an all-blank submission is refused with `:empty_answer` before anything is written). Verified live this session with two fresh questions — see above.
- Prior attempts on this task (`98e3e824`, `651658c8`, both `partial`) could not construct a non-main-role asker identity at all and treated most of this as spex-only. `qa_as_agent.sh` plus a sandbox-scoped fixture pair (`create_working_copy` with `roles: "coding,main"`) closes that gap; this pass reached 3214/3215/3217/3218/3219/3220/3221/3222 live.
- **Mid-session git anomaly, worth flagging:** partway through this pass, the `.code_my_spec` submodule's checkout was found in a detached HEAD state (`detached from a2e20f6`) with a `brief.md` edit from earlier in the same session silently reverted to a stale prior-attempt version (working tree reported clean against that detached HEAD). Screenshots (untracked files) survived; the tracked `brief.md` edit did not. Rewritten a second time from this session's own notes before final submission. Something on this shared box appears to check out `.code_my_spec` to a specific commit during a session — worth someone tracing if it recurs, since a subagent has no way to detect it happened except by re-reading the file before trusting it.
