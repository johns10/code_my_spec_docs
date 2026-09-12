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
- **3314, 3315, 3316, 3329, 3330 — everything routed through
  `ask_user_question` / `AnswerQuestion` / `list_open_questions`.** See Setup
  Notes below before attempting any of these live. As of this QA pass they
  cannot be exercised end-to-end on the real running local app: a structural
  gap (filed as issue `9c1c6d69-fdd1-4109-8d67-c6fb52f6507e`) means a
  question raised through the real `4004/mcp` endpoint never carries the
  asking agent's identity, so it can never be routed to `holder:
  "main_agent"` — it always escalates straight to the real user. Do not
  re-run this experiment to "confirm" it; the finding is already filed and
  reproducing it again only creates more real inbox/push noise for no new
  information.

## Result Path

No `result.md` — file findings via `create_issue` as you hit them, and call
`submit_qa_result` once at the end with the scenario list and every issue id.

## Setup Notes

**`ask_user_question` has no `agent_id` parameter.** It reads
`frame.assigns[:agent_id]`, which is populated by
`CodeMySpecWeb.Plugs.AgentScope` (reads `X-Agent-Id`) — but that plug is wired
into the **hosted** endpoint's `:mcp_protected` pipeline only
(`lib/code_my_spec_web/router.ex:39`). The **local** endpoint's `:mcp`
pipeline (`lib/code_my_spec_local_web/router.ex:325-328`) is just `LocalOnly`
+ `HarnessScope` — nothing sets `:agent_id` there, and nothing in all of
`lib/code_my_spec_local_web` does either. Sending `X-Agent-Id` on a curl to
`4004/mcp` is silently dropped: `holder_for(scope, nil)` returns `"user"`,
and the question goes straight to the real project owner's `/app` inbox with
a real Web Push notification, immediately, on tool success — there is no dry
run and no confirmation step.

Only the **first** live probe of this actually needs to happen — it already
did, during this QA pass (question id `29c7acb6-0903-4833-98b1-18eab11cfb01`,
row confirmed via `psql` to have `agent_id` NULL and `holder='user'`). A
second tester hitting the same wall gains nothing and costs the project owner
another notification. If this gap gets fixed, re-verify criteria 3314/3315/
3316/3329/3330 fresh rather than trusting this note forever.

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
