# QA Brief — Story 969: My app sends mail from my own domain

## Tool

web

## Auth

Magic link as the owner (`johns10@gmail.com`) — the Resend integration is
user-scoped and only that account has it connected.

    vibium cookies clear
    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "johns10@gmail.com"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

## Seeds

`QA Fixture Project` — `11111111-1111-4111-8111-111111111111`, domain
`astralbi.com`, environment `uat`, `email` option enabled.

**Capture the zone's DNS before you run anything** — 8029 is about not
destroying what was there, and you cannot show that without a baseline:

    for t in MX TXT A; do echo "$t: $(dig +short astralbi.com $t @1.1.1.1)"; done

**The Resend account holds real production domains** — `codemyspec.com`,
`uat.codemyspec.com`, `broken-oaths.com`, `fuellytics.app` and others, all
verified. The step only ever touches `<environment>.<project domain>`, but list
before and after and confirm the count is unchanged.

List and tear down through the app's own integration (the token in `envs/.env`
is not the one the app uses):

    Resend.list_domains(scope)  /  Resend.delete_domain(scope, id)

with a scope carrying `user`, `active_project_id` and `active_account_id`.

## What To Test

URL: `http://127.0.0.1:4000/app/projects/<id>/provisioning`

- **Sam's domain is known to the mail provider (8024)** — run the email step; a
  `sending_domain — resend/<env>.<domain>` resource must be recorded, and the
  domain must appear in `Resend.list_domains/1`.
- **Setup waits for verification rather than assuming it (8026)** — the step must
  sit in `data-state="running"` while polling and must never reach `done` on an
  unverified domain.
- **A domain stuck unverified names the record at fault (8027)** — the error must
  name the specific records, e.g. "TXT resend._domainkey.uat, MX send.uat,
  TXT send.uat", not "verification failed".
- **The signing and bounce records resolve publicly (8025)** — `dig` each named
  record. **Currently fails**: nothing publishes them (issue `e2865a5e`).
- **A real message arrives from Sam's domain (8028)** — blocked by the same issue;
  the domain cannot verify, so nothing can send.
- **Existing inbound mail survives the sending setup (8029)** — re-run the DNS
  baseline afterwards and diff. Note astralbi.com has no MX at all, so this is
  currently vacuous; a domain with real inbound mail would be the honest test.
- **Test mail cannot pass for production mail (8056)** — the registered name must
  be `<environment>.<domain>`, never the bare apex.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.

## Setup Notes

**Always tear down the sending domain you create.** It is a real Resend domain on
the owner's account and it will sit there `pending` forever, since it cannot
verify. Delete by id after each run and confirm the verified-domain count is back
to what it was.

**Do not enable the `inbound` option while testing this story.** That step
publishes MX records to the **apex** (story 974's territory), and the two must not
fight — the knowledge doc warns specifically against deleting apex MX during a
provider migration. Keep the two stories' runs separate.

**The gap here is invisible to the spex.** A recorded cassette replays a domain
that was already verified, so the missing record publication never shows up.
Everything about this story that is worth knowing came from a live run against a
real zone.
