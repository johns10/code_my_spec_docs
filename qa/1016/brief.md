# Qa Story Brief — Story 1016: The main agent reads what its agents cannot

## Tool

`run_script` (the `CodeMode`/MCP surface) plus direct curl against `4004/mcp`
for spine tools (`ask_user_question`, `check_answer`). This story has no
LiveView surface of its own — everything it promises is agent-to-agent, over
MCP. Do not use Vibium; do not use Fixtures (that's the spex layer, in-process
— it is not a QA surface and it hides wiring defects the real HTTP path can
have).

## Auth

None needed beyond the standard local harness scoping. Use this worktree's
own harness id from `.cms_harness.json` (`X-Harness-Id: 9f77b922-9810-4b49-
931d-b073012bc317`) for any direct curl. `run_script` picks up harness scope
from the calling session automatically.

Tool-scoping tests need real Agent rows of specific roles to pass as
`run_script`'s `agent_id` argument (a body parameter, not a header — this is
the mechanism `CodeMySpec.Agents.ToolSets` gates on). Rather than spinning up
new engine-backed agents (expensive, and would leave real autonomous
processes running against this project), reuse real, already-registered
agents visible via `list_agent_work({})`:

- main: `b49cb24a-0f07-4746-9138-0238f0f6aff3`
- product: `780b1159-1094-4e37-8fe3-190fb88b9be9`
- coding: `0067d652-1059-4e6d-a3ec-6e742435779a`

These IDs will drift as the fleet restarts; re-resolve via `list_agent_work`
if they're gone.

**Do not call `ask_user_question` against the real project more than once.**
See Setup Notes — it escalates straight to the real user's `/app` inbox and
fires a real push notification, regardless of which agent you claim to be.

## Seeds

None needed. Use real project data — this story is exercised entirely through
real Stories/Epics/Agents/Issues already in the project. Do not use the
`qa_sandbox` project for this story: nothing here needs disposable backlog
content, and the mutation this story does perform (`assign_story_to_epic`) is
fully reversible via the same tool (omit `epic_name` to unassign) — verify the
before/after state with `ready_stories_without_epic({})` or `get_story` and
put it back exactly where you found it.

## What To Test

- **3313 — sees past a role's tool list.** `run_script({agent_id=<product>,
  script="return ready_stories_without_epic({})"})` → refused ("is not a tool
  a product agent carries"). Same script with `agent_id=<main>` → succeeds and
  returns the real orphan story/stories. Comparative — both halves matter.
- **3327 — acts where a role cannot.** `assign_story_to_epic` as `<coding>` →
  refused. As `<main>` → succeeds; confirm via `ready_stories_without_epic`
  that the story left the orphan list (not via `get_story`, which doesn't
  render the same way `list_epics`/`assign_story_to_epic` do — read it back
  through a different surface than the one that wrote it). **Revert
  immediately**: `assign_story_to_epic({story_id=..., epic_name omitted})`,
  and confirm the story is back in the orphan list before moving on.
- **3328 — full scope isn't everybody's work.** `take_over_work({agent_id=
  <a real, existing agent id>, task_id="anything"})` as `<main>` → always
  refused. (`task_id` is structurally unused in the current implementation —
  `CodeMySpec.MainAgent.take_over_work/3` never branches on it — so this tool
  cannot currently succeed for *any* input. That's consistent with this
  story's only assertion about it, which is refusal; there is no criterion
  here that exercises a genuine takeover.)
- **3314 — a blocked agent is unblocked.** As `<product>`, `ask_user_question`
  with title prefixed `[QA TEST — ignore]` (see Setup Notes on why). Check the
  row lands `holder: "main_agent"` with a real `agent_id` (psql or wait for
  `list_open_questions` as `<main>` to show it). As `<main>`, `answer_question`
  with `basis: "record"` and an answer that actually contains a real orphan
  story's title (see below — the check is literal substring match against
  `ready_stories_without_epic`, not semantic). As `<product>`, `check_answer`
  gets the reply. Confirm `list_open_questions` as `<main>` is clear again.
- **3315/3329 — a workaround becomes a filed issue, immediately, on the first
  occurrence.** Same as 3314's answer flow, plus `worked_around: "<gap
  text>"`. One occurrence is enough — `list_issues({scope="framework",
  status="incoming"})` shows a new issue naming the role and the gap right
  after the first answer, not after a pattern accumulates.
- **3330 — the same workaround is not filed twice.** Repeat the 3315/3329
  flow two more times with the *same* `worked_around` text. Still exactly one
  matching issue (dedup), and `get_issue` on it now says "3 times" (or
  whatever the true count is) in the body — recurrence is counted, not
  silently dropped.
- **3316 — an agent cannot use the main agent to escape its own scoping.** As
  `<coding>`, `ask_user_question` asking main to submit a QA result on its
  behalf (coding doesn't carry `submit_qa_result`). As `<main>`,
  `answer_question` with `basis: "record"`, `on_behalf_of: "coding"`,
  `tool: "submit_qa_result"` → refused (`ToolSets.for_role(:coding)` doesn't
  include it). Then answer it for real (any `basis: "record"` answer
  containing a real orphan title) to dispose of it cleanly rather than
  leaving it open.

**The `basis: "record"` check is real, not a formality.** `recorded?/3`
checks whether your answer text *contains the title of an actual current
`ready_stories_without_epic` story* — nothing else satisfies it. Fixture-style
answers ("Dunning emails go out") will get `:not_recorded` on the real
project, because that story doesn't exist here. Look up the real one first
(currently "The main agent onboards me", story 1030) and put its title
somewhere in your answer string.

**Dispose of every question you raise.** `answer_question` (even a refused
`on_behalf_of` attempt) leaves the question open until a *successful* answer
call settles it. Always follow a refusal-path test with a real, successful
`answer_question` call so nothing is left sitting in `list_open_questions` —
or worse, orphaned with `holder: "user"` if the routing itself is what's
broken (see Setup Notes).

## Result Path

No `result.md` — file findings via `create_issue` as you hit them, and call
`submit_qa_result` once at the end with the scenario list and every issue id.

## Setup Notes

**Tag every test question `[QA TEST — ignore] ...` in both the `title` and
the question text.** `ask_user_question` has no way to mark a question as
scaffolding, and an untagged one is indistinguishable from a real blocked
agent — the project owner cannot tell the difference from the text alone
(this bit John twice during this story's QA before the convention existed).

**Two real transport bugs stood between `ask_user_question` and a working
`holder: "main_agent"`, both now fixed — history kept here because the
symptom (`agent_id` NULL, `holder: "user"`) is identical for either and a
future regression in either layer will look exactly the same:**

1. `CodeMySpecWeb.Plugs.AgentScope` (reads `X-Agent-Id` into
   `frame.assigns[:agent_id]`) was wired into the **hosted** endpoint's
   `:mcp_protected` pipeline only. The **local** `:mcp` pipeline had no
   equivalent. Fixed in `1927ae077` by adding
   `CodeMySpecLocalWeb.Plugs.AgentScope` to `lib/code_my_spec_local_web/
   router.ex`'s `:mcp` pipeline, after `HarnessScope`.
2. That fix alone did not work, because `4004/mcp` is not
   `CodeMySpecLocalWeb.Endpoint` directly — it is the light harness's proxy
   (`CmsHarness.Web.McpController`), which forwards only an allowlisted set
   of headers to the real server and silently drops the rest. `x-agent-id`
   was not on that list, so the header died at the proxy before reaching
   either pipeline. Fixed in `4c36f22e9` by adding it to `@forwarded`.

Both are needed together. If `agent_id` ever comes back NULL again, check
both layers rather than assuming it's a repeat of whichever one you fixed
last.

**Do not clean up a stray question via `mix run -e`.** The sanctioned code
path (`CodeMySpec.Notifications.answer_question_request/2`) requires a
one-off `mix run`, which holds the compile lock and 500s the shared dev
server (`:4000`) for everyone actively working against it. Leave a stray
question for the actual user to dismiss in the UI, and say so — don't trade
one live side effect for a worse one.

**Reverting `assign_story_to_epic` needs the tool's own unassign path, not
`update_story`.** `update_story` does not accept `epic_id` at all — passing
it is silently ignored (the call still reports success), which reads as a
successful revert and is not one. Use `assign_story_to_epic` with
`epic_name` omitted instead; verify with a fresh `ready_stories_without_epic`
read after (`get_story`'s own epic display is a red herring here — a story
with `epic_id: nil` and one whose response body just doesn't happen to render
the field look identical at a glance; watch the DB or the reciprocal
listing).
