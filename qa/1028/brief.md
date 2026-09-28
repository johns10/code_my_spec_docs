# Qa Story Brief

Story 966 — I watch my project and talk to its agent on one screen.

## Tool

web

## Auth

Passwordless. There is no password login for the QA user; `/users/log-in` offers
GitHub, Google and a magic link only.

1. `http://127.0.0.1:4000/users/log-in` — fill `input[name="user[email]"]` with
   `qa@codemyspec.local`, click "Email me a login link".
2. `http://127.0.0.1:4000/dev/mailbox` — the local mail adapter catches it. Open
   the newest message.
3. The link is minted with the configured host,
   `https://dev.codemyspec.com/users/log-in/<token>`. **Rewrite the origin to
   `http://127.0.0.1:4000` before navigating.** Following it as-is leaves the app
   under test. This is the step people miss.
4. Lands on `/app` with the fixture project active. The token is single-use — a
   second attempt needs a fresh link.

`/dev/mailbox` is shared across QA sessions. Take the newest message only;
an older one logs you in as somebody else's fixture user.

## Seeds

Already present — do not re-run seeds with the dev server up. `mix run` under
`MIX_ENV=dev` takes the compile lock and 500s the app being tested.

Verify instead, read-only:

```
psql -qtA code_my_spec_dev -c "select email from users where email='qa@codemyspec.local';"
```

Values this session needs:

- Project `QA Fixture Project` — `11111111-1111-4111-8111-111111111111`
- Conversation with an agent — `62d3f01c-68ac-4c36-a7d1-4467a8da25a6`
- Designated main working copy — `d1540d93-f639-448a-9dac-5317665e513f` (rooted, 1 agent)

Target screen:

```
http://127.0.0.1:4000/app/projects/11111111-1111-4111-8111-111111111111/agent-conversation/62d3f01c-68ac-4c36-a7d1-4467a8da25a6
```

## What To Test

Both halves and the header (criteria 2944, 2943):

- Load the target screen at a desktop window size. Both the conversation and the
  panel accordion are present at once, with no navigation between them.
- The timeline header is visible above them. Scroll the conversation to the
  bottom and back up — the header stays put rather than scrolling away.

Layout by width (2945, 2946):

- At a desktop width (≥1024), the conversation is on the **left** and the
  accordion on the **right**.
- Resize to a phone width (≈390). The accordion moves **above** the
  conversation. This is a real reflow driven by the client reporting its width,
  so give the page a moment after the resize.

Panels (2949, 2948, 2947):

- The accordion has exactly **three** tabs: preview, project (the dynamic one),
  activity. Opening and closing them does not change how many there are.
- Open the preview tab on a project with nothing deployed. It says no preview is
  running **and** what would start one — not an empty box.
- Type a message into the composer but do **not** send it. Open a panel. The
  text is still in the box afterwards.

Phone exclusivity (2951, 2952):

- At phone width, open the preview, then open activity. The preview closes —
  only one panel is open at a time.
- At desktop width open two panels, then resize to phone width. Exactly one
  remains open and it is the **preview**.

Attention (2953, 2954):

- With the activity tab closed, have an agent in another working copy ask a
  question. The activity tab header shows an attention mark without the tab
  being opened. Opening it shows the question and which copy asked.
- Ordinary progress must **not** raise that mark. This is the half that keeps it
  worth reading.

## Result Path

`.code_my_spec/qa/966/result.md`

## Setup Notes

The story is the **shell**, not the panels' contents. The preview panel has no
provisioned instance behind it and the dynamic tab renders a placeholder — that
is the designed state for this story, not a defect. Judge the frame: does it
lay out correctly, does it hold state, does it say what it cannot show.

Two of the criteria describe behaviour that differs by viewport. That is not CSS
— the client reports its width to the server, which decides. So a resize is a
round trip, and testing it by inspecting stylesheets proves nothing.

Do not use `mix spex` as evidence here. The suite is green and that establishes
the contract; it does not establish that a person can see this screen.
