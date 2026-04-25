# QA Brief — Story 559: Three Amigos

The Three Amigos surface is a PM-facing LiveView wall on the local app
(`/projects/:project_name/stories/:story_id/three-amigos`). It shows a story's
rules, scenarios, and open questions as cards, and re-renders in real time as
the agent calls `add_rule` / `add_scenario` / `add_question` MCP tools. The PM
can also edit a rule statement, delete a question, and resolve a question
directly from the wall.

This brief covers Story 559 acceptance criteria 5175–5180 (the LiveView UI
surface). Backend MCP tool semantics (5159–5174) are covered by the spex
suite at `test/spex/559_three_amigos/` and don't need re-QA at the UI layer.

## Tool

`mcp__vibium__browser_*` for the wall + `mcp__plugin_codemyspec_local__*`
(`add_rule`, `add_scenario`, `add_question`, `create_persona`,
`link_persona_to_story`) to populate fixture data and exercise real-time
re-renders.

## Auth

None. The local app on port 4003 uses `Plugs.LocalOnly` — loopback IPs are
admitted directly. No login, no session, no header. Just navigate.

If `127.0.0.1:4003/health` doesn't return `{"status":"ok"}` first, stop and
fix the server before continuing.

## Seeds

QA runs against the **dedicated QA story** seeded by `priv/repo/qa_seeds.exs`
(`id=565`, title "QA: Three Amigos UI smoke", under QA Fixture Project) — NOT
against the real story 559. Mutations land on this isolated fixture so the
dev dataset stays clean.

```
# Run once to ensure seed
mix run priv/repo/qa_seeds.exs
# expect line: story: exists "QA: Three Amigos UI smoke" (id=565)

# Confirm via MCP
mcp__plugin_codemyspec_local__list_stories search="QA: Three Amigos"
# expect: id=565, title="QA: Three Amigos UI smoke"

# Persona — required before add_rule will accept anything
mcp__plugin_codemyspec_local__create_persona name="QA PM" slug="qa-pm"
mcp__plugin_codemyspec_local__link_persona_to_story story_id=566 persona_slug="qa-pm"

# Rules + scenarios for the populated-wall test
mcp__plugin_codemyspec_local__add_rule story_id=566 \
  statement="Suspended cards cannot be used for purchases"
mcp__plugin_codemyspec_local__add_scenario story_id=566 \
  rule_statement="Suspended cards cannot be used for purchases" \
  title="Driver attempts purchase with suspended card" \
  body="Given... When... Then..." kind="happy_path"
mcp__plugin_codemyspec_local__add_scenario story_id=566 \
  rule_statement="Suspended cards cannot be used for purchases" \
  title="Driver retries with valid card" \
  body="Given... When... Then..." kind="failure_path"

# One open question to populate the rail
mcp__plugin_codemyspec_local__add_question story_id=566 \
  text="What grace period applies after suspension?"
```

If the MCP session goes stale (`No active session`), reconnect via `/mcp`
and retry — known interaction with Anubis Streamable HTTP, see plan.md
System Issues.

## What to Test

Drive every UI scenario from spex 5175–5180. Screenshot at every key state
into `.code_my_spec/qa/559/screenshots/` (note: Vibium writes to
`~/Pictures/Vibium/<basename>`, so name files with a scenario prefix and
`cp` them in at the end).

- **Empty-state listening (spex 5176)** — Navigate to a story with NO rules
  yet (e.g. unpopulated story id, or 559 before seeding above). Expect
  "Agent is listening" overlay on the wall and a `Listening` badge in the
  header. Screenshot `5176_listening.png`.

- **Populated wall renders (spex 5175)** — After seeding above, navigate to
  `http://127.0.0.1:4003/projects/code-my-spec/stories/559/three-amigos`.
  Expect:
    - Header with story title "Three Amigos", counts (rules, scenarios,
      open questions), and a session-state badge (not `Listening`)
    - One rule card on the canvas with the suspended-cards statement
    - Two scenario cards in their kind colors (happy_path + failure_path)
    - The question rail shows the open question
  Screenshot `5175_populated_wall.png`.

- **PM edits rule statement (spex 5178)** — Open the rule card's menu,
  click "Edit", change the statement to "Cards expire after 30 days
  unused", save. Expect the new statement visible on the card without a
  page reload. Reload the page and confirm it persisted. Screenshots
  `5178_before_edit.png`, `5178_after_edit.png`, `5178_after_reload.png`.

- **Real-time re-render (spex 5177)** — Keep the wall open in the browser.
  In a second context, fire `mcp__plugin_codemyspec_local__add_rule` with a
  new statement. Without manual reload, expect a new rule card to appear
  on the wall within ~2 seconds (LiveView push). Screenshot
  `5177_realtime_after_add.png`.

- **PM resolves a question (spex 5180)** — From the wall's question rail,
  resolve the open question (button or menu — explore). Expect the
  question to disappear from the open-questions rail (or move to a
  resolved indicator). Reload and confirm persistence.

- **PM deletes a question (spex 5179)** — Add a fresh question via MCP,
  then delete it from the rail. Expect it disappears. Screenshot
  `5179_question_deleted.png`.

- **Acceptance criterion deleted state (spex 5170, surface check)** — If
  the wall exposes deletion of all criteria, delete them and observe the
  wall return to empty/listening state.

After scripted scenarios, explore freely — try editing a scenario,
collapsing the rail, navigating away mid-edit, etc. File any UI defect
you find as a `qa` issue with severity matching impact.

## Result Path

`.code_my_spec/qa/559/result.md`

Status `pass` if all six bullets above produce the expected outcome.
`fail` if any do not. `partial` if a tool/feature isn't yet exposed at the
UI layer (the spex enumerate the intent — implementation may still be
catching up).

## Setup Notes

- Story 559 component_id is `nil`; this story isn't linked to a single
  surface component. The implementing surface is
  `lib/code_my_spec_local_web/live/three_amigos_live.ex` plus the MCP
  tools under `lib/code_my_spec/mcp_servers/bdd_rules/`.
- Spex are at `test/spex/559_three_amigos/criterion_517[5-9]_*.exs` —
  read them for exact rendered text and selector hints.
- The `three_amigos_live.ex` had a duplicate-`:for` compile bug fixed
  earlier today; if the page returns a CompileError HTML, run
  `mix compile` to confirm the fix is still in place before filing
  issues.
- Do **not** use curl to test the wall — it's a `:browser` pipeline
  LiveView. Vibium MCP only.
- The MCP `add_rule` tool rejects when a story has no personas linked
  (spex 5160). The seed step above creates and links a persona first;
  if you skip that, `add_rule` will return an error, not the expected
  rule card.
