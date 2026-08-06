# Qa Story Brief

Story 990 — Guided intake takes a visitor from an idea to a running app. The
flow a stranger walks: describe an idea at `/build`, answer two shaping
questions, read the plan, correct the names, go through the gate, and land on
`/build/workspace` while their instance comes up behind the story interview.

The interesting half of this story is anonymous, so most of it must be tested
**without logging in at all** — a session that starts authenticated cannot see
the thing being claimed.

## Tool

web — the `vibium` CLI (the `mcp__vibium__*` MCP server is disconnected this
session; drive it from Bash: `vibium go/fill/click/eval/screenshot -o f.png`).

`curl` is sufficient for the unauthenticated GET checks (`/build` reachable
without a session, no redirect to log-in).

## Auth

**Most criteria need NO auth.** Criteria 8209–8211, 8214, 8215 are anonymous by
definition — do not log in for them, and use a fresh browser profile so no
cookie leaks in from an earlier scenario.

For the post-gate criteria (8212, 8213, 8216, 8217, 8218), log in on port 4000
via magic link, per the QA plan:

1. `vibium go http://127.0.0.1:4000/users/log-in`
2. Fill the magic-link form: `form[action="/users/log-in/magic"] input[name='user[email]']`
   (both forms share input names — scope to the form, per plan.md:98)
3. Click "Log in with email"
4. Read the token from the swoosh mailbox at `http://127.0.0.1:4000/dev/mailbox`
5. Visit `/users/log-in/:token`

To prove "a different browser" (8215) use a separate vibium profile or clear
cookies — not a new tab, which shares the session cookie.

## Seeds

None required. Guided intake creates its own account and project from the plan
— that is the behaviour under test, and pre-seeding one would mask it.

For 8213 (a name someone else already uses) an account named `Acme` must exist
first. Create it through the surface: log in, go to `/app`, create an account
named `Acme`, then run the intake flow and confirm the same name.

For 8216 (existing customer) the logged-in user must already have a project
before walking the flow, so `/app` shows one project before and two after.

## What To Test

- **8209** — `GET /build` anonymously (expect 200, no redirect to `/users/log-in`).
  Describe "a booking tool for hair salons", answer the two questions, confirm a
  plan comes back naming what they described. No password or email field appears
  anywhere before the plan.
- **8210** — On the questions step, read the two questions verbatim. They must ask
  about *signing in* and *separate businesses each using their own copy*. Fail if
  the words "multi-tenant", "tenancy" or "authentication" appear.
- **8211** — On the plan step, confirm it states its sign-in and separate-copies
  conclusions in prose, and that the proposed account and project names are
  **editable inputs**, not static text.
- **8212** — Change both proposed names (to `Acme` / `Widget Tracker`), go through
  the gate, then check `/app` shows `Widget Tracker`. The proposed names must
  appear nowhere.
- **8213** — With an account named `Acme` already existing, confirm `Acme` again.
  Expect no "already taken" message and no second chance to pick a name — the
  flow moves on to the gate.
- **8214** — Reach the plan, close the tab, reopen `http://127.0.0.1:4000/build`
  in the same profile. The plan is waiting with the same answers.
- **8215** — Reach the plan, then open `/build` in a *different profile*. Expect
  the "What do you want to build?" first step, and no error / expired / not-found
  language.
- **8216** — As a user who already has a project, walk the whole flow. `/app`
  must show the new project **and** the old one.
- **8217** — After the gate, `/build/workspace` shows the boot progressing with a
  phase label that changes (this boots a **real devbox container** — expect
  minutes, and `docker ps` should show `cms-workspace-*`). When it comes up,
  "Open your application" appears and the link answers.
- **8218** — Force a failure (e.g. `docker rm -f` the container mid-boot). Expect
  the screen to say it did not come up, "Your plan is safe", and a "Try again"
  button — never an indefinite spinner. `/app` still shows the project.
- **8219–8221 (interview)** — The interview body is a known placeholder pending
  `req_llm` wiring. Confirm only the layout claim: the interview area is the
  page's focus and the boot is a status strip beside it, not the whole page.
  Do not pass the interview criteria themselves.

## Result Path

`.code_my_spec/qa/990/result.md`

## Setup Notes

- Port 4000 is `CodeMySpecWeb.Endpoint` (hosted). It is **not** running by
  default this session — start it with `mix phx.server` and wait for 200 on
  `/` before testing; it returns 503 while assets build.
- The workspace runner shells out to the **real Docker daemon** in dev. The
  `codemyspec/devbox:latest` image is present. Boot runs `deps.get`,
  `ecto.create` and a cold compile before the app answers, so 8217 is a
  minutes-long wait by design — that slowness is the subject of an open
  product question, not a defect to file.
- Clean up any `cms-workspace-*` containers left behind after testing.
