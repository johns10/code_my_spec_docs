# QA Brief — Story 994: I can see and link the servers I already own

## Tool

web

## Auth

Hosted UI on port 4000. Magic-link login as the real account owner, because the
whole story is about *his* boxes — a seeded account has no servers at Hetzner
and would make every criterion vacuous.

```
vibium go "http://127.0.0.1:4000/users/log-in"
vibium fill "form[phx-submit] input[name='user[email]']" "johns10@gmail.com"
vibium eval "[...document.querySelectorAll('button')].find(x=>x.innerText.includes('Email me a login link')).click()"
curl -s "http://127.0.0.1:4000/dev/mailbox" # find the newest message id
curl -s "http://127.0.0.1:4000/dev/mailbox/<id>/html" | grep -o 'href="[^"]*log-in/[^"]*"'
# swap the dev.codemyspec.com host for 127.0.0.1:4000, then:
vibium go "http://127.0.0.1:4000/users/log-in/<token>"
```

Dev server must be answering first: `curl -o /dev/null -w '%{http_code}'
http://127.0.0.1:4000/users/log-in` → 200. Any `mix` command in this checkout
recompiles `_build/dev` and 500s every route; recovery is `pkill -9 -f
phx.server`, `rm -rf _build/dev/lib/code_my_spec*`, `varlock run -- mix
compile`, relaunch, and wait ~80s.

## Seeds

None. The point of this story is that nothing was seeded — the servers on the
screen are the ones Hetzner reports for the account's real API token.

Schema only: `linked_servers` must exist in `code_my_spec_dev`. It was applied
by hand (the running server cannot survive `mix ecto.migrate`):

```
psql -d code_my_spec_dev -c "select count(*) from linked_servers;"
```

Values in play:

- `fuellytics` (46.225.105.88, cax11) and `fuellytics-prod` (178.156.143.212,
  cpx21) — **real, production, must never be destroyed or modified**
- `qa-fixture-project-uat` (5.161.239.73) — retained from earlier devops QA,
  lives under a different Hetzner project's token

## What To Test

- `/app/servers` renders and the sidebar carries a **Servers** link under
  Projects — the screen is reachable without knowing the URL
- Both `fuellytics` and `fuellytics-prod` appear with size, IP and status, on a
  screen that was never told they exist *(criterion 8257, 8264)*
- Sizes shown match what Hetzner reports **now**, not a stored record — compare
  `data-size` against `hcloud`/the API for the same box *(8258)*
- Link `fuellytics` and confirm the box is untouched: status, IP, size and
  Hetzner's `updated`/action log unchanged *(8260)*
- After linking, the linked box moves out of the unlinked group and the
  `+N more` count drops by one; the unlinked ones are still reachable *(8263)*
- With the active project switched to one whose Hetzner token is absent or
  wrong, the screen says the provider could not be asked — it must not render
  as "no servers" *(8259)*
- A linked server the provider no longer reports is marked `missing at
  provider` rather than dropped *(8262)*
- Provisioning form offers only sizes `/datacenters` reports available; confirm
  by checking a type that is listed-but-sold-out is absent *(8266)*
- Choose a size, and verify a **cost** is stated before anything is created;
  confirm no server exists at Hetzner until "Create it" is pressed *(8267)*
- Pick a location/size pair the form allows but the provider cannot supply,
  and confirm the failure names the size and location and does not silently
  substitute another *(8266)*
- Create one real box, confirm it arrives already linked, then destroy it
  *(8265)*
- Cross-project visibility: a second project on the same account sees the
  server the first one linked *(8261)*

## Setup Notes

`Servers` is account-scoped, but the Hetzner credential is still resolved from
the **active project**. Watch for this seam — it is the most likely place for
8261 to fail, and it is why `qa-fixture-project-uat` is absent from the list
while the two `fuellytics` boxes are present.

Never touch codemyspec.com. Any box created during this session must be
destroyed before the session ends, and the two `fuellytics` boxes are
off-limits for anything but linking.

## Result Path

`.code_my_spec/qa/994/result.md`
