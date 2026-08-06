# Stripe — modern subscription billing (the approach we'll use)

Project research for tiered billing (Stripe story, TBD id). Synthesized from the official
docs at `docs.stripe.com` on 2026-06-08. We write our **own thin Req client** (no Stripe SDK),
so this captures the API contract, not a library.

## At a glance
- **Model:** Stripe-hosted **Checkout** in `mode=subscription` (Stripe recommends this for SaaS;
  smallest surface area that still keeps server-side control of customer + metadata).
- **One Stripe Customer (`cus_…`) per account**, stored on the account, `metadata[account_id]` back-link.
- **Webhooks are required** — see "Webhooks are not optional" below. The success redirect is a
  fast-path for UX only, never the source of truth.
- **API version to pin:** `Stripe-Version: 2026-05-27.dahlia` (send on every request).
- **Base URL:** `https://api.stripe.com`. **Auth:** `Authorization: Bearer sk_…`.
  **Encoding:** `application/x-www-form-urlencoded` (Stripe does not take JSON bodies).
- **Idempotency-Key: <uuid>** on every POST.

## Why hosted Checkout (vs Payment Links / raw Subscriptions API)
| Option | Verdict |
| --- | --- |
| **Hosted Checkout** (`POST /v1/checkout/sessions`, `mode=subscription`) | **Use this.** Stripe hosts the PCI form, SCA, payment-method logic; we still set `customer`, `client_reference_id`, `metadata`, `price` server-side. |
| Payment Links | No-code, but hard to attach a deterministic per-account `customer`/`client_reference_id`; weak reconciliation once we have tiers. Skip. |
| Raw Subscriptions API + Payment Element | Max control, but we own SCA + card UI + PCI surface. Overkill. |

Sources: [SaaS subscriptions use case](https://docs.stripe.com/get-started/use-cases/saas-subscriptions) ·
[Build subscriptions with Checkout](https://docs.stripe.com/payments/checkout/build-subscriptions) ·
[Payment Links](https://docs.stripe.com/payment-links)

## The subscription flow
1. **Create/lookup Customer** — `POST /v1/customers` with `email`, `name`, `metadata[account_id]`.
   Store `cus_…` on the account. Reuse it forever (pass `customer=cus_…`, never `customer_email`,
   so Stripe doesn't mint a duplicate).
2. **Create Checkout Session** — `POST /v1/checkout/sessions` (form-encoded):
   ```
   mode=subscription
   line_items[0][price]={{RECURRING_PRICE_ID}}     # one price id per tier
   line_items[0][quantity]=1
   customer={{cus_…}}
   success_url=https://app/billing/success?session_id={CHECKOUT_SESSION_ID}
   cancel_url=https://app/billing/cancel
   client_reference_id={{account_id}}              # ≤200 chars, reconciliation handle
   subscription_data[metadata][account_id]={{account_id}}   # stamps the Subscription too
   ```
   `{CHECKOUT_SESSION_ID}` is a literal placeholder Stripe substitutes on redirect.
   Response: `id`, `url` → redirect the browser to `url`.
3. **Success page** — `GET /v1/checkout/sessions/{id}?expand[]=line_items`. Read `payment_status`
   (`paid`), `subscription`, `customer`. Provision **idempotently** — but treat this as a fast-path,
   not the truth (the webhook is authoritative).

Sources: [Build a subscriptions integration](https://docs.stripe.com/billing/subscriptions/build-subscriptions) ·
[Create a Checkout Session](https://docs.stripe.com/api/checkout/sessions/create) ·
[Fulfill orders](https://docs.stripe.com/checkout/fulfillment)

## Webhooks are not optional
The user's hope to avoid webhooks is **not viable for a correct subscription system.** Stripe states
plainly: *"You can't rely on triggering fulfillment only from your Checkout landing page… You must
use webhooks."* The success redirect misses: tab-closed-after-pay, async payment methods (ACH),
and — critically — **renewals, dunning, cancellations, and period-end downgrades**, which only arrive
as events (especially cancels from the Customer Portal).

**Minimum correct setup = one webhook endpoint** handling:
- `checkout.session.completed` (+ `checkout.session.async_payment_succeeded`) → provision
- `invoice.paid` → renewal succeeded (provision while subscription `status: active`)
- `invoice.payment_failed` → dunning (`past_due`)
- `customer.subscription.updated` → plan/status change (trial→active, downgrade)
- `customer.subscription.deleted` → **revoke access**

Cache the resulting subscription status/tier in **our DB**; gate features by reading our DB, not by
calling Stripe per request. Delivery is **at-least-once and unordered** — dedup by `event.id`, make
every handler idempotent, assume no ordering.

Sources: [Webhooks with subscriptions](https://docs.stripe.com/billing/subscriptions/webhooks) ·
[Fulfill orders](https://docs.stripe.com/checkout/fulfillment) · [Receive events](https://docs.stripe.com/webhooks)

## Signature verification (no SDK)
Header: `Stripe-Signature: t=<ts>,v1=<hex>` (comma-separated, may carry multiple `v1` during
secret rotation; ignore non-`v1` schemes).
1. `signed_payload = "#{t}.#{raw_body}"` — the **raw, pre-JSON-parse** body.
2. `HMAC-SHA256(whsec_signing_secret, signed_payload)`, lowercase hex.
3. Constant-time compare against header `v1`.
4. Reject if `abs(now - t) > 300` (5-min tolerance; never `0`).

Capture the raw body before `Plug.Parsers` consumes it (custom `body_reader`). Implementation +
test recipe in [`elixir-req-client-and-testing.md`](./elixir-req-client-and-testing.md).

Source: [Verify signatures](https://docs.stripe.com/webhooks/signature)

## Self-service: Customer Portal
`POST /v1/billing_portal/sessions` with `customer=cus_…`, `return_url`. Returns `url` → redirect.
Short-lived, mint on demand when the user clicks "Manage billing." Allowed actions (cancel, switch
plan, update card) are governed by a portal **configuration** set once in the Dashboard/API. Portal
changes surface back as `customer.subscription.updated/.deleted` webhooks.

Source: [Integrate the customer portal](https://docs.stripe.com/customer-management/integrate-customer-portal)

## Idempotency, versioning, tax
- **Idempotency-Key: <uuidv4>** on every POST. Stripe replays the first response (success *or* error)
  for 24h. Generate the key once per logical operation so client-level retries reuse it.
- **Pin `Stripe-Version: 2026-05-27.dahlia`** on every request *and* on the webhook endpoint (event
  payload shape = the version at event time). 2025 change to know: `billing_mode` defaults to
  `flexible` for new subscriptions as of `2025-08-27` — fine for us; pass `billing_mode[type]=classic`
  only to keep legacy proration.
- **Stripe Tax** (`automatic_tax[enabled]=true` on the session) — defer for a single-jurisdiction
  launch, but capture customer address + tax ID from day one (`customer_update[address]=auto`) so
  it's a flag-flip later.

Sources: [Idempotent requests](https://docs.stripe.com/api/idempotent_requests) ·
[Versioning](https://docs.stripe.com/api/versioning) · [Tax on subscriptions](https://docs.stripe.com/tax/subscriptions)

## Mapping to our tiers (product shape — refine in Three Amigos)
- Tiers live in **our DB** on the account (a `tier`/`plan` enum + `stripe_customer_id` +
  `stripe_subscription_id` + cached `subscription_status`). Each *paid* tier maps to one Stripe
  **recurring Price id** (config, not hardcoded).
- Free tier has **no** Stripe objects until the user upgrades — it's a local default with entitlement
  limits (1 site, 1 minimal audit, no fixing).
- Entitlements (site count, audit depth, may-execute-fixes) are derived from the account's tier in a
  single `Billing`/entitlements module so every gate reads one source.
