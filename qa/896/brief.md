# Qa Story Brief

Story 896 — Agent sees the questions it has open.

Ships `ask_user` / `list_user_questions` / `check_answer` as in-process MCP
tools (replacing the old HTTP-arbitraged `AskUserQuestion` interception), a
question count on the stop-hook refusal (`CodeMySpec.Validation.Menu`), no
expiry for open questions, and one shared answer-form component
(`CodeMySpecWeb.ChatComponents.question/1`) rendered on both
`QuestionLive.Show` (`/app/questions/:id`) and `AgentConversationLive.Show`.

## Tool

Three, by surface:

- `mix spex` for the tool-surface and session-scoping criteria (2414–2421) —
  this story's own spex suite drives `AskUser`/`ListUserQuestions` in-process
  and `QuestionLive.Show` via `Phoenix.LiveViewTest`.
- MCP tool client (this agent's own typed `mcp__plugin_codemyspec_local__*`
  tools) for read-only/idempotent live confirmation: `list_user_questions`,
  `check_answer`.
- `web` (Vibium) was the intended tool for the two UI-rendering criteria
  (2421 live round trip, 2422 shared-component visual confirmation) but could
  not be exercised this cycle — see Setup Notes.

## Auth

Spex: `register_log_in_setup_account` + `setup_active_project`, same as
every other spex in the suite — no manual login.

MCP tool client: authenticates implicitly as whoever the connected Claude
Code session's harness serves. For a worktree of this repo that is the real
`phx-new-generator` dev harness (`6bc4851f-f735-4590-bb1c-c660619b4019`),
which resolves to the real project owner — there is no parameter to redirect
a typed tool call elsewhere. This is exactly what made `ask_user` unsafe to
call repeatedly this cycle; see Setup Notes.

Browser/UI: would need either a login as the real project owner (ruled out —
not this agent's account to use) or an isolated QA account against a sandbox
harness (blocked this cycle — see Seeds).

## Seeds

None needed for the spex suite — it creates its own sessions via real
`POST /api/hooks/session-start` calls and its own questions via `AskUser`.

For an isolated live/browser pass, the QA Fixture Project already exists
(`11111111-1111-4111-8111-111111111111`, owner `qa@codemyspec.local`,
`local_path` = `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`)
but has **no harness row**, so no `X-Harness-Id` currently routes to it.
Provisioning one via `mix cms.harness.onboard <sandbox path>` requires
`CMS_TOKEN` or `CMS_DEPLOY_KEY`; neither is set in this environment and no
cached credential exists — this blocked the live/browser pass this cycle.

## What To Test

- **2414** — a question on its own does not hold the agent in the loop.
  `ask_user` a question, then fire a stop; the refusal must not force a wait
  on the reply.
- **2415** — a refusal carries the count of what is waiting on the user (`N
  questions are open and waiting on the user`).
- **2416** — a refusal with zero questions open does not print a count.
- **2417** — `list_user_questions` returns this session's own questions,
  oldest first.
- **2418** — a question asked from an earlier session on the same harness
  does not appear in a later session's list.
- **2419** — answer a question via `QuestionLive.Show`
  (`/app/questions/:id`, `data-test="question-form"`); it must drop off
  `list_user_questions` while a second, unanswered question stays listed.
- **2420** — fire two stops with a question still open; it must still be
  listed and never reported as `expired`.
- **2421** — `ask_user` → `list_user_questions` → `check_answer` end to end,
  entirely in-process (no `{:http, 401}`, no arbitraged `AskUserQuestion`).
- **2422** — visit `/app/questions/:id` and a conversation view with an open
  question; confirm the same answer form (same fields, same submit
  behaviour) renders in both places.

## Result Path

No result.md — findings filed via `create_issue`, outcome submitted via
`mcp__plugin_codemyspec_local__submit_qa_result`. Already called this cycle:
`status: partial`, attempt id `df9a0906-11d5-4cb2-8313-453269e1b9e8`, task
`b494b75e-31ed-4e0a-b563-56dbd014c3d1`.

## Setup Notes

**Spex, run fresh this cycle (2026-08-17):**
`elixir -S mix spex --pattern "test/spex/1017_agent_sees_the_questions_it_has_open/**/*.exs"`
→ `7 tests, 0 failures`, covering 2414–2420. `criterion_2419` is the
strongest single piece of evidence for 2422 as well: it drives the real
`QuestionLive.Show` route via `Phoenix.LiveViewTest` — `live(conn,
"/app/questions/:id")`, then `form("[data-test='question-form']", ...) |>
render_submit()` — submitting through the actual
`ChatComponents.question/1` template and the real `phx-submit="submit"`
handler, one host short of a browser.

**2422, structural confirmation:** `QuestionLive.Show`
(`lib/code_my_spec_web/live/question_live/show.ex:70`) and
`AgentConversationLive.Show`
(`lib/code_my_spec_web/live/agent_conversation_live/show.ex:252-257`) both
call the identical `CodeMySpecWeb.ChatComponents.question/1`, differing only
in the `on_submit` attr — confirmed by direct source read of both call
sites and the component definition
(`lib/code_my_spec_web/components/chat_components.ex:404-532`), whose own
moduledoc documents this exact lift-and-reuse. What this does **not**
confirm: nothing drives the component through the
`AgentConversationLive.Show` host (spex or browser), and no live screenshot
of either host was taken.

**Mistake made this cycle, and why it's not repeatable:** called this
agent's own typed `ask_user` tool against the real harness (not a sandbox),
creating a question in the real project owner's `/app` inbox
(`d59f0cde-2eee-4c8e-925a-c22f032dcc8a`, "QA 896 probe — please ignore").
This is the second time this exact mistake has happened on this story — a
prior, cancelled QA run hit the identical trap
(`95dfe268-77eb-4182-80bc-6c34d8f388f0`). Caught after one call and not
repeated. Filed as a framework issue, since generalized: `08d4d7bd-54f4-4274-83a6-fd2f050daca4`.

This is a decision, not an oversight, and not a defect to route around:
896's Three Amigos deliberately deleted the `expired` status rather than
build a sweeper — a question vanishing on a clock is a decision the user
never made disappearing from the one place they'd see it. Answering is the
only terminal state, by design, and both stray rows are exactly that —
probes needing an answer, not permanent clutter. The project owner is aware
of both and no cleanup action is expected or possible from an agent.

Independently re-verified via `check_answer` this cycle (not just
taking that awareness on faith): `95dfe268-…` **has been answered** —
`check_answer` now returns the real reply text ("Test") instead of
"still waiting". `d59f0cde-…` (this cycle's own probe) was **still
pending** as of the same check. That first result is genuine, unscripted
live evidence, from a real user, of the full loop this story ships:
`ask_user` → shown in `/app` → answered in the UI → `check_answer`
returns the reply — independent of both the spex suite and of this QA
cycle's own (mis-scoped) round trip.

**What would close the gap:** a sandbox harness with its own MCP endpoint
would let a follow-up pass drive `ask_user` end to end against isolated
data and take real screenshots of both hosts of the shared component,
upgrading 2422 to a full pass and giving 2421 a cleanly-scoped live
confirmation instead of a mis-scoped one.
