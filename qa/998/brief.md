# QA Brief — Story 998: I can tell at a glance whether my whole setup is healthy

## Tool

web

## Auth

Hosted UI on port 4000, magic-link login as the real account owner. A seeded
account has no providers, so every criterion would be vacuous.

```
vibium go "http://127.0.0.1:4000/users/log-in"
vibium fill "form[phx-submit] input[name='user[email]']" "johns10@gmail.com"
vibium eval "[...document.querySelectorAll('button')].find(x=>x.innerText.includes('Email me a login link')).click()"
curl -s "http://127.0.0.1:4000/dev/mailbox"            # newest message id
curl -s "http://127.0.0.1:4000/dev/mailbox/<id>/html" | grep -o 'href="[^"]*log-in/[^"]*"'
# swap the dev.codemyspec.com host for 127.0.0.1:4000, then:
vibium go "http://127.0.0.1:4000/users/log-in/<token>"
```

Server must answer first (`curl -o /dev/null -w '%{http_code}'
http://127.0.0.1:4000/users/log-in` → 200). Any `mix` command in this checkout
recompiles `_build/dev` and 500s every route; recovery is `pkill -9 -f
phx.server`, `varlock run -- mix compile`, relaunch, wait ~60–90s.

## Seeds

None, and deliberately none: the page's whole claim is that it reports the
providers rather than our records.

State that matters, and must be left as found:

```
psql -d code_my_spec_dev -c "select p.name, c.devops from projects p
  left join project_configurations c on c.project_id=p.id
  where p.account_id=(select active_account_id from user_preferences where user_id=1);"
# Todo Sprite = off, sprite smoke test = prod, nine with no row (= off)
```

`devops` defaults to `:off`, so the checklist half is currently empty for this
account. Exercising it means turning devops on for one project through
`/app/projects/:id/configuration` — **and turning it back off afterwards.**

## What To Test

- `/app/resources` is reachable from the sidebar, under Servers *(nav)*
- The page enumerates all four providers and lists real resources with kind
  and location *(8291)*
- Compare the rendered set against each provider's own API at the same moment
  — Hetzner servers/firewalls/ssh keys, Cloudflare DNS records, Resend
  domains/webhooks, object-storage buckets. Counts and locations must match
  *(8291, 8294)*
- The account's SSH key and firewall appear **once**, under an account-owned
  section, carrying no project attribution *(8292)*
- Every A record whose target is not one of the account's Hetzner server
  addresses is marked dangling, and every record that does point at one is not
  *(8293)*
- Resources setup never recorded are present and marked as such — most of this
  account's resources predate CodeMySpec, so this is the common case *(8294)*
- Rename the account's Hetzner token so that provider cannot be asked, reload,
  and confirm: the other three still list, a provider error names Hetzner and
  says why, and the summary does **not** read healthy *(8295)*. Restore the
  token afterwards.
- Turn devops on for one project, reload, and confirm its unbuilt steps appear
  as missing and the problem count rises by that many *(8296)*
- The summary carries `data-status` and `data-problems` and states the count in
  words above any resource — readable without scrolling into the list *(8297)*
- Exactly the resources that are wrong are marked; nothing else is *(8297)*

## Setup Notes

**Expect false positives on 8293 and treat them as the finding, not as noise.**
The dangling rule is "an A record whose target matches no Hetzner server in this
account". `codemyspec.com`, `www.codemyspec.com` and `uat.codemyspec.com` point
at Fly addresses and will be flagged; `astralbi.com` and the two `ftp.` records
point at a host outside this account and will be flagged. Only
`uat.astralbi.com → 5.161.239.73` is a genuine leak — the box behind it was
destroyed. Record what the rule gets right and what it gets wrong; the marking
that fixes it is story 999.

**Read-only story.** Nothing on this page should create, delete or modify
anything at a provider. Confirm that explicitly: capture each provider's
resource counts before and after the session and diff them.

Never touch codemyspec.com. `fuellytics` and `fuellytics-prod` are read-only.

## Result Path

`.code_my_spec/qa/998/result.md`
