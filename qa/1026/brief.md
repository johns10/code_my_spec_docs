# Qa Story Brief

Story 964 — I approve an epic and it gets built somewhere else.

## Tool

web

## Auth

The QA user is passwordless; `/users/log-in` offers only GitHub, Google and a
magic link.

1. `http://127.0.0.1:4000/users/log-in` → fill `input[name="user[email]"]` with
   `qa@codemyspec.local` → click "Email me a login link".
2. `http://127.0.0.1:4000/dev/mailbox` → open the newest message **addressed to
   this user**; the mailbox is shared with every other QA session on this box,
   and it is cleared by a server restart.
3. The link is minted with the configured host
   (`https://dev.codemyspec.com/users/log-in/<token>`). **Rewrite the origin to
   `http://127.0.0.1:4000` before navigating.**
4. Lands on `/app` with the fixture project active. Single-use token.

Fill the email only after LiveView has connected — the input is `readonly` until
it does, and the fill fails silently enough to look like a wrong selector.

## Seeds

Base fixture only. Verify without `mix run` — the dev server holds the compile
lock and a `mix run` under `MIX_ENV=dev` would 500 the app under test:

```
psql -U postgres -h localhost -d code_my_spec_dev -t \
  -c "select email from users where email='qa@codemyspec.local';"
```

Entity: project `QA Fixture Project`, id `11111111-1111-4111-8111-111111111111`.

This story needs no provider and no running agent. Everything under test is the
epic's own life and the screen that shows it.

## What To Test

Base URL `http://127.0.0.1:4000`, epics at
`/app/projects/11111111-1111-4111-8111-111111111111/epics`.

- **A draft epic offers nothing to approve.** Create an epic on the page. It
  reads as draft and carries no "Build this" control — work cannot start on
  something the agent has not put forward. *(2932)*
- **A proposed epic offers approval, and only then.** Nothing in the UI proposes
  yet; use the agent surface to move it (`EpicDispatch.propose/2` via an agent,
  or check an already-proposed epic if one exists). The control appears. *(2942)*
- **Agreeing dispatches it.** Click "Build this". The epic reads as dispatched
  and names where the work is happening. You were never asked to choose a
  checkout. *(2930)*
- **Ignoring a proposal changes nothing.** Leave a proposed epic alone, reload:
  still proposed, no working copy, no agent running on the working copies page.
  *(2931)*
- **The screen changes while you watch it.** With the epics page open in one
  tab, have the agent propose an epic. It should appear **without reloading**.
  This is the one that needs two windows and is the reason the story exists in
  this shape. *(2942)*
- **A dispatched epic that failed says so.** Not reachable from the UI — check
  the rendered state if one exists; otherwise record as not covered. *(2939)*
- **The graph node reports why.** `/requirements` → find `work_dispatched`. On
  the fixture project it should be satisfied, and the row should say *why* —
  "nothing left to hand out" versus "work is underway" are different sentences
  and the distinction is the point. *(2933, 2934)*

Judgement this pass owes, beyond what the spex assert: whether "Build this"
reads as the irreversible act it is to somebody non-technical, and whether a
dispatched epic that names a rootless default copy ("waiting for a checkout")
reads as sensible rather than broken.

## Setup Notes

The twelve spex cover the same criteria in-process and are green. That is the
contract layer. This pass is about whether the screen is right, and in
particular whether the live update actually happens in a real browser — the spex
proves the LiveView receives the broadcast, not that a person sees it land.

Known limitation: nothing in the UI *proposes* an epic yet. Proposing is the
main agent's act and the main agent needs a provider, which the QA account does
not have (see issue 4345609b). Criteria that need a proposed epic have to reach
`EpicDispatch.propose/2` another way or be recorded as not covered.

## Result Path

`.code_my_spec/qa/964/result.md`
