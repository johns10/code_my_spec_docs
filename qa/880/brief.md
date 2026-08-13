# Qa Story Brief

Story 880 — "The first story is shaped in conversation, before any code."
Surface: `CodeMySpecWeb.ChatLive` at `/app/projects/:project_id/chat` (`:browser` pipeline).

## Tool

web

## Auth

Hosted magic-link login, port 4000, seed user `qa@codemyspec.local`:

1. `browser_navigate` to `http://127.0.0.1:4000/users/log-in`
2. Fill `input[name="user[email]"]` with `qa@codemyspec.local`, click "Email me a login link"
3. `browser_navigate` to `http://127.0.0.1:4000/dev/mailbox` — read the newest message addressed
   to `qa@codemyspec.local`. **Shared mailbox warning:** other QA agents run concurrently
   against this same dev server and may also use this seed user. Confirm the mailbox has
   exactly one message (or that the message timestamp is right after your own send) before
   trusting the link — otherwise you may be logging in as whatever the last agent requested.
4. Open the message's HTML body (`/dev/mailbox/:id/html`), extract the `https://dev.codemyspec.com/users/log-in/:token` link, **rewrite the origin to `http://127.0.0.1:4000`**, navigate to it.
5. Confirms landing on `/app` as `qa@codemyspec.local`. Verify via page text before proceeding —
   don't assume the login link was yours.

## Seeds

Dev server was already running; seeds were verified in place rather than re-run (re-running
`mix run priv/repo/qa_seeds.exs` against a live `:dev` server 500s it — see plan.md):

```
psql -qtA code_my_spec_dev -c "select email from users where email='qa@codemyspec.local';"
psql -qtA code_my_spec_dev -c "select id, name, local_path from projects where id='11111111-1111-4111-8111-111111111111';"
```

Both present. Target project: **QA Fixture Project**, id
`11111111-1111-4111-8111-111111111111`, chat URL:
`http://127.0.0.1:4000/app/projects/11111111-1111-4111-8111-111111111111/chat`.

**Heads up — shared project, not empty.** This project already carries ~25 stories from
other concurrent QA agents. `ChatLive.assign_story/2` renders whichever story
`Stories.list_project_stories/1` returns first — on this project that is story id 1,
"QA: Three Amigos UI smoke". Criteria that assume a *fresh* project with zero stories
("four answers become one story", "second story is refused") cannot be cleanly observed
here even when the model is wired, because the story-count assertions
(`Floki.find("#stories > div")`, `nth-of-type(2)`) will be confounded by pre-existing
stories. Spex isolate this with a fresh `setup_active_project`; QA on the shared dev
project cannot replicate that isolation without a scratch project. If a clean read is
needed, create a fresh project first rather than reusing the fixture project for the
count-sensitive assertions.

## What To Test

**Blocking discovery — read this before running individual scenarios.**
`CodeMySpec.Chat.Runner.run_live/1` (`lib/code_my_spec/chat/runner.ex:100`) is a stub:
it unconditionally calls `Conversations.fail(conversation, "no model configured for this
conversation")` and never calls a provider. The `:chat_llm` application-env seam that lets
spex script tool calls is a test-only mechanism, set via `Application.put_env` inside the
spex process — there is no live-server equivalent reachable from a browser session, so it
cannot be used to drive the running dev app. **Confirmed empirically**: sending any message
via `[data-test='chat-compose']` on the live app immediately renders
`[data-test='chat-failed']` with text "no model configured for this conversation" — no tool
call ever fires. Screenshot: `screenshots/4000_880_chat_after_send.png`.

Practical effect: acceptance criteria that require the model to actually place a tool call
(create_story, list_stories, the step cap, the halt path, tool-call/tool-result rendering,
project-scoped tool dispatch) **cannot be exercised on the running app at all** — every
conversation fails on the first turn, before any tool runs. This is not a per-scenario bug
to reproduce individually; test it once, then move on to what IS reachable.

Scenarios actually reachable on the live app (don't require the LLM to work):

- **Message send + failure path** (touches criterion "a failure mid-conversation keeps what
  Sam already said," the persistence half only — not the "already-produced tool state"
  half, which needs a working model):
  - Navigate to the chat URL, fill `[data-test='chat-compose'] input`, submit.
  - Expect: the user's message renders as `[data-test='message'][data-role='user']`, followed
    by `[data-test='chat-failed']` (not `[data-test='chat-halted']`).
  - Reload the page (`browser_reload`) — both the user message and the `chat-failed` turn
    must still be present. This is durability without a chat_llm seam, and it passed.

- **Editing the story in place** (criteria "Sam corrects the story in place" / "the editor is
  the story UI, not a second one") — doesn't require the LLM, only that *some* story exist
  on the project, which the fixture project already satisfies:
  - Click `[data-test='story-card']` — expect it expands to `[data-test='story-form']`
    pre-filled with the existing story's title/description (real `Stories.change_story`
    form, not a chat-local copy).
  - Edit `#story_title`, submit. Expect the story-form re-renders with the new title (still
    editing) and the compose box is still usable.
  - Navigate to `/app/projects/11111111-1111-4111-8111-111111111111/stories` — the edited
    title must appear there, proving it's the same record, not a chat-local shadow.
  - **If you touch story id 1 ("QA: Three Amigos UI smoke") to test this, rename it back
    when done** — other QA agents depend on that title/description staying intact.

- **Start Three Amigos button**:
  - With a story present, click `[data-test='start-three-amigos']`.
  - Expect (per spex 8273): either the URL/page contains "three-amigos", or
    `[data-test='three-amigos-started']` appears.
  - **Confirmed empirically: neither happens.** `handle_event("start_three_amigos", ...)`
    only sets an assign (`three_amigos_started?: true`) that the template never reads — no
    navigation, no marker, no visible change at all. URL stays on `/chat`. This is a real,
    reproducible defect independent of the chat_llm gap.

- **Redirect gating** (not an explicit acceptance criterion, quick smoke only): navigating
  to `/app/projects/:id/chat` for a project not owned by the current scope should flash
  "That project is not yours, or does not exist." and redirect to `/app/projects` per
  `handle_params/3`. Not exercised this run — lower priority than the two structural
  findings above.

## Result Path

DB-backed attempt via `submit_qa_result`; no result.md. Screenshots in
`.code_my_spec/qa/880/screenshots/`.

## Setup Notes

Two structural findings block most of this story's acceptance criteria and should be filed
as issues rather than re-diagnosed per scenario:

1. `Chat.Runner.run_live/1` never calls a real provider — every live conversation fails on
   the first turn. Blocks: four answers become one story, second story refused, story lands
   on project, tool calls appear as made, cap/step-bounding, model-that-won't-stop halting,
   tools act on conversation's project, tool call arrives as tool call not prose, and the
   "kept tool-produced state" half of the mid-conversation-failure criterion. 9 of 13
   criteria.
2. "Start Three Amigos" is a dead click in the current build — sets an unused assign, no
   navigation or visible state change. Blocks: the review starts from a story already on
   the board.

What passed on the real app, independent of both gaps: message persistence across reload,
correct `chat-failed` (not `chat-halted`) marking on failure, and the story-card/story-form
editing flow round-tripping to the real Stories record.
