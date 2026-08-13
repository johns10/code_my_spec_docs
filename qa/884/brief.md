# QA Brief — Story 884: I can fix what my setup is missing, and keep what I meant to leave

## Tool

web

## Auth

Hosted UI on port 4000, magic-link login as the real account owner. This story
acts on real providers (fix builds real infrastructure, trim deletes real DNS
records), so a seeded account has nothing real to act on.

```
vibium go "http://127.0.0.1:4000/users/log-in"
```

**The browser session is shared across concurrently-running QA agents** (see
issue b373700d). If the email field is readonly and pre-filled with someone
else's address, click "Log out" first, then request a fresh link.

```
vibium fill "input[name='user[email]']" "johns10@gmail.com"
# click the "Email me a login link" button (@e18 or similar — re-map, it shifts)
```

**The mailbox is also shared.** Do not grab the newest message — grab the one
addressed to you:

```
curl -s "http://127.0.0.1:4000/dev/mailbox/json" | python3 -c "
import json,sys
for e in json.load(sys.stdin)['data']:
    if e.get('to') == ['johns10@gmail.com']:
        print(e.get('text_body')); break
"
```

Rewrite the `dev.codemyspec.com` host in the link to `127.0.0.1:4000`, then
`vibium go` the token URL directly.

Server must answer 200 on `/users/log-in` first. Any `mix` command against
this checkout recompiles `_build/dev` and 500s every route; recovery is
`pkill -9 -f phx.server`, `varlock run -- mix compile`, relaunch, wait
~60–90s.

## Seeds

None. The account's real state is the fixture.

```
psql -d code_my_spec_dev -c "select count(*) from resource_acknowledgements;"
```

State going in (verified this session, 2026-08-12):
- 0 acknowledgement rows — nothing marked.
- 3 real dangling DNS records: `uat.astralbi.com` (genuine leak, box destroyed
  during story 997's QA), `drill.astralbi.com`, `uat.drill.astralbi.com`
  (residue from the `devops-drill` project's box being torn down/rebuilt).
- Two projects with missing devops steps: `sprite smoke test` (devops: prod,
  all 15 steps missing — nothing has ever been built) and `devops-drill`
  (devops: uat — repository/server/secrets/domain/dns already present;
  `deploy` onward missing/erroring for real reasons: `deploy` fails on a SOPS
  decrypt error, `tls` on a cert timeout, `email` on Resend domain
  verification).
- Account health: unhealthy, 28 problems (25 missing steps + 3 dangling).

## What To Test

- Mark `uat.astralbi.com` via **Keep**: problem count drops by one, the row
  stays listed reading `kept`, disappears from the trim-candidate list *(8304)*
- Reload `/app/resources` from scratch (fresh `live/2`, not a patch): the
  record is still `kept`, without marking it again *(8306)*
- **Stop keeping** puts it back to `dangling` and the count returns
- Trim section lists candidates by name before anything is pressed, and a
  kept resource is absent from that list *(8305)*
- Trim's button only toggles a modal class (`add_class … modal-open`), no
  push — the delete rides on the confirm dialog *(8305)*
- A disposable DNS record, deletion of it via Trim, and confirmation that a
  marked sibling survives *(8305)* — see Setup Notes; needs an explicit
  create-a-real-record step that this session flagged to the operator before
  running.
- `Run setup` per project, addressed by `phx-value-project-id`, with
  `Build everything missing` above them *(8302)*
- `devops-drill`'s single-project `Run setup`: only `deploy` is missing, on an
  *existing* server, so retrying it is a redeploy, not new provisioning.
  Real exercise of the "reports which step and why" half of 8302/8303 without
  building anything new. Flagged to the operator before clicking, since it
  still touches real infra.
- `sprite smoke test`'s `Run setup` / `Build everything missing`: **do not
  click**. All 15 steps missing means this would provision a real repository,
  server, and DNS from nothing. That's the button working, not a test of it —
  same call the prior QA attempt (2026-08-06, attempt c51ba9fd) made, and
  issue 53b8f192 (resolved) explicitly endorsed keeping this seam-verified via
  spex rather than exercised for real.

## Setup Notes

**This story is genuinely destructive/costly to test for real**, more than
almost any other in the app — trim deletes at a live provider, fix
provisions real servers. Two guardrails carried over from the prior QA pass
on this exact story (issue 53b8f192):

1. Never trim the account's *real* dangling records
   (`uat.astralbi.com`, `drill.astralbi.com`, `uat.drill.astralbi.com`)
   just to prove the button works. Create one disposable record instead —
   the prior session used `qa-trim-999.astralbi.com -> 5.161.239.73` (a
   released address, no server behind it) via the app's own Cloudflare OAuth
   integration (`Cloudflare.ensure_dns_record/5`), the same path
   `mix cms.provisioning_leaks` uses, run under `MIX_ENV=test` so it never
   touches the running dev server's compile lock. This session named the
   record `qa-trim-884.astralbi.com` for the same purpose and asked the
   operator before running it, since it's an outward-facing, real DNS
   mutation.
2. Never click `sprite smoke test`'s fix — it would provision real
   infrastructure from nothing. `devops-drill` is the new, cheaper option
   this session found (didn't exist at the time of the prior QA pass): its
   only missing step redeploys to an existing box.

**Restore state before finishing:** release every mark and remove every
disposable record this session created, so the next reader sees the account
as it started — 0 acknowledgement rows, the same 3 dangling records, 28
problems.

Never touch codemyspec.com. `fuellytics` and `fuellytics-prod` are read-only.

## Result Path

`.code_my_spec/qa/884/result.md` (informational only — the canonical record
is the DB attempt via `submit_qa_result` plus linked issues, per
`qa_story/workflow.md`).
