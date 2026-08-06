# QA Brief — Story 965: My domain is registered and pointed at my app

## Tool

web

## Auth

Magic link as the owner (`johns10@gmail.com`) — provider integrations are
user-scoped and only that account has Cloudflare connected.

    vibium cookies clear
    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "johns10@gmail.com"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

## Seeds

No seed run needed.

- `QA Fixture Project` — `11111111-1111-4111-8111-111111111111`, domain
  `astralbi.com` (owned, so the domain step adopts), environment `uat` with a
  provisioned server.
- **Checking a name writes it onto the project.** For availability probes, create a
  disposable project at `/app/projects/new` and delete it afterwards, or you will
  overwrite the fixture's domain.

`astralbi.com` is live — its apex serves a real site behind Cloudflare
(172.64.80.1). Never let a run point the apex anywhere: keep the project scoped to
subdomain environments only, and note the default `prod` environment maps to the
apex (issue `ae37f523`).

## What To Test

URL: `http://127.0.0.1:4000/app/projects/<id>/provisioning`

Reachable today:

- **An existing domain is an ordinary way in (8052)** — enter `astralbi.com` and
  Check. Expect "astralbi.com (already yours)" and the domain step reaching `done`
  with resource `domain — cloudflare/astralbi.com`, not an error.
- **A retried step does not buy a second domain (7991)** — re-run the domain step;
  exactly one domain resource, project `domain` column unchanged.
- **Sam finds the domain in his own account (7992)** — the zone and the records the
  run creates live in the user's own Cloudflare account.
- **An unsupported extension becomes a dashboard errand (7993)** — check
  `something.gov` or `.museum`. Expect `[data-test="domain-unsupported"]` reading
  "extension is not one the Registrar API can sell", distinct from the
  supported-but-unpriceable wording.
- **Each environment resolves to its own server (7995)** — add a second environment,
  run `server` then `dns`. Each host must resolve to a different IP, each matching
  that environment's own `server_name`. Tear the extra one down afterwards,
  **including its DNS record** (issue `206af045`).
- **The records let the proxy get its certificate (7996)** — the A record must be
  **unproxied**: `dig <env>.astralbi.com @1.1.1.1` returns the Hetzner IP, not a
  Cloudflare 172.64.x address. A proxied record means Cloudflare terminates TLS and
  kamal-proxy can never complete an HTTP-01 challenge.

Not reachable — the Registrar API neither prices nor sells (issue `86fa0dbf`):

- Sam picks a name and sees what it costs (7988)
- A taken domain sends Sam back to choose again (7989)
- Buying takes an explicit yes (7990)
- A missing payment method is named rather than guessed at (7994)

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.

## Setup Notes

**Do not attempt a real purchase.** Registration is not refundable. The API cannot
price a name it does not already hold, so there is no safe way to exercise the
purchase criteria without spending money on a domain nobody wants.

**Clean up every environment you add**, in this order: delete the DNS record first,
then the server. Releasing the IP while the record still points at it is the window
where the takeover in `206af045` is live. There is no UI for either — use
`Cloudflare.delete_dns_record/3` through `mix run` against the owner's scope, and
the Hetzner API for the server.

**`mix run` is safe against the live dev server** (a no-op compile does not
invalidate the lock); `mix test` is not, because the TestAdapter recompiles the dev
environment for static analysis.
