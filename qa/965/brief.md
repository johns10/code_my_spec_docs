# Qa Story Brief

Story 965 — A timeline across the top says where my project is.

## Tool

web

## Auth

The QA user is passwordless; `/users/log-in` offers only GitHub, Google and a
magic link.

1. `http://127.0.0.1:4000/users/log-in` → fill `input[name="user[email]"]` with
   `qa@codemyspec.local` → click "Email me a login link".
2. `http://127.0.0.1:4000/dev/mailbox` → open the newest message **addressed to
   this user**; the mailbox is shared with every other QA session on this box.
3. The link is minted with the configured host
   (`https://dev.codemyspec.com/users/log-in/<token>`). **Rewrite the origin to
   `http://127.0.0.1:4000` before navigating.**
4. Lands on `/app` with the fixture project active. Single-use token.

## Seeds

None beyond the base fixture, and nothing to run. Verify it is present without
`mix run` — the dev server on 4000 holds the compile lock and a `mix run` under
`MIX_ENV=dev` would 500 the app under test:

```
psql -U postgres -h localhost -d code_my_spec_dev -t \
  -c "select email from users where email='qa@codemyspec.local';"
```

Entity: project `QA Fixture Project`, id `11111111-1111-4111-8111-111111111111`.

This story needs no provider, no harness and no agent. The timeline is drawn
from the project's own requirement graph, which every project has.

## What To Test

Base URL `http://127.0.0.1:4000`, project `11111111-1111-4111-8111-111111111111`.

- **It is there without being asked for.** Open `/stories`, `/issues` and
  `/working-copies` on the project. The timeline is on all three, above the
  page's own content — not on a page of its own. *(2929)*
- **One step is current.** Exactly one step carries the current marker; the
  others read as done or not-started. *(2925)*
- **All the story work is one step.** The fixture project has stories; the
  timeline shows a single Building step regardless of how many. *(2924)*
- **The whole graph is on the line.** Fourteen steps — the project's thirteen
  own requirements plus story work — none dropped. *(2940)*
- **One phase expanded, the rest collapsed.** Exactly one phase is expanded and
  every other is collapsed. *(2940)*
- **The detail reads as sentences.** The current step carries about two
  sentences of plain language containing no module name, file path, id or count
  of internals. Read it as a non-technical person would. *(2927)*
- **A step is a way in.** Click a step; it opens the page that answers for it
  rather than dead-ending. *(2928)*
- **Idle still says where it stands.** The fixture project has nothing in
  flight; the timeline must still mark a step rather than going blank. This is
  the one that matters most — a timeline marking nothing is indistinguishable
  from one that failed to load. *(2926)*

Judgement calls this pass owes, beyond what the spex can assert: whether the
phase names and the fourteen sentences actually read as plain language to
somebody who does not know the system, and whether fourteen steps across the top
is legible rather than a build log. Both were written by the agent, not by the
PM, so they are the parts most likely to be wrong.

## Setup Notes

The spex cover the same criteria in-process and are green. That is the contract
layer; this pass is about whether it is right on a real screen, which is where
the density and the wording can only be judged by looking.

## Result Path

`.code_my_spec/qa/965/result.md`
