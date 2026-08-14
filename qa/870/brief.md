# QA Brief — Story 870: Watch what a background sprite is actually doing

## Tool

web

## Auth

The story's surface is a project-scoped LiveView, so it needs a logged-in user with
an account and a project. Do **not** reuse the operator's own browser session — a QA
run logs it out and the operator loses their place.

1. `http://localhost:4000/users/register` — register a throwaway address on the
   `codemyspec.local` domain, e.g. `qa-<topic>@codemyspec.local`.
2. `http://localhost:4000/dev/mailbox` — take the newest `/users/log-in/<token>` link
   and navigate to it. The mailbox is shared: if the newest link is not yours, another
   QA session is running and you will be logged in as them. Match the recipient before
   clicking.
3. Create an account, then a project, through the onboarding forms that follow.
4. Keep the project's UUID — every URL below needs it.

## Seeds

There is no seed script for this story. The rendering criteria each need a specific
message *shape*, and the recorder only produces those from a live model turn, so seed
`conversation_messages` rows directly.

Insert one `conversations` row with `type: 'agent'` and a `session_external_id`, then
the message shapes below. `psql -qtA code_my_spec_dev` against the dev database; take a
`pg_dump` of the two tables first and delete the seeded rows when finished.

The shapes that matter, and which criteria each one is for:

| Shape | Stored as | Covers |
|---|---|---|
| A person's typing | `role: user`, plain text | 2366 |
| The agent's prose | `role: assistant`, plain text | 2366 |
| A call the recorder wrote | `role: tool`, `"Bash\n{json}"` | 2364, 2367 |
| Five such calls in a row, no prose between | five consecutive `role: tool` rows | 2371, 2372 |
| One call with prose either side | a single `role: tool` row | 2373 |
| A call with no arguments | `role: tool`, bare name, no newline | 2369 |
| A ~5 kB payload | `role: tool`, `"Write\n{...}"` past 600 bytes | 2368 |
| A qualified MCP name | `role: tool`, `mcp__plugin_codemyspec_local__add_scenario` | 2375 |
| Output misfiled under the call role | `role: tool`, multi-word first line | 2374 |
| A tool result | `role: user`, `"← result: …"` | 2362 |
| A failed result | `role: user`, `"← failed: …"` | 2363 |
| A sub-agent's call | any call row with `agent_role: 'qa'` | 8172 |

## What To Test

Set the viewport to **375 × 812** before loading anything. Every criterion here is
about what fits and what is readable, and none of them fail at desktop width.

- `/app/projects/<id>/agent-conversation` — the transcript renders; the page does not
  scroll horizontally (`documentElement.scrollWidth <= 375`).
- The run of five consecutive calls renders as **one** `[data-test='tool-call-group']`
  with `data-count='5'`, closed by default (2371).
- Opening the group lists five `[data-test='tool-call']` entries showing names only;
  opening one entry's `arguments` disclosure leaves the other four closed (2372).
- The lone call is **not** inside the group and has no group wrapper of its own (2373).
- The misfiled `role: :tool` output renders as `[data-test='tool-result']`, not as a
  call whose first line is offered as a tool name (2374).
- The qualified MCP name is fully visible — measure it, do not eyeball it. Compare the
  name element's `scrollWidth` to its `clientWidth`, and its card's to the card's. A
  name wider than its card is clipped, and clipped is how `add_scenario` and `add_rule`
  become the same block (2375).
- Results: one carries `data-failed='true'` and reads as failed without reading its
  text; the other does not (2362, 2363).
- Prose from each side sits on opposite sides and is matched by neither the call nor
  the result selector (2366).
- A call block shows the tool name with arguments behind a **closed** disclosure
  (2367); the oversized payload carries `data-truncated='true'` and says so **inside**
  the disclosure, so a closed block stays compact (2368); the bare name offers no
  disclosure at all (2369).
- The `agent_role: 'qa'` call renders `QA` beside its name where main-agent calls
  render `MAIN` (8172).
- `/app/projects/<id>/inbox` — the agent conversation is **absent**: no rows, no unread
  count, "No conversations yet", while the same conversation is still fully present on
  its own surface (8177).

Three criteria are not browser-reachable and are covered by spex instead — say so in
the observation rather than claiming a browser check: 8171 (both halves recorded),
8175 (needs a broken store), 8176 (needs a turn arriving while the page is open).

## Result Path

Findings go to `create_issue` as they are found and the attempt goes to
`submit_qa_result`. Screenshots to `.code_my_spec/qa/870/screenshots/`.

## Setup Notes

`:4000` serves the **main checkout**, not a worktree. A fix made in a worktree is not
on the page until it is pushed and the main checkout fast-forwarded — verifying against
a stale server is how a fix gets confirmed that nobody shipped.

The three tool-call surfaces share `CodeMySpecWeb.ChatComponents`, so a rendering
defect found here is worth re-checking on `/app/projects/<id>/inbox` and the story
interview before it is called story-specific.
