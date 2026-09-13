# Qa Story Brief — Story 1033 (eighth re-run)

The handoff from onboarding to sales to building never breaks the conversation
or the panel beside it.

This is a fresh, full re-run — eighth attempt. Dev server's newest boot line
is `[Boot] serving fc05b0023`, which matches this worktree's current HEAD
(`git log --oneline -1` → `fc05b0023 Merge remote-tracking branch 'origin/main'
into cro`) — so nothing in this story's code has changed since round 7.

Round 7 (attempt `7a059b7e`) passed criteria 3415, 3417, 3418, 3420, 3425,
3431 cleanly and confirmed the round-6 workspace-boot bug
(`Runner.Local.launch/2` PATH resolution, `114843ff`) is fixed — a fresh
Stripe payment boots the workspace end to end for the first time in this
story's QA history. The only remaining gap was **3432**'s second half:
post-boot, `/app/projects/:id/agent-conversation` showed
`data-test="no-provider"` instead of `phx-submit="send_message"`, traced to
`CodeMySpec.Agents.Credential.platform_credential/1` having no
`platform_api_key` configured on this dev box — a deliberate "off unless
configured" cost-control fallback, not a code defect (filed as accepted
low-severity issue `9538be00`).

**This round's purpose:** that gap is now closed. Confirmed at brief-writing
time:
- `config/runtime.exs:446` reads `PLATFORM_API_KEY` into `:platform_api_key`
  (commit `25b5d18f7`).
- `envs/dev.env` now has exactly one `PLATFORM_API_KEY=` line (value not
  printed here; presence confirmed via `grep -c`).
- The running server's boot line is `[Boot] serving fc05b0023` — this is a
  **new process instance** (confirmed via `~/.codemyspec/web.log`), i.e. it
  booted after the key was added, so `platform_credential/1` will read the
  real value, not a stale empty one from before the restart.
- Disk: 30Gi free / 36% used. `docker ps -a`: no containers (this runtime
  path is `Runner.Local` / bare OS processes, not Docker, per round 6's
  finding — disk/Docker theories don't apply here anyway).
- Port 4000 confirmed listening.

This round retries 3432 fresh, end to end, to see whether a real platform
credential now lets a freshly-booted workspace's agent-conversation page
actually show the send-message form.

Also known and already filed (no action needed, cited for context only):
- `542e2311` — the task prompt's/spex's-adjacent selector
  `[data-test='connect-provider-required']` does not exist in the codebase.
  Use `[data-test='no-provider']` instead when checking for its **absence**.
- `9538be00` — the platform_api_key gap itself, now resolved by this round's
  setup (see above). Do not re-open; if 3432 passes this round, note in the
  scenario observation that this issue's fix is confirmed.

## Tool

web (browser via `run_browser_script` Lua sandbox — `mcp__vibium__*` MCP
tools are not connected in this session; the `run_browser_script` tool
documented via `tool_docs` exposes the same underlying vibium browser
control as `browser_*` Lua globals: `browser_navigate`, `browser_fill`,
`browser_click`, `browser_evaluate`, `browser_screenshot`, `browser_frame`,
`browser_wait_for_text`, etc. All URLs target `http://127.0.0.1:4000` per
the QA plan — never `dev.codemyspec.com`, which is the externally-reachable
Cloudflare tunnel.)

## Auth

None needed for the pre-signup surface (`/build`) — it mints an anonymous
`intake_token` session cookie automatically (`Plugs.IntakeSession`).

To reach the post-signup surface, sign up through the guided intake's own
signup card using a fresh unique email
`qa-1033-round8-<unix-timestamp>@codemyspec.local` via the plain
`POST /build/sign-up` form on the signup card — this registers and logs in
directly (`UserAuth.log_in_user/3`), no magic-link/mailbox round trip
needed. Do not reuse any email from rounds 3–7 — each is a spent visitor
(a plan/account that already exists skips the `/build/workspace`
payment-gate path this story covers).

## Seeds

None required. The guided intake creates its own `Intake.Plan` row per
anonymous session; no `qa_seeds.exs` run needed for this story.

## What To Test

- **3415** — Visit `http://127.0.0.1:4000/build` anonymously (no login,
  fresh cookies). Describe a new idea (not reused from any prior round).
  Answer shaping questions until the plan concludes. Confirm
  `[data-test='intake-plan']` is present and rendered from the `Plan` row
  (guessed summary/first_build text), not from a project/account lookup.
  Confirm no signed-in scope exists at this point (check `document.cookie`
  has no session cookie, only the anonymous `intake_token`).
- **3417** — With the plan concluded, edit at least one pushed default
  (account/project name) before submitting the plan-confirmation form, to
  prove the *confirmed* value round-trips rather than the superseded guess.
  Expect a new visitor turn "Call it `<account>` — the project is
  `<project>`." and a following agent turn "Got it — `<account>`'s
  `<project>` it is." to appear in the transcript
  (`[data-test='intake-said']`), positioned after all shaping Q&A turns.
- **3418** — After confirming names, confirm via DOM query that
  `[data-test='intake-plan']` is fully absent (not just hidden) while
  `[data-test='signup-card']` is present. Never observe both at once at any
  stage (initial empty plan, concluded plan, confirmed/signup).
- **3420** — After signing up with the fresh email above, `/build/workspace`
  should show a real Stripe Payment Element (`[data-test='cloud-payment']`)
  with plain purchase language ("$100/month", "Pay to bring your working
  copy up") — assert no "config"/"provisioning options"/"infrastructure
  settings" wording appears anywhere on the page (check full lower-cased
  body text via `browser_evaluate`, not just the payment card).
- **3425** — Confirm `[data-test='conversation-panels']` renders on `/build`
  (pre-signup). Then confirm it also renders on `/build/workspace`
  specifically while `awaiting_payment` (before completing the Stripe
  Payment Element).
- **3431** — After signup, confirm `/build/workspace` contains no
  "handoff"/"relocat"/"switching agents"/"new agent" wording (full
  lower-cased body text). Confirm the full pre-signup transcript survives
  onto this page in chronological order: original description → every
  shaping Q&A turn → the name-confirmation turn pair → (once the interview
  starts) the interview's own first question, in that order. Confirm no
  second `phx-submit="describe"` composer appears.
- **3432 (primary focus this round)** — Complete the Stripe test-mode
  payment (`4242 4242 4242 4242`, any future expiry, any CVC, US ZIP) on
  `/build/workspace` using the fresh visitor from this round. Confirm the
  workspace boots successfully (progress through "Fetching dependencies" →
  "Setting up the database" → running, per round 7's confirmed-fixed path;
  if it fails, this would be a NEW regression — round 7 confirmed the boot
  bug fixed, so don't assume the old disk/PATH causes apply without fresh
  evidence). Then visit `/app/projects/:id/agent-conversation` for the
  newly created project and confirm `phx-submit="send_message"` **is
  present** and `[data-test='no-provider']` **is absent** (this is the
  correct selector — see `542e2311`; do not check for the nonexistent
  `[data-test='connect-provider-required']`).

  This is the headline result this round is built to establish. If the
  platform credential now works, sending an actual test message and
  observing a real agent response is the strongest possible verification —
  attempt it if there's room in the run. Confirming the send_message form's
  presence and no-provider's absence is sufficient for a pass on this
  criterion otherwise.

  **If it still shows `no-provider`:** check `~/.codemyspec/web.log` around
  the failure for what `platform_credential/1` actually returned (or grep
  for `not_connected` near the timestamp) before concluding the config fix
  didn't take — confirm the server serving the request is the same
  `fc05b0023` instance from this brief's setup check (a harness/server
  restart mid-run is a known shared-box hazard per the task prompt).

## Result Path

Findings are filed via `create_issue` as discovered (not a result.md — see
issue ids on the submitted `qa_complete` attempt for story 1033). Screenshots
are saved to `.code_my_spec/qa/1033/screenshots/` with a `r8_` prefix to
distinguish them from prior attempts' evidence already in that directory.

## Setup Notes

- The composer's `<textarea>` and the plan-confirmation form's inputs are
  both inside `div > form > button` trees with similar shape; prefer
  `browser_evaluate` to set `.value` + dispatch a real `input` `Event` then
  `.click()` the target button directly, when ref/selector-based commands
  don't visibly change page state (necessary in prior attempts).
- The shaping conversation calls a real LLM (no fakes/cassettes on this dev
  box for this flow) — expect a few real seconds of "Thinking…" per turn.
- Stripe keys on this dev box are test-mode (`sk_test_…`) — safe to attempt
  real Payment Element interaction with the standard `4242...` test card.
- Working technique for the Payment Element iframe (confirmed rounds 3–7):
  `browser_frame` to switch into the `elements-inner-payment` iframe →
  `browser_fill` on `#payment-numberInput` / `#payment-expiryInput` /
  `#payment-cvcInput` / `browser_select` on `#payment-countryInput` /
  `#payment-postalCodeInput` (all work directly by id selector) → switch
  back to the top-level page (required, or subsequent commands silently
  keep operating against the stale iframe context) → `browser_click` on
  `#payment-submit` (now targets the real page).
- If tools stop answering mid-run (dev server or harness restart under you
  — shared box), retry per the task prompt's guidance; if truly unable to
  continue, submit what's gathered with the interruption named as the
  reason and file it as its own finding.
