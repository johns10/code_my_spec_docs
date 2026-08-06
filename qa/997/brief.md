# QA Brief — Story 997: I can see what is running on each of my servers

## Tool

web

## Auth

Hosted UI on port 4000, magic-link login as the real account owner. The whole
story is about reading a real machine, so a seeded account proves nothing —
it has no box to read.

```
vibium go "http://127.0.0.1:4000/users/log-in"
vibium fill "form[phx-submit] input[name='user[email]']" "johns10@gmail.com"
vibium eval "[...document.querySelectorAll('button')].find(x=>x.innerText.includes('Email me a login link')).click()"
curl -s "http://127.0.0.1:4000/dev/mailbox"            # newest message id
curl -s "http://127.0.0.1:4000/dev/mailbox/<id>/html" | grep -o 'href="[^"]*log-in/[^"]*"'
# swap dev.codemyspec.com for 127.0.0.1:4000, then:
vibium go "http://127.0.0.1:4000/users/log-in/<token>"
```

Server must answer first (`curl -o /dev/null -w '%{http_code}'
http://127.0.0.1:4000/users/log-in` → 200). Any `mix` command in this checkout
recompiles `_build/dev` and 500s every route; recovery is `pkill -9 -f
phx.server`, `varlock run -- mix compile`, relaunch, wait ~60–90s.

## Seeds

None. The point is that nothing is seeded — the containers on screen are what
`docker ps -a` reports on a real machine right now.

The provisioning records that back the "Set up here" half are already in
`code_my_spec_dev` from earlier devops runs, and they carry the three step
states this story cares about:

```
psql -d code_my_spec_dev -c "select key, state from provisioning_steps
  where project_id='11111111-1111-4111-8111-111111111111' order by position;"
# server/domain/storage = done, secrets/dns/inbound = not_started,
# repository/tls/deploy/email = errored
```

Values in play:

- `fuellytics-prod` (178.156.143.212) — **real production, read-only.** Never
  stop, start or remove a container on it. 31 containers, 23 exited, 8 running,
  across six apps.
- `fuellytics` (46.225.105.88) — real production, read-only.
- The QA Fixture Project's `uat` environment names `qa-fixture-project-uat`,
  whose box was destroyed. Creating a throwaway box under that exact name is
  what makes the recorded resources resolvable — see Setup Notes.

## What To Test

- `/app/servers` — every row's name links through to its own page (the show
  view was unreachable before this was added; check it is a link, not text)
- `/app/servers/fuellytics-prod` renders the box: containers read live, and a
  "Set up here" section for our records *(the two halves, 8284)*
- Compare the container list against `ssh root@178.156.143.212 'docker ps -a'`
  taken at the same moment — names, states and statuses must match exactly,
  with nothing sourced from a deploy record *(8284)*
- At least one **exited** container is listed with its exit code and does not
  read as healthy — 23 of them are on that box already, no need to stop
  anything *(8286)*
- All six apps are listed, including `kamal-proxy` and `infra-postgres-1`,
  which belong to no project *(8287)*
- The filter dropdown narrows the list; changing it must **not** re-read the
  box — confirm by watching that no second SSH connection is made
- Containers whose service maps to a project carry `data-project-id` and link
  to it; ones that do not are still listed unattributed *(8287)*
- Hide the account's SSH key and reload: the page must say it cannot get in,
  keep the records half on screen, and never render an empty container list as
  though the box were idle *(8285)*
- With a linked box named `qa-fixture-project-uat`, its page shows the DNS
  record setup made for that environment *(8288)*
- The same page shows `storage` as done, `dns` as never run, and `deploy` as
  failed carrying its error text — three distinct marks, not two *(8289)*
- On first paint the container area says it is still reading, and the records
  half is already there *(8290)*

## Setup Notes

**For 8288 and 8289** the recorded resources are keyed to a server name whose
box no longer exists. Create a throwaway under that exact name, link it, read
its page, then destroy it:

```
TOK=$(grep -i -o 'HETZNER[A-Z_]*=.*' envs/.env | head -1 | cut -d= -f2- | tr -d '"'"'"' ')
curl -s -X POST -H "Authorization: Bearer $TOK" -H 'content-type: application/json' \
  https://api.hetzner.cloud/v1/servers \
  -d '{"name":"qa-fixture-project-uat","server_type":"cpx11","location":"hil","image":"ubuntu-24.04","ssh_keys":["codemyspec"]}'
# ... test ...
curl -s -X DELETE -H "Authorization: Bearer $TOK" https://api.hetzner.cloud/v1/servers/<id>
```

Roughly €0.03/hour. **Destroy it before the session ends**, and confirm only
`fuellytics` and `fuellytics-prod` remain.

**8290's timeout path** cannot be produced honestly against real infrastructure
— a box that accepts a connection and then never answers is not a state we can
arrange without breaking a production machine. Test the pending-render half for
real and record the timeout half as covered by criterion 8290's spex, which
seams the reader.

Never touch codemyspec.com. Both `fuellytics` boxes are read-only for the whole
session.

## Result Path

`.code_my_spec/qa/997/result.md`
