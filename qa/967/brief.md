# Qa Story Brief

Story 967 — The agent steers what I am looking at.

## Tool

web

## Auth

Passwordless. `/users/log-in` offers GitHub, Google and a magic link only.

1. `http://127.0.0.1:4000/users/log-in` — fill `input[name="user[email]"]` with
   `qa@codemyspec.local`, submit `#login_form_magic button`.
2. `curl -s -L http://127.0.0.1:4000/dev/mailbox` and take the newest
   `https://dev.codemyspec.com/users/log-in/<token>`.
3. **Rewrite the origin to `http://127.0.0.1:4000` before navigating.** Following
   it as minted leaves the app under test. This is the step people miss.
4. Lands on `/app`. Single-use token — a second attempt needs a fresh link.

The session does not survive a `just refresh`; the server restart drops it. If
a page suddenly renders the login form, log in again rather than diagnosing the
feature.

## Seeds

Already present. Do not run seeds with the dev server up — `mix run` under
`MIX_ENV=dev` takes the compile lock and 500s the app being tested.

- Project `QA Fixture Project` — `11111111-1111-4111-8111-111111111111`
- Conversation with a running agent — `62d3f01c-68ac-4c36-a7d1-4467a8da25a6`
- The project has 25 stories, so the dynamic tab has real content to show.

Target screen:

```
http://127.0.0.1:4000/app/projects/11111111-1111-4111-8111-111111111111/agent-conversation/62d3f01c-68ac-4c36-a7d1-4467a8da25a6
```

The agent's side of this story has no caller yet — nothing in the product calls
`ScreenState.show/2`. Drive it the way the agent will, from `iex` against the
running node, or accept that the two agent-steering criteria are unreachable
from the browser alone and say so rather than passing them.

## What To Test

Remembering (2955):

- Open the screen, open the dynamic tab, and leave it showing a single story.
- Navigate away and come back. The dynamic tab is open on that same story —
  not shut, and not reset to the list.
- Reload rather than only re-navigating. The claim is that it is written down,
  and a value held in the socket survives a navigation but not a reload.

Steering (2956, 2957):

- With the screen open on a desk width, have the agent point the dynamic tab at
  a story. It appears without any interaction.
- The preview stays open. Nothing had to close to make room, which is the whole
  reason this applies on a desk.

Offering (2958):

- At 390px with the preview open, have the agent point the dynamic tab at a
  story. The preview must still be the open panel.
- The dynamic tab shows a mark saying it has something.
- Tapping it shows the story the agent chose, and the mark clears.

Isolation (2959):

- Leave one project's dynamic tab on one of its stories.
- Open a different project's agent conversation. It must not be showing the
  first project's story.
- Go back. The first project's screen is as it was left.

Survival (2960):

- Leave the dynamic tab showing a story, delete that story, reload.
- The page still renders — conversation and composer both present.
- The dynamic tab says the story is gone or falls back to the list. A crash
  here takes the conversation with it, which is why this one matters most.

## Result Path

`.code_my_spec/qa/967/result.md`

## Setup Notes

This story is state and steering, not layout. 966 owns the shell and is already
QA'd; do not re-test tabs, breakpoints or the attention mark here.

Two criteria describe behaviour that differs by screen width. That is not CSS —
the client reports its width and the server decides — so a resize is a round
trip. Give the page a moment after resizing, and read `data-layout` on
`[data-test="conversation-layout"]` to confirm which mode is actually in play
before judging what you see.

Known and not a defect: the preview panel says nothing is running. Story 968
covers giving it an address; the panel's empty state is correct until then.
