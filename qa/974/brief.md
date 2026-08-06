# QA Brief — Story 974: I can receive mail at my domain

## Tool

web

## Auth

Magic link as the owner (`johns10@gmail.com`) — the Resend and Cloudflare
integrations are user-scoped and only that account has them.

    vibium cookies clear
    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "johns10@gmail.com"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

## Seeds

`QA Fixture Project` — `11111111-1111-4111-8111-111111111111`, domain
`astralbi.com`, `inbound` option enabled.

**This step writes apex MX to a live domain.** Capture the baseline first and
diff it afterwards — that is the whole of criterion 8032 and of the rule that an
existing apex MX must not be silently replaced:

    for t in MX TXT A; do echo "$t: $(dig +short astralbi.com $t @1.1.1.1)"; done
    dig +short uat.astralbi.com A @1.1.1.1

astralbi.com has **no** apex MX at rest, so a clean run is additive. That also
means the "already receiving mail elsewhere" rule cannot be exercised without
first publishing an MX of your own to conflict with.

## What To Test

URL: `http://127.0.0.1:4000/app/projects/<id>/provisioning`

- **A domain that receives no mail today gets its inbound records published** —
  run the inbound step on a domain with no MX. Expect resources
  `receiving_domain — resend/<domain>`, `webhook — https://<domain>/webhooks/resend`,
  `mx_record — cloudflare/<domain>`, and `dig <domain> MX` returning Resend's
  inbound host.
- **Receiving mail does not break sending it (8032)** — diff the zone against the
  baseline. The apex A record and every sending subdomain must be untouched.
  Also read the step's `{:receiving_disabled, name}` pause: it refuses to delete
  and recreate an existing domain because that rotates its DKIM key and would
  break sending until DNS caught up. That refusal *is* this criterion.
- **The inbox is proven by a message, not by configuration (8033)** — the step
  must not reach `done` without a message having been delivered. **Currently
  fails** (issue `717a3df9`): it records three configuration resources and no
  proof.
- **A message to Sam's domain arrives where he reads mail (8030)** — send real
  mail to the domain and observe it arriving. Needs a reachable webhook.
- **The app can act on a message someone sent in (8048)** — the webhook is
  configured as `https://<project domain>/webhooks/resend`, which is the
  customer's own site. On an undeployed project, or one whose apex serves
  something unrelated, Resend posts received mail at a URL that cannot handle it.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.

## Setup Notes

**Tear the apex MX down when you finish.** Before the run, mail to the domain
bounces (no MX). After it, mail is *accepted* by Resend and dropped when the
webhook cannot handle it — silent loss is worse than a bounce. Remove both the
MX record and the Resend receiving domain:

    Cloudflare.delete_dns_record(scope, zone_id, record_id)   # type MX, name = apex
    Resend.delete_domain(scope, domain_id)

then re-run the baseline `dig` and confirm the zone matches exactly.

**Do not run the inbound and email steps against the same domain in one pass.**
969 owns the per-environment sending subdomains, 974 owns the apex. The inbound
step's own label says it — "apex MX, which outbound deliberately does not touch"
— and the knowledge doc warns against deleting apex MX during a provider
migration. There is an open question on the story about whether the two need a
shared apex-record owner rather than two steps writing there.

**`mix run` and `mix test` both recompile and can wedge the running dev server.**
Check `curl -o /dev/null -w '%{http_code}' http://127.0.0.1:4000/users/log-in`
before trusting a strange result.
