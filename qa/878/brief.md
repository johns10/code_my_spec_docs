# QA Brief — Story 878: Buying a plan puts the account on it

## Tool

Mixed, per the golden rule (pipeline determines tool):

- **Vibium browser** for the LiveView surfaces: `/pricing` (embedded `CheckoutLive`), `/app/accounts/picker`, `/users/log-in` magic-link flow, `/app` post-payment landing. These are `:browser`-pipeline LiveViews — no curl.
- **curl** for `POST /webhooks/stripe` (`:api` pipeline, confirmed at `router.ex:274`). A signing helper
  (`stripe_webhook_post.sh`, in this session's scratchpad) reads `STRIPE_WEBHOOK_SECRET` from
  `envs/dev.env`, computes the HMAC-SHA256 signature exactly as `StripeWebhookController.verify/3`
  does, and POSTs with a correct `Stripe-Signature` header. Sanity-checked against a well-signed,
  unattributable event → got HTTP 500 as expected (valid signature, undispatchable event), confirming
  the HMAC math is right before it's used for real assertions.
- **curl against the real Stripe API** (`sk_test_…` secret key) for the abandoned-checkout criterion
  (2266) — checking a subscription's `status` stays `incomplete` and is never charged.
- **psql (`code_my_spec_dev`), read-only** for direct account-state verification (`plan`,
  `stripe_customer_id`, `stripe_subscription_id`) without going through app-level writes, and to avoid
  the compile-lock 500 that a `mix run` against the live :4000 dev server would cause.

## Auth

Hosted app, magic-link only (no password form — confirmed live at `/users/log-in`, single email input +
"Email me a login link"). Logged in as `qa@codemyspec.local` via `/dev/mailbox`, rewriting the minted
link's origin from `https://dev.codemyspec.com` to `http://127.0.0.1:4000` before navigating (the local
mailbox is shared across QA sessions; confirmed the message opened was addressed to `qa@codemyspec.local`
and matched the most recent send timestamp before extracting its token).

**Multi-account safety note:** this seed user owns 4 accounts, including "Code My Spec"
(`0f27281c-240b-4d6d-8e52-9c5972329522`), the real dogfooding account, already `plan=paid`. The active
account is a persisted preference (`UserPreferences`), not session-scoped, and it defaulted to "Code My
Spec" on login. Before any checkout/payment interaction, switched the active account via
`/app/accounts/picker` to **QA Second Account** (`d792a72e-ab06-4224-83c9-1faac6b91d34`), confirmed via
read-only psql to start at `plan=free`, `stripe_customer_id=NULL`, `stripe_subscription_id=NULL`. All
browser-driven payment actions in this cycle target QA Second Account only; the real account is never
touched by a mutating action.

## Seeds

No new seeds needed — `qa@codemyspec.local` and its accounts (including QA Second Account) already exist
from prior QA/dev seeding. No fixtures planted under `test/`.

## What To Test

All 12 acceptance criteria on story 878:

- 2260 — pick a tier, pay in place (browser, embedded Payment Element, Stripe test card)
- 2261 — closing the tab after paying still grants the plan (webhook is sole writer; simulate via signed
  `invoice.payment_succeeded` POST regardless of browser tab state)
- 2262 — the page's own "it worked" message does not itself grant the plan (code-level: confirmed
  `handle_event("payment_confirmed", …)` never touches `Billing` or writes any plan field — verify by
  checking DB plan is unchanged immediately after the browser flash, before the webhook lands)
- 2263 — paying for the top tier doesn't land on the cheaper one (assert exact tier from webhook metadata)
- 2264 — a renewal is invisible to the user (webhook-only `invoice.payment_succeeded` on an existing sub,
  no user action, plan/tier unchanged)
- 2265 — cancelling keeps the tier until the paid period ends (`customer.subscription.updated` with
  `cancel_at_period_end: true` does NOT change plan immediately)
- 2266 — abandoning checkout costs nothing (create a subscription intent, never confirm payment, check via
  real Stripe API that it stays `status: incomplete` / uncharged)
- 2267 — new tiers don't disturb existing paid accounts (read-only: confirm the migration adding billing
  columns doesn't touch/backfill `plan`, and that `Code My Spec`'s existing `plan=paid` account is
  untouched by this cycle's actions — verified via psql only, never mutated)
- 2268 — a redelivered webhook doesn't charge/grant twice (dedup via `stripe_events` unique `event_id` —
  POST the same signed event body twice, confirm second is a no-op / not reprocessed)
- 2269 — a webhook not really from Stripe is refused (bad signature → 400)
- 2270 — an expired card doesn't cost the tier while Stripe retries (`invoice.payment_failed` → plan
  unchanged, only logs)
- 2271 — a renewal Stripe gives up on returns the account to free (`customer.subscription.deleted` → plan
  set to `:free`)

## Result Path

Findings filed via `create_issue` (story_id=878) as discovered, ids collected into `issue_ids`. Final
outcome via a single `mcp__plugin_codemyspec_local__submit_qa_result` call — no `result.md` file.

## Setup Notes

- Verified `STRIPE_SECRET_KEY`/`STRIPE_PUBLISHABLE_KEY` in `envs/dev.env` are test-mode
  (`sk_test_…`/`pk_test_…` prefixes) before any Stripe interaction — required gate per team-lead
  instruction, since a live key would place a real charge on a real card.
- Dev app already running on :4000 with billing config loaded from `envs/dev.env` (Dotenvy, not visible
  to `System.get_env` in a shell — confirmed via `config/runtime.exs` grep, not assumed).
- Did not run `mix` or re-seed against the live :4000 server (compile lock would 500 the app under test).
- `stripe_webhook_post.sh` (scratchpad) is a throwaway signing helper, not a repo fixture — nothing
  planted under `lib/` or `test/`.
