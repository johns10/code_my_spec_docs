# Qa Story Brief

## Tool

web

## Auth

Sign in on THIS copy's app at http://127.0.0.1:60642 (the copy's own
instance serving 3edb3f8a, not main's 4000):

1. POST the dev sign-in endpoint (curl, single line):

   `curl -sS -X POST http://127.0.0.1:60642/dev/sign-in -H "Content-Type: application/json" -d '{"email":"qa@codemyspec.local","password":"qa-dev-sign-in"}'`

   It answers `{"email":"qa@codemyspec.local","user_id":14,"sign_in_url":"https://dev.codemyspec.com/users/log-in/<token>"}`.

2. Open `sign_in_url` in the MCP browser with the origin REWRITTEN to this
   copy's host:port — `http://127.0.0.1:60642/users/log-in/<token>` — never
   `https://dev.codemyspec.com` and never main's 4000. It lands on `/app`.

The token is single-use; a fresh POST mints a fresh one. NEVER the login
form (`/users/log-in` page): it is magic-link only, no password field.

If sign-in answers `{"error":"no user with that email and password"}`, the
copy's cloned database (name `code_my_spec_dev_wc_<sha8-of-root>`, derived
per `AppInstance.database_name/1`) holds a stale password hash — a clone
does not track later password changes on main. Re-run the seed against the
copy's own database (single line):

`DATABASE_NAME=code_my_spec_dev_wc_ad7d67d6 MIX_ENV=dev mix cms.seed priv/repo/qa_seeds.exs`

(`mix cms.seed` boots no endpoint, so it cannot collide with the running
instance's port.) Then retry the POST.

## Seeds

Already applied for this run (idempotent, safe to re-run):

`DATABASE_NAME=code_my_spec_dev_wc_ad7d67d6 MIX_ENV=dev mix cms.seed priv/repo/qa_seeds.exs`

Outputs: user `qa@codemyspec.local` (id 14), account slug `qa-account`
(id `22222222-2222-4222-8222-222222222222`), project `QA Fixture Project`
(id `11111111-1111-4111-8111-111111111111`), story id 1
("QA: Three Amigos UI smoke"). Health check first:
`curl -sS http://127.0.0.1:60642/health` — `pending_migrations` must be
`[]` (verified: `[]` at run start).

No story-specific seeds beyond the base fixture: story 1075's subject is
the harness's working-copy app lifecycle itself, which this run exercises
against the real copy (root
`/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/agent-conversation-ui`,
database `code_my_spec_dev_wc_ad7d67d6`, app port 60642), not the fixture
project's data.

## What To Test

The fixed issue on this pass is **c1d6b0b4** (resolved at 3edb3f8a6): the
operating rules now tell the sanctioned `restart_app` tool apart from the
forbidden by-hand recipe, inside the by-hand rule. Everything else was
already green on the prior pass (attempt f72b9e55, coder-restart scenario
verified on this same copy). This pass re-verifies the fix on the copy's
own code and samples the story's live surfaces.

1. **QA sees the copy's own code (criterion 1523)** —
   `ensure_app_running` via `run_script` reports THIS copy serving
   `3edb3f8a6a110abf...` at `http://127.0.0.1:60642`, and names the
   copy's own HEAD (`9160ad8...`) separately when the two diverge. Compare
   with `/health` (`"version":"2.0.387+7.g3edb3f8a6"`). PASS if the
   reported commit equals the copy's app commit, and the app URL is this
   copy's port, never main's 4000.

2. **The fixed wording (c1d6b0b4)** — read
   `lib/code_my_spec/agents/operating_rules.ex` served by the copy's own
   checkout: the by-hand rule must name `restart_app` as the sanctioned
   path, name "running the recipe yourself" as what is forbidden, and the
   distinction must sit INSIDE the by-hand rule (before the
   `origin/main` sentence), not appended after it. Verify the pinned test
   `the sanctioned restart tool is told apart from the by-hand recipe`
   exists in `test/code_my_spec/agents/operating_rules_test.exs` and the
   byte cap: `MIX_ENV=test mix run` printing
   `byte_size(OperatingRules.text())` must stay under 4000 (measured
   3914). Run the test file: 13 tests, 0 failures expected.

3. **QA starting brings the app up (criterion 1533)** — the start_task
   prompt for this session itself named this copy's own app URL
   (`http://127.0.0.1:60642`), not main's — that is the criterion's
   direct assertion, already evidenced by the prompt text this brief is
   answering. PASS on prompt evidence + live 200s from the copy.

4. **A stopped copy says so (criterion 1538) / stale app not current
   (1537)** — `ensure_app_running` reports the running commit and HEAD
   divergence honestly (the HEAD note in the tool's reply: "the app is
   not restarted when HEAD moves, only on a promote"). And
   `stop_app` then `ensure_app_running` on this copy reports stopped /
   brings it back, and the browser serves the copy again after. (Do this
   LAST so the app is up for scenarios that need it.)

5. **The app is current (criterion 1536)** — after `ensure_app_running`,
   browser-navigate `/app` and `/health`: both answer on 60642 with the
   copy's version string; screenshot both.

6. **Two copies at once (criterion 1524, sampled live)** — main's app
   (port 4000) and this copy's (60642) both answer simultaneously:
   `curl -sS http://127.0.0.1:4000/health` and
   `curl -sS http://127.0.0.1:60642/health` both 200 with different
   version strings (main's carries main's commit, copy's carries
   `3edb3f8a6`). This is the live sampling; the port/database
   non-collision itself is asserted by the spex.

Browser scenarios (MCP browser, `:browser` pipeline):
- `/app` renders Overview with the fixture project visible.
- Screenshot each key state to `.code_my_spec/qa/1075/screenshots/`
  (via browser_screenshot with basename, then copy into the story dir).

Expected outcomes: every scenario passes with the copy's own commit
reported; no page served from main's port; the rules wording distinction
present and pinned; the byte cap unbroken.

## Result Path

.code_my_spec/qa/1075/result.md

## Setup Notes

- This copy's own instance: `http://127.0.0.1:60642`, serving
  `3edb3f8a6a110abf1dff7918747ec86532ef5453` (copy HEAD is `9160ad8...`,
  ahead; the app is not restarted when HEAD moves, only on a promote —
  by design, per criterion 1537's revision).
- Main's app on 4000 stays untouched by this run: no stop, no restart,
  no seed against main's database. The only database touched is this
  copy's own clone.
- Restarting THIS copy through `restart_app` is the sanctioned path
  (that is exactly what the fixed rule says); running the recipe by
  hand and concurrent restarts remain forbidden.
- `git status` in the copy shows a modified `.code_my_spec` submodule
  pointer only — the harness's own state dir, expected.
- Attempt history: f72b9e55 (prior pass on this story, verified the
  coder-restart scenario and this fix). No QA-attempt-blocking issues
  open on story 1075 at run start.
