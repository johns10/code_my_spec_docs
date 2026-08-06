# QA Brief — Story 999: I can fix what my setup is missing, and keep what I meant to leave

## Tool

web

## Auth

Hosted UI on port 4000, magic-link login as the real account owner. This story
acts on real providers, so a seeded account has nothing to act on.

```
vibium go "http://127.0.0.1:4000/users/log-in"
vibium fill "form[phx-submit] input[name='user[email]']" "johns10@gmail.com"
vibium eval "[...document.querySelectorAll('button')].find(x=>x.innerText.includes('Email me a login link')).click()"
curl -s "http://127.0.0.1:4000/dev/mailbox"            # newest message id
curl -s "http://127.0.0.1:4000/dev/mailbox/<id>/html" | grep -o 'href="[^"]*log-in/[^"]*"'
# swap the dev.codemyspec.com host for 127.0.0.1:4000, then:
vibium go "http://127.0.0.1:4000/users/log-in/<token>"
```

Server must answer 200 on `/users/log-in` first. Any `mix` command recompiles
`_build/dev` and 500s every route; recovery is `pkill -9 -f phx.server`,
`varlock run -- mix compile`, relaunch, wait ~60–90s.

## Seeds

None. The account's real state is the fixture.

What is on the page going in:

```
psql -d code_my_spec_dev -c "select count(*) from resource_acknowledgements;"
# 0 — nothing marked yet
```

- `uat.astralbi.com → 5.161.239.73` is the one genuinely dangling record: the
  box behind it was destroyed during story 997's QA and its address released.
- `sprite smoke test` is the only project with `devops: :prod`, so it is the
  only one contributing a checklist — 15 steps, all missing.

## What To Test

- `/app/resources` shows a **Keep** control on the dangling record and nothing
  else *(8304)*
- Marking `uat.astralbi.com` clears it from the problem count, leaves it listed,
  and shows it as kept on purpose — the account's count drops by one *(8304)*
- Reload the page from scratch: the record is still kept, without marking it
  again *(8306)*
- **Stop keeping** puts it back among the dangling and the count returns
- The **Trim** section lists candidates by name before anything is pressed, and
  a kept resource is absent from that list *(8305)*
- Trim's button opens a confirmation rather than deleting on the first click,
  and the deletion rides on the confirm *(8305)*
- Create a disposable DNS record on `astralbi.com` pointing at the released
  address, so it reads as dangling; mark one of the two dangling records as
  kept; trim; confirm at Cloudflare that the unmarked one is gone and the
  marked one is still there *(8305)*
- A **Run setup** button appears per project with a missing step, addressed by
  project id, and a **Build everything missing** button above them *(8302)*

## Setup Notes

**Fix is not exercised against real providers.** Clicking Run setup for
`sprite smoke test` would provision a real repository, server and DNS from
scratch — the point of the button, and not something to do to prove a button
works. What is checked here is that it renders, is addressed per project, and
matches the sequence's ordering model. The behaviour is covered by 8302 and
8303's spex, which seam the step runner.

**Trim deletes for real, so it gets a disposable target.** Create a record that
is genuinely dangling by pointing it at the released address:

```
# via the Cloudflare dashboard or API, on astralbi.com:
#   qa-trim-999.astralbi.com  A  5.161.239.73
```

Then confirm after trimming that it is gone at Cloudflare and that anything
marked kept survived. Nothing else on any provider may be touched.

**Restore state before finishing:** remove every row from
`resource_acknowledgements` that this session created, so the next reader sees
the account as it was.

Never touch codemyspec.com. `fuellytics` and `fuellytics-prod` are read-only.

## Result Path

`.code_my_spec/qa/999/result.md`
