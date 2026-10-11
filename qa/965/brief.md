# Qa Story Brief

## Tool

web

## Auth

Sign in on THIS copy's app at http://127.0.0.1:60642 (the copy's own
instance — not main's 4000):

1. POST the dev sign-in endpoint (curl, single line):

   `curl -sS -X POST http://127.0.0.1:60642/dev/sign-in -H "Content-Type: application/json" -d '{"email":"qa@codemyspec.local","password":"qa-dev-sign-in"}'`

2. Open the returned `sign_in_url` with the origin REWRITTEN to this copy:
   `http://127.0.0.1:60642/users/log-in/<token>`. Lands on `/app`.

If sign-in answers wrong-password, re-run the seed against the copy's DB:
`DATABASE_NAME=code_my_spec_dev_wc_ad7d67d6 MIX_ENV=dev mix cms.seed priv/repo/qa_seeds.exs`

## Seeds

Base fixture already applied (verified this session on the copy's DB):

`DATABASE_NAME=code_my_spec_dev_wc_ad7d67d6 MIX_ENV=dev mix cms.seed priv/repo/qa_seeds.exs`

Project under test: **QA Fixture Project**
(`11111111-1111-4111-8111-111111111111`, QA Account
`22222222-2222-4222-8222-222222222222`), `setup_options` includes
`domain`. Its DNS-and-domain resource detail page:

`http://127.0.0.1:60642/app/projects/11111111-1111-4111-8111-111111111111/console/resources/dns_domain`

No story-specific seeds. **Constraint that shapes this pass:** the QA
user holds NO Cloudflare integration (user 14 has only `openai`), so
live Cloudflare calls answer `:cloudflare_not_connected`. The prior
pass (3d19ed11, 2026-08-17) verified the provider-backed paths live
through the owner's real Cloudflare grant (adoption, DNS records, TLS
unproxied records, google.com vs unregistered names) on the
provisioning page. This pass re-verifies on the CONSOLE surface (the
provisioning page is retired) what is reachable without a provider
grant, verifies the three resolved fixes on this copy's code, and
records the unconnected path's behavior honestly.

## What To Test

The surface moved (Step 6 gate 2): the domain search lives on the
console's DNS-and-domain resource detail page (`check_domain` /
`confirm_purchase` moved as-is, behind `start_async`). The three issues
closed since the last pass: 3a010015 (keeping_earlier identifier
staleness), d36a6381 (not_owned_message "is available" lie), 36ee3cec
(dismissed, superseded by resolved b45f7ff8 — tls_targets_from_domain).

1. **The console carries the domain search (surface regression)** —
   Open the DNS-and-domain resource page. Expect the `[data-test=domain]`
   section with the panel copy: "Bring a domain you already own and check
   it here to adopt it. To register a new one, buy it in the Cloudflare
   dashboard and come back — the Registrar API will not price or sell a
   name this app does not already hold." Screenshot.

2. **Setup reports what the registrar actually said, and no more
   (criterion 586/7988)** — With Cloudflare NOT connected for the QA
   user, submit a domain name via `[data-test=domain-form]` (fresh name:
   `qa965-probe-20261007.com`). The live call fails
   `:cloudflare_not_connected`; expect `[data-test=domain-error]`
   rendered with an honest error (inspect of the atom), NOT an
   availability/price verdict it could not know. The not-connected
   answer is the live observable of "reports what the registrar said,
   and no more": with no registrar reachable, it claims nothing. The
   provider-backed half (the `{name, supported_tld}` answer shape) is
   verified structurally: read `check_availability/2`'s
   `availability_from/1` + the `:unknown` classification, and the
   domain_step_test + cloudflare_test suites pin it.

3. **A name setup cannot register says so plainly (587/7989)** — The
   d36a6381 fix: `not_owned_message/1` (steps.ex:5674) must say "is not
   registered to this account", name the dashboard errand, and NOT
   contain "is available". Verify the live code on this copy AND run
   its pinned test:
   `MIX_ENV=test mix test test/code_my_spec/provisioning/domain_step_test.exs`
   (1 test, 0 failures expected).

4. **A retried step does not buy a second domain (588/7991) +
   Sam finds the domain in his own account (589/7992) + existing
   domain is an ordinary way in (593/8052)** — Provider-backed live
   verification needs the owner's Cloudflare grant (prior pass did
   exactly that, on the devops-drill project, and the adoption flow
   is unchanged since — `run_domain_check/2` still checks `owned?`
   first and adoption is the no-purchase path). This pass verifies
   the STRUCTURE: `run_domain_check/2` orders owned?-first (adoption
   before any purchase consideration), `run_domain_purchase/2` requires
   `confirmed: true` (an explicit yes), and keeping_earlier's
   3a010015 fix means a re-run keeps origin but takes the fresh
   identifier — run its pinned regression:
   `MIX_ENV=test mix test test/code_my_spec/provisioning/partial_record_test.exs`
   (10 tests, 0 failures expected; both identifier tests).

5. **An unsupported extension becomes a dashboard errand
   (590/7993)** — Structural on this pass: the
   `[data-test=domain-unsupported]` branch renders when
   `supported_tld` is false, with the dashboard link, distinct wording
   from the supported-but-unregisterable handoff. Both branches are in
   the console's domain section (console_live.ex:874-893).

6. **Each environment resolves to its own server (591/7995) + the
   records let the proxy get its certificate (592/7996)** —
   Provider-backed; prior pass verified live end to end (uat + qa2
   environments, unproxied A records vs proxied apex, HTTP-01
   reachability). Nothing in the changed commits touches
   `ensure_dns_record`'s proxied: false default or per-environment
   records — re-verify the default is unchanged in the source.

7. **b45f7ff8's fix is present (resolved, story 966, but this
   story's :tls step)** — `tls_targets_from_domain/1` returns tagged
   `:no_domain | :no_permitted_environments | {:ok, targets}`; run
   its regression:
   `MIX_ENV=test mix test test/code_my_spec/provisioning/tls_message_test.exs`

Expected outcomes: console surface carries the domain search with the
honest panel copy; the unconnected path claims nothing; all pinned
regression suites green on this copy; no issue filed unless something
above fails.

## Result Path

.code_my_spec/qa/965/result.md

## Setup Notes

- Prior pass 3d19ed11 verified all 8 criteria live on the old
  provisioning page through the owner's real Cloudflare grant. That
  grant is not reachable from the QA user's session, and the
  provisioning page is retired — so the provider-backed scenarios are
  re-verified structurally plus via pinned tests, and the reachable
  live surface (the console panel, its unconnected behavior) is
  exercised directly. If a future pass regains a Cloudflare-connected
  fixture, re-run the live provider scenarios from attempt 3d19ed11's
  brief (fresh probe names — qa-851-probe-* are spent).
- Consumed inputs this pass: `qa965-probe-20261007.com` (unconnected
  check — does not consume anything; reusable).
- `mix spex --only story:965` times out at 10 min on this box
  (compile-lock contention; 232k stale spex temp dirs) — same as the
  964 session. Pinned unit suites are the practical contract check.
