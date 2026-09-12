# Qa Story Brief

Story 1030 / spex bundle 1064 — "The main agent onboards me". The surface is
the guided intake funnel at `/build` (`CodeMySpecWeb.IntakeLive.Plan`) and
`/build/workspace` (`CodeMySpecWeb.IntakeLive.Workspace`) on the hosted
endpoint, port 4000. The "Linked component" the task prompt names
(`CodeMySpec.MainAgent`) is a different, unrelated context (agent restarts /
questions / cadence) — ignore it for this story; the real implementation is
`CodeMySpec.Intake` + `IntakeLive.*`.

## Tool

web

## Auth

Two identities are needed: anonymous (no login) and authenticated-with-a-fresh-plan.
Do **not** use the shared `/dev/mailbox` or the `qa@codemyspec.local` fixture user for
this story — use the dedicated dev routes built to avoid exactly that contention
(`lib/code_my_spec_web/controllers/dev_sign_in_controller.ex`):

```
curl -sS -X POST http://127.0.0.1:4000/dev/sign-up \
  -H "Content-Type: application/json" \
  -d '{"email":"qa-1030-<unique-suffix>@example.com"}'
```

Returns `{"email":..., "user_id":..., "sign_in_url": "http://.../users/log-in/<token>"}`.
**Rewrite the URL's origin to `http://127.0.0.1:4000`** before navigating — the
endpoint's configured `:url` points at the tunnelled `dev.codemyspec.com`
hostname (same caveat as the qa_seeds magic link in `.code_my_spec/qa/plan.md`).
Navigating the browser to the rewritten URL redeems the token through the real
`/users/log-in/:token` controller — the same code path a real magic-link click
hits — so this is real session auth, not a bypass.

**The plan token never expires and is one-per-cookie, and login/logout
deliberately carries it across** (`UserAuthWeb.renew_session/2` restores
`_code_my_spec_key`'s intake key across every renewal, on purpose, so a visitor
who signs up on one page doesn't lose the plan they were on). That means:

- Reusing the same browser cookie for two "fresh visitor" scenarios in a row
  hands the second one the first one's already-converted plan, not a blank one.
- Before minting a new identity for a scenario that needs a **blank** plan,
  clear this app's session cookie by name (not a blanket cookie wipe — the
  browser may be shared with other concurrent QA agents):

  ```lua
  browser_delete_cookies({ name = "_code_my_spec_key" })
  ```

- Do this once before the anonymous scenarios' first navigation, and again
  before each authenticated scenario's `/dev/sign-up` + redeem, per the
  sequencing in "What To Test" below.

No login is needed at all for the anonymous scenarios (3370, 3371, 3378, 3369)
until the moment 3369 itself signs up.

## Seeds

None. This story is about first-run visitors and freshly-minted accounts, not
the `qa_seeds.exs` fixture project — every scenario below mints its own
throwaway account via `/dev/sign-up`. Just confirm the app is already up:

```
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:4000/
```

(Port 4000 is the hosted dev endpoint; do not start a second `mix phx.server` —
see `.code_my_spec/qa/plan.md`'s port table.)

## What To Test

Run in this order — it's built so each group leaves the plan token in the
right state for the next, and only crosses a "clear the cookie" boundary where
a scenario genuinely needs a blank plan.

**Group 1 — one anonymous visitor, uninterrupted (criteria 3370, 3371, 3378):**

1. `browser_delete_cookies({ name = "_code_my_spec_key" })`, then navigate to
   `http://127.0.0.1:4000/build` on a clean cookie.
2. **3370 — Arriving means arriving in a conversation.** Before typing
   anything: assert `[data-test='intake-transcript']` exists, assert
   `[data-test='intake-said'][data-from='agent']` exists (the agent has
   already spoken), and assert the page text does **not** contain "Sign up".
3. **3371 — The paperwork sits beside the talking.** Submit the composer
   (`form[phx-submit='describe']`, textarea `description`) with something like
   "a booking tool for a two-chair barbershop". Answer whatever shaping
   question(s) appear via `form[phx-submit='answer']` (textarea `answer`) until
   none remain. Assert `[data-test='intake-plan'] form[phx-submit='confirm_names']`
   is now present *beside* `[data-test='intake-transcript']` (both present, not
   one replacing the other), and assert the URL is still `/build` (no
   navigation happened just from answering).
4. **3378 — Talking before signing up costs the visitor nothing.** On that
   same rendered page (still anonymous, plan not yet confirmed), lowercase the
   HTML and assert none of "api key", "api_key", "anthropic key", "openai key",
   "model key", "byok" appear, and none of "sign up to continue", "create an
   account to continue", "log in to continue" appear. (The transcript element
   from step 2 is your anchor that the page isn't just empty.)

**Group 2 — a second anonymous visitor, interrupted by signup (criterion 3369):**

5. `browser_delete_cookies({ name = "_code_my_spec_key" })`, navigate to
   `/build` fresh. Submit only the description (`form[phx-submit='describe']`)
   — do **not** answer the shaping question yet.
6. Sign up mid-conversation using the dev route: `curl -X POST
   http://127.0.0.1:4000/dev/sign-up -d '{"email":"qa-1030-signup@example.com"}'`
   (JSON body, `Content-Type: application/json`), take the `sign_in_url`,
   rewrite its origin to `127.0.0.1:4000`, and navigate the browser there.
7. Then navigate to `/build` again. Assert the page still contains the
   description text you submitted in step 5, and assert
   `[data-test='intake-composer'][phx-submit='describe']` is **absent** (the
   conversation moved on rather than re-asking).

**Group 3 — a fresh signed-in visitor per scenario (criteria 3374, 3372, 3376, 3377):**

For each of the four scenarios below: `browser_delete_cookies({ name =
"_code_my_spec_key" })`, `POST /dev/sign-up` with a new unique email, redeem
the rewritten `sign_in_url`, **then** navigate to `/build` — this mints a
brand-new plan with zero turns because there was no intake cookie for the
renewal to carry across.

8. **3374 — Somebody who would rather type than talk.** Immediately on
   arrival (before submitting anything), assert `form[phx-submit='confirm_names']`
   is already present and assert `[data-test='intake-said'][data-from='visitor']`
   is **absent** (nothing typed yet). Fill the plan form directly — account
   name, project name, both selects, `location: local` — and submit. Assert
   you land somewhere other than `/build` (`push_navigate` fired), then on that
   destination assert `[data-test='local-instructions']` is present.

9. **3372 — The agent fills in what it understood.** Fresh identity again.
   Describe an idea, answer the shaping question(s). On the resulting page,
   assert `input[name='plan[account_name]']` and `input[name='plan[project_name]']`
   both have non-empty `value` attributes, and assert **no** input under
   `[data-test='intake-plan']` carries `disabled` or `readonly`.

10. **3376 — Onboarding ends somewhere.** Fresh identity. Describe an idea,
    answer the shaping question(s), then submit the confirm form with
    `location: local` (leave names as the agent's guesses). Assert the
    resulting page/URL is not `/build`, assert `[data-test='local-instructions']`
    is present there, assert `[data-test='intake-transcript']` is present (the
    conversation came with you), and assert `form[phx-submit='answer']` is
    present (the agent is asking the post-signup interview question).

11. **3377 — A correction reaches the agent.** Fresh identity. Describe an
    idea, answer the shaping question(s), read what the agent guessed for
    `project_name`, then submit confirm with a **different** `project_name`
    (e.g. `"BarberBook"` — check first that the agent didn't already guess
    that exact string) and `location: local`. On the destination page, assert
    the corrected name appears (the local-run instructions are built from
    `plan.project_name`, so `mix cms.new BarberBook` should be visible in
    `[data-test='local-instructions']`), not whatever the agent originally
    guessed.

**Criterion 3375 — The agent cannot be reached — flag as likely unexercisable live, don't force it:**

There is no lever on the running dev app to make the real shaper/model
unreachable without swapping `Application.get_env(:code_my_spec, Intake)[:shaper]`,
which would break shaping for every other visitor and agent using this shared
dev box for as long as it's swapped — not something to do against a live
shared instance. This mirrors the "GenServer/process internals — no QA surface
here" and "external system state with no surface that produces it" cases
already called out in `.code_my_spec/qa/plan.md` and in the criterion's own
spex moduledoc.

What **is** verifiable live, and worth doing as a substitute: confirm (via the
Group 3 scenarios above) that the plan card and `confirm_names` form render
unconditionally on every `/build` visit regardless of conversation progress —
i.e. the two things this criterion needs both already showed up working in
scenario 8 alone (form present with zero turns) and nothing in the template
gates the form on `trouble`/shaping status (`lib/code_my_spec_web/live/intake_live/plan.ex`
has no `:if` on `plan_card` at all). Record 3375 as partial/source-verified
rather than forcing a live repro, and say why.

## Result Path

.code_my_spec/qa/1030/result.md
