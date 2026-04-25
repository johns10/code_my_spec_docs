# QA Result — Story 559: Three Amigos UI smoke

QA target: `CodeMySpecWeb.StoryLive.ThreeAmigos` mounted at
`/app/stories/:id/three-amigos`. **Note: the brief at `brief.md` was
written assuming the LiveView lived on the local app (port 4003). The
LiveView was refactored mid-session to the hosted server (port 4000),
which is the correct target. All scenarios below were exercised against
`http://127.0.0.1:4000/app/stories/566/three-amigos` after logging in
as `qa@codemyspec.local` and switching the active project to the QA
Fixture Project.**

QA Fixture Project + dedicated story (id=566 "QA: Three Amigos UI smoke")
were used so no mutations touched the real story 559 dataset.

## Status

fail

## Scenarios

- **5176 — listening state for empty story (PASS).** Loaded the wall
  with no rules/scenarios/questions seeded yet. Wall rendered the
  "Agent is listening" overlay with a `LISTENING` badge. Counts: 0
  rules, 0 scenarios, 0 open questions. Evidence:
  `screenshots/566_5176_listening_empty.png`.

- **5175 — populated wall renders for a populated story (PASS).** Seeded
  one persona, one rule with happy + failure scenarios, and one open
  question via `mix run /tmp/qa_seed_three_amigos.exs`. Reloaded the
  wall — header showed `1 rules / 2 scenarios / 1 open` and a `SEALED`
  badge (readiness gate cleared because the rule has both happy and
  failure scenarios). Rule card rendered with the statement, two
  scenario cards rendered in their `HAPPY` / `FAILURE` kind colors, and
  the question rail showed the open question. Evidence:
  `screenshots/566_5175_populated_sealed.png`.

- **5178 — PM edits a rule statement via the wall, change persists
  (PASS).** Opened the rule card's admin menu, clicked Edit, replaced
  the statement with `Cards expire after 30 days unused (edited via QA)`,
  saved. New statement visible immediately. Hard-reloaded the page;
  edit persisted. Evidence:
  `screenshots/566_5178_rule_edited_persisted.png`.

- **5180 — PM resolves an open question via the rail (PASS).** Opened
  the question's admin menu, clicked Resolve. Counts flipped from
  `1 open · 0 resolved` to `0 open · 1 resolved` and the question card
  status changed to `RESOLVED` without a reload. Evidence:
  `screenshots/566_5180_question_resolved.png`.

- **5179 — PM deletes a question via the rail (PASS, with caveat).**
  Created a fresh question via context call, reloaded, opened admin
  menu, clicked Delete. The Delete button has
  `data-confirm="Delete this question?"`; the confirm dialog has to be
  accepted before the LiveView fires the event. After accepting,
  question removed and counts dropped from `1 open · 1 resolved` to
  `0 open · 1 resolved`. Evidence:
  `screenshots/566_5179_question_deleted.png`.

- **5177 — wall re-renders when agent calls add_rule mid-session
  (FAIL).** With the wall loaded and showing 1 rule, called
  `BddRules.create_rule/3` from a separate `mix run` process. The new
  rule landed in Postgres (verified via reload — rule count went from
  1 to 3 and the new statement appeared on the canvas) but the open
  page did NOT update. Rule count stayed at `1 rules`, the new rule
  card never appeared on the canvas, and there was no activity-ribbon
  flash. Page only picked up the change after a manual reload.
  Evidence: `screenshots/566_5177_realtime_after_reload.png` (post-
  reload — shows the new rule visible, confirming DB write but UI
  push failure).

## Evidence

All screenshots in `.code_my_spec/qa/559/screenshots/`. Each is
prefixed with the story id (`566`) and the spex criterion id.

## Issues

- **issue/three-amigos-pubsub-no-realtime-rule-create (high)** —
  `ThreeAmigosLive` does not re-render when `BddRules.create_rule/3`
  fires its broadcast. Spex 5177 expectation is that the wall updates
  in real time as the agent populates rules; this is the load-bearing
  behavior of the V4 cluster wall (the moduledoc explicitly says "all
  mutations land via MCP from the agent in Claude Code, and PubSub
  pushes the resulting cards in real time"). Reproduction: load
  `/app/stories/:id/three-amigos`, separately call
  `BddRules.create_rule(scope, story_id, %{statement: ...})`, observe
  no DOM update on the open page. Suspect: the moved LiveView
  (`CodeMySpecWeb.StoryLive.ThreeAmigos`) may not be subscribing to
  the same PubSub topic that `BddRules.broadcast/2` publishes on, or
  the `handle_info` clause for `:bdd_rule_created` is missing. Filing
  for triage.

- **issue/three-amigos-brief-out-of-date (low)** — The brief at
  `.code_my_spec/qa/559/brief.md` was written when the LiveView was on
  the local app at port 4003. The refactor moved it to the hosted
  server at `/app/stories/:id/three-amigos`. The brief still references
  the local URL and tells the QA agent to navigate via Vibium without
  authentication. Anyone re-running the brief verbatim will hit the
  refactor diff. Update brief to point at the hosted URL and document
  the auth step (login as `qa@codemyspec.local` /
  `qa-password-123!`, switch to QA Fixture Project). Filing for the
  doc fix.

- **issue/data-confirm-blocks-headless-clicks (info)** — The Delete
  button on question cards uses `data-confirm`. Headless / scripted
  clicks via `element.click()` skip the confirm dialog so no event
  reaches the server. Workaround: override `window.confirm = () =>
  true` before clicking, or use a click pathway that handles native
  dialogs. Worth documenting in the QA tooling cheat sheets so future
  agents don't bounce off this. Filing for docs.

- **issue/three-amigos-rule-card-duplicate (low, reproduce first)** —
  During the 5177 test the canvas rendered the new "Realtime test rule"
  card twice after reload, despite a single `create_rule` call. The
  count summary said "3 rules" but I'd only intentionally created 2.
  Possible duplicate-render bug in the rule cluster, or possible
  duplicate insert from an earlier seed step. Worth reproducing on a
  clean fixture before raising as a real defect.

- **issue/mcp-session-drops-during-qa (medium, ops)** — The Anubis
  Streamable HTTP session for the local MCP server (`4003/mcp`)
  returned `No active session` after every other tool call during this
  QA run, even immediately after `/mcp` reconnect. Drove me to fall
  back to `mix run` direct context calls instead of MCP tool calls.
  This is the same issue already filed as
  `issue/mcp-session-drops-frequently` — capturing here as confirmation
  it's still active and impacting QA workflows.
