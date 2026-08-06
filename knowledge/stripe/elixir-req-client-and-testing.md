# Stripe — custom Req client, webhook plumbing, and test strategy (Elixir)

Companion to [`subscriptions-modern.md`](./subscriptions-modern.md). The *how* for our hand-rolled
client. Patterns proven in the Fuellytics codebase (a Connect/Treasury app — not subscriptions, but
the client/webhook/test scaffolding is directly reusable). We have `{:req, "~> 0.5"}` already.

## Client pattern (one module, plug-injectable)
Fuellytics scattered five near-duplicate mini-clients — **we centralize into one** `GetAiTraffic.Billing.StripeClient`.

```elixir
defp req do
  opts = [
    base_url: "https://api.stripe.com",
    auth: {:bearer, secret_key()},
    headers: [
      {"stripe-version", "2026-05-27.dahlia"}
    ]
  ]

  # Test seam: when configured, route requests through a plug (Req.Test / cassette)
  # instead of the network. Nil in prod.
  case Application.get_env(:get_ai_traffic, __MODULE__, [])[:plug] do
    nil -> Req.new(opts)
    plug -> Req.new(Keyword.put(opts, :plug, plug))
  end
end
```

- **Writes:** `Req.post(req(), url: "/v1/checkout/sessions", form: %{...}, headers: [{"idempotency-key", key}])`.
  Req form-encodes to `x-www-form-urlencoded`. Nested params use **flattened bracket keys**:
  `%{"line_items[0][price]" => price_id, "subscription_data[metadata][account_id]" => id}`.
- **Reads:** `Req.get(req(), url: "/v1/checkout/sessions/#{id}", params: %{"expand[]" => "line_items"})`.
- **Idempotency:** generate `Ecto.UUID.generate()` once per logical operation, pass as the
  `idempotency-key` header on POSTs (NOT on GET/DELETE).
- **Error fidelity (improve on Fuellytics):** Fuellytics collapsed everything to
  `{:error, :processor_error}`, discarding Stripe's `error.code`/`decline_code`. We return
  `{:ok, body}` for 2xx and `{:error, %{status: status, body: body}}` otherwise, so callers can
  distinguish `card_declined` from rate-limit from network.

The `:plug` config key is the single most important pattern — it makes the same client run real HTTP
in prod and deterministic stubs/cassettes in test with zero production cost.

## Webhook plumbing (copy this stack)
1. **Cache the raw body** — a `CacheRawBody` body_reader plug stashes raw bytes in
   `conn.private[:raw_body]` before `Plug.Parsers` JSON-decodes them. Wire it as the endpoint's
   `Plug.Parsers` `:body_reader`, scoped so it only matters for the webhook route.
2. **Controller** verifies `Stripe-Signature` (HMAC-SHA256 over `"#{t}.#{raw_body}"`,
   `Base.encode16(case: :lower)`, `Plug.Crypto.secure_compare/2`, 300s window), then returns **200
   immediately** and enqueues async processing (Oban or a Task) — never block the response on our
   handler work, or Stripe retries.
3. **Dedup gate** — a `stripe_events` table with a unique `event_id`; insert-or-skip *before*
   dispatch (stronger than Fuellytics, which relied on per-handler DB constraints). Handlers stay
   idempotent regardless.

```elixir
# verification core
def verify(raw_body, sig_header, secret, tolerance \\ 300) do
  parts =
    for kv <- String.split(sig_header, ","),
        [k, v] <- [String.split(kv, "=", parts: 2)],
        into: %{},
        do: {k, v}

  with %{"t" => ts, "v1" => v1} <- parts,
       {t, ""} <- Integer.parse(ts),
       true <- abs(System.system_time(:second) - t) <= tolerance,
       expected = :crypto.mac(:hmac, :sha256, secret, "#{ts}.#{raw_body}") |> Base.encode16(case: :lower),
       true <- Plug.Crypto.secure_compare(expected, v1) do
    :ok
  else
    _ -> {:error, :invalid_signature}
  end
end
```

## Test strategy
Three deterministic layers, all hanging off the `:plug` seam — **no network in CI**:

1. **Client unit tests — `Req.Test` stubs.** In `config/test.exs`, set
   `config :get_ai_traffic, GetAiTraffic.Billing.StripeClient, plug: {Req.Test, GetAiTraffic.Billing.StripeClient}`.
   ```elixir
   Req.Test.stub(StripeClient, fn conn ->
     # assert request shape: method, conn.request_path, form body, stripe-version + idempotency-key headers
     Req.Test.json(conn, %{"id" => "cs_test_123", "url" => "https://checkout.stripe.com/c/pay/cs_test_123"})
   end)
   ```
   Also exercise failures with `Req.Test.transport_error(conn, :timeout)` and non-2xx bodies, and use
   `Req.Test.expect/3` to assert a retried op reuses one idempotency key.
2. **Webhook tests — hand-built signatures (no network, no SDK).** Re-implement the signing in the
   test and assert the matrix: valid → 200 + job enqueued; missing/empty/tampered/wrong-secret → 400;
   `t - 301s` → 400 (replay). This mirrors Stripe's scheme exactly and is fully deterministic.
   ```elixir
   defp sign(body, secret, ts) do
     v1 = :crypto.mac(:hmac, :sha256, secret, "#{ts}.#{body}") |> Base.encode16(case: :lower)
     "t=#{ts},v1=#{v1}"
   end
   ```
   Inject a known test `whsec_…` via `Application.put_env` in `setup`, restore in `on_exit`.
3. **BDD spex — same `:plug` seam.** Drive the upgrade LiveView; stub the StripeClient plug to return
   a canned Checkout Session; assert the redirect to `session.url` and (for the webhook path) POST a
   signed `checkout.session.completed` to the webhook route and assert the account's tier flips.
   Optionally record real test-mode responses as fixtures (Fuellytics used `req_cassette`), but a
   plain stub keeps spex hermetic.

**Lifecycle / integration (local, not CI):** Stripe CLI — `stripe listen --forward-to
localhost:4011/webhooks/stripe` (prints a local signing secret) and `stripe trigger
invoice.payment_failed`; **Test Clocks** to fast-forward subscription renewals/dunning deterministically
in a sandbox.

Sources: [Test your Billing integration](https://docs.stripe.com/billing/testing) ·
[Test clocks](https://docs.stripe.com/billing/testing/test-clocks) ·
[Stripe CLI](https://docs.stripe.com/stripe-cli/use-cli)

## Config & secrets
- Env vars: `STRIPE_SECRET_KEY` (`sk_…`), `STRIPE_WEBHOOK_SECRET` (`whsec_…`), and the per-tier
  **Price ids** (`STRIPE_PRICE_BYOK`, `STRIPE_PRICE_FULL`, …). Publishable key only if we ever build
  a custom (non-hosted) form — hosted Checkout doesn't need it server-side.
- Same Varlock-dev / SSM-prod pattern as the existing Anthropic/AWS/Resend secrets
  (see `.env.schema`). **Never commit `sk_live_…`** — Fuellytics did (live keys in `prod.env`); we
  use the encrypted Varlock schema + SSM only.
- `Stripe-Version` is a code constant, not an env var (it pins behavior to what we tested).

## What we copy vs. improve from Fuellytics
- **Copy:** the `Req.new` + `auth: {:bearer}` + `form:` + `:plug`-injection client; the
  `CacheRawBody` + manual HMAC + 300s-window + 200-immediately + async + DB-dedup webhook stack;
  `Req.Test`/cassette test harness.
- **Improve:** one shared client (not five); real error bodies (not `:processor_error`); idempotency
  keys on every POST (they had none); a top-level `event_id` dedup table (they relied on per-handler
  constraints); secrets out of git.
