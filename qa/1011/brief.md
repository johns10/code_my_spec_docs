# Qa Story Brief — Story 1011: The main agent sees every open question across its working copies

## Tool

`run_script` / direct code-mode MCP tools, driven as specific agents via `.code_my_spec/qa/scripts/qa_as_agent.sh` against the shared harness proxy on `:4004`. No LiveView surface is central to this story's own criteria (3267 is the one exception — see Setup Notes).

## Auth

No human login needed for the primary surface: `CodeMySpec.McpServers.MainAgent.Tools.*` are local-harness tools, identity comes from `X-Harness-Id` + `X-Agent-Id`, not a browser session.

```
export QA_WORKTREE=<sandbox checkout root>   # see Seeds
.code_my_spec/qa/scripts/qa_as_agent.sh <agent-id> <tool> '<json-args>'
```

`list_notifications`, `escalate_question`, `answer_notification`, and `create_working_copy` are code-mode only — wrap them: `run_script({script = "return list_notifications({})"})`. `ask_user_question`, `check_answer`, `list_user_questions`, `stop_agent`, `start_agent`, `start_task` stay direct per-tool calls.

Two sandboxes were used, never the real "Code My Spec" project:

- **QA Fixture Project** — `11111111-1111-4111-8111-111111111111`, harness `1fc425f5-7b88-4e32-86a3-c16c3317408c`, checkout `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`. Owner `qa@codemyspec.local`. Already has two distinct working copies registered (`1fc425f5-...` and a stale scratch one, `d1540d93-f639-448a-9dac-5317665e513f`), which is what makes it usable for the cross-checkout criteria without minting anything new.
- **Math Test Project** — `d7f466a1-591e-4f36-8319-42633f59411e`, harness `56f5bf62-9cf8-400d-abcd-6c796afd3437`, checkout `/Users/johndavenport/Documents/github/math_test_project`. Owner `johns10@gmail.com` (the real dev account — this project is still a sandbox, distinct from "Code My Spec").

## Seeds

```
mix cms.seed priv/repo/qa_wake_seed.exs
```

Tops up Math Test Project's fixture roster (2 coding, 1 product, 1 main). **The rows are reaped to `status: stopped` within about a minute of the harness's next report** (`record_running_on_copy/3`) because nothing is really running them — this is not a defect and, incidentally, is what let this pass demonstrate criterion 3263 for free (see below). Verify immediately before use:

```
psql -d code_my_spec_dev -c "select id, role, status from agents where project_id = 'd7f466a1-591e-4f36-8319-42633f59411e';"
```

QA Fixture Project needed no seed — it already carries dozens of agents (mostly `stopped`, which is fine: `AgentScope`/`ask_user_question` do not require the calling agent to be `running`).

**Correction carried forward from story 1009's brief, still not reflected in `plan.md`:** the plan's "a question asked through the local harness is addressed to nobody real (`user_id: 0`)" finding is stale for this box's actual topology. Every question raised this session — on both sandboxes — recorded the real, positive `user_id` of the project's real owner (verified via `psql`), not the `Scope.for_local_project/2` sentinel that the checked-out source (both this worktree and `main`, byte-identical) would produce if called directly. `:4004` on this box is the light-harness proxy, not `CodeMySpecLocalWeb`'s in-process `/mcp`, and it resolves identity differently. Filed as issue (see below) so this propagates into `plan.md` itself rather than living only in per-story briefs.

## What To Test

Ten criteria (3260–3269), against `CodeMySpec.McpServers.MainAgent.Tools.{ListNotifications,EscalateQuestion,AnswerNotification}` plus the asker's own `AskUserQuestion`/`CheckAnswer`/`ListUserQuestions`:

- **3260** (three agents, one place) — as three distinct Math Test Project agents (`coding`, `coding`, `product`), each `ask_user_question`. As any agent, `list_notifications`: all three question texts present, each with its own `agent:` id.
- **3261** (another working copy still visible) — on QA Fixture Project, ask from an agent on working copy `1fc425f5-...` and from an agent on working copy `d1540d93-...` (a second, already-registered checkout of the *same* project). `list_notifications` read from the first checkout's identity must still show the second checkout's question.
- **3266** (who asked it, from where) — read off the same listings as 3260/3261: every entry carries `agent: <id> (<role>, <status>)` and `checkout: <working_copy_id> <root>`, derived rather than caller-supplied.
- **3262** (answered stops competing) — `answer_notification` (`basis: "record"`, citing the real working-copy id) on one of the three 3260 questions. Re-list: that question is gone from both sections; `check_answer` from the asking agent confirms the actual answer text was delivered.
- **3263** (asker stopped, question not lost) — observed for free: the reaping described under Seeds moved every Math Test Project fixture agent to `status: stopped` between asking and listing, and every one of their questions remained fully listed throughout (title, agent id, checkout). This is arguably stronger evidence than a deliberate `stop_agent` call, since it demonstrates survival through the same unannounced-death path the criterion's own reasoning names ("an agent is restarted whenever its harness reconnects... so this is the ordinary case").
- **3264** (escalated does not look unhandled) — `escalate_question` on one of the three questions. Re-list: it moves out of "Needs your attention" into "Waiting on the user", keeps its id, gains `sent up because: <reason>`, and the section headings match `MainAgentMapper` exactly (`"Needs your attention"` / `"Waiting on the user"`).
- **3268** (nested question preserves original link) — a coding agent asks an "original" question; a main-role agent asks a "nested" one that names the original's id in its text; escalate the nested one. `list_notifications` shows both, the original still under "Needs your attention" naming the coding agent, the nested under "Waiting on the user" naming the main agent and the original's id. `list_user_questions` as the coding agent shows only the original, not the nested one (per-asker scoping holds even with a live nested question in flight).
- **3269** (chain resolves only its own blocker) — two independent coding agents each ask their own question ("Deployment target" / "Receipt retention" analogue). Answer only the first via `answer_notification`. `check_answer` on the second, both before and after, reads "Still waiting on the main agent" throughout — completely unaffected — while the first now returns its answer and has dropped off `list_notifications`.
- **3265** (guarded turn admission) and the **task-linkage/`start_task` half of 3268/3269** — see Setup Notes; not reachable from outside the spex harness on this pass.

## Result Path

No `result.md`. Findings via `create_issue`; outcome via `submit_qa_result` on task `007a19f5-aeb1-4032-b3c8-48155c265836`.

## Setup Notes

- **3265 is spex-only and stays that way.** Every scenario asserts on `CmsHarnessTest.Machine.status/1` (`busy?`, `queued`) and `HeldProvider.seen()` — whether a real turn/HTTP request to the model was or wasn't started by the admission path. There is no external surface that observes "did a turn start" independent of watching the actual engine process; QA has no access to `Machine`/`HeldProvider` outside the test harness. This matches the QA plan's own rule: "GenServer state / process internals: there is no QA surface here."
- **The task-linkage half of 3268/3269 is spex-only for this pass, not for the story.** `AskUserQuestion`'s `task_id` blocking behavior is real and callable — the gap is entirely on the *setup* side: getting a story to a state where `start_task` can legitimately claim `bdd_specs_exist` requires `three_amigos_complete` first, and every story on both sandboxes has that unsatisfied (`list_requirements({requirement_name: "three_amigos_complete", status: "satisfied"})` returned zero rows on QA Fixture Project). Running a real Three Amigos session live is an open-ended, LLM-driven interview — disproportionate to mint for this pass. Spex covers this with `ProjectStateFixtures.apply_project_kickoff/1` and `apply_three_amigos_for_story/3`, fixtures built specifically to skip that cost; QA instead verified everything about 3268/3269 that does not depend on a real task existing (attribution, coexistence, per-asker scoping, and answer-isolation between two independent blockers), which is the bulk of what's novel in both criteria.
- **3267 was not re-driven live this pass.** Its own moduledoc states it is "green on arrival... not because it was built for [this story]" — pure regression coverage of `Notifications.create_question_request/2` + `/app/notifications`, orthogonal to `CodeMySpec.MainAgent`. Nothing touched by 3260–3266/3268–3269's implementation intersects it (confirmed by reading `NotificationLive.Index` and `Notifications.list_pending_notifications/1`, which filter by `user_id` alone and never reference `holder`, `agent_id`, or the new `OpenQuestion` struct at all). Reproducing it live would mean minting a second project under one real owner purely to reconfirm pre-existing, unrelated LiveView behavior. Spex-covered; flagged rather than re-verified.
- Ids from this pass are all spent (each was asked once and is either answered or escalated): Math Test Project — `d69f73ea-787a-4e78-9ed0-4b610f0cee75` (answered), `1b03c568-4af8-42a6-9363-60919f17a46a`, `99d8418f-c9f5-4734-9655-f68d8d3eb94f` (pre-existing), `4e713331-b5cc-40ff-80ae-b841a268a6f6` (escalated). QA Fixture Project — `5b2ef0bb-3555-410f-9451-9ff0290e7ee9`, `55cfe047-dfab-4e4c-bc1f-578483ac7094`, `a23e9909-7f5c-4c1f-bd34-3659035b77d5` (3268 original), `62f3e8c0-013c-4170-8421-f1f78a50ab1e` (3268 nested, escalated), `99d0e9fe-2994-49db-83ce-6b572f7147c3` (3269, answered), `25a2667a-f8d7-44b6-9718-8fb80ae5695f` (3269 neighbor, deliberately left unanswered — reusable as a control for a future pass if still pending).
- QA Fixture Project's "Waiting on the user" section is now 16 entries deep, most of it leftover from stories 1004/1009/1017/896 — none of it blocks reading this pass's evidence (grepped by id throughout) but it is getting hard to eyeball. Flagged as a `scope: qa` issue rather than touched.
