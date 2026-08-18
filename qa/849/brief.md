# QA Brief — Story 849: Setup runs as a routine I can watch

## Tool

web

## Auth

Log in as the owner — the provider grants (Cloudflare, Resend, GitHub) are
per-user OAuth and live on his account, so no other user can drive a real run.

1. `http://127.0.0.1:4000/users/log-in`
2. Fill `input[name="user[email]"]` with `johns10@gmail.com`
3. Click the submit button, `form button.btn-secondary` ("Email me a login link")
4. `http://127.0.0.1:4000/dev/mailbox` — the mailbox is shared, so confirm the
   message is addressed to that user before opening it
5. The link is issued for `dev.codemyspec.com`; swap the host to `127.0.0.1:4000`

If the email field renders `readonly`, a session is already open — log out via
the `a[href="/users/log-out"]` link (it is `data-method="delete"`, so navigating
to the URL does nothing), then start again.

The active account resets on a server restart. Re-pick at
`/app/accounts/picker`; entries are `a[phx-value-account-id=...]`. Code My Spec
is `0f27281c-240b-4d6d-8e52-9c5972329522`.

## Seeds

No story-specific seeding.

- QA Fixture Project: `11111111-1111-4111-8111-111111111111` (Code My Spec
  account; holds the real provider credentials and the adopted domain
  `astralbi.com`)
- QA Scope Test Project: `b30eab87-f481-40f4-9797-85939e833487` (QA Team 605
  Scope Test account; **no steps have ever run on it**, which is what makes it
  the right project for the untouched-plan criterion)
- Provisioning page: `http://127.0.0.1:4000/app/projects/<project_id>/provisioning`

## What To Test

- **Sam sees the whole plan before anything runs (7959).** Open the QA Scope
  Test project. Every step should render `data-state="not_started"`, in
  dependency order, before anything has happened.
- **An option turned off never appears in the run (7968).** Untick
  `options[domain]`: domain should go, and so should dns and tls, which mean
  nothing without it. Re-tick and they return. Count steps before and after.
- **Coming back without doing the thing keeps setup paused (7967).** Point the
  fixture project at a name the Registrar API cannot sell, run the domain step,
  and expect `paused` rather than `errored` or `done`. Then run it again without
  registering anything: it must re-check and stay paused, not treat the return
  as proof. Set the domain back to `astralbi.com` afterwards and re-run to
  confirm it goes green again.
- **A step's state changes under Sam's eyes (7960).** Run the server step and
  watch states move without a reload.
- **A failing step halts the run instead of pressing on (7961)** and **the
  provider's own error reaches the agent session (7962).** tls errors on its own
  here, because nothing is deployed to answer HTTPS. Expect a specific message
  naming the host and what issuance needs — not a generic failure — and expect
  the steps after it to stay `not_started`.
- **Sam retries one errored step without re-running the rest (7971)** and **a
  re-run picks up where it stopped (7963).** Retry tls alone and confirm only
  its `started_at` moves while the done steps keep their earlier timestamps.
- **A resource deleted behind setup's back is rebuilt, not skipped (7964)** and
  **a step's state is checked against the provider, not remembered (7970).**
  Delete a server directly at Hetzner, confirm the page still shows the stored
  `done`, then run the step and confirm it rebuilds rather than skipping.
- **Running a step twice leaves one of everything (7965).** Re-run server and
  count at the provider, not in our rows.
- **Sam reads back what he now owns (7969).** After the run, each step should
  list what it actually created — repository and commit, server with its ssh key
  and firewall and open ports, dns record and its address.
- **The domain purchase round-trip resumes on return (7966).** Not testable —
  see Setup Notes.

## Setup Notes

**Real provisioning, and tear it down.** Servers and DNS records created here
are real and cost money. Do not buy domains. Do not touch `fuellytics` or
`fuellytics prod` — those are live servers. Remove everything this session
creates before finishing, via the environment Remove button: `environment/3`
builds its own resource list and removes the DNS record before releasing the
server, which is the ordering that avoids handing a live name to a recycled
address.

**7966 is out of reach and should stay recorded as such.** It needs a real
registration to resume into, which is real money and non-refundable, and buying
domains is out of scope by the owner's instruction. Marking it partial is the
honest outcome, not a gap to work around.

**7967 is newly reachable.** Both prior attempts recorded it unexercised for
want of a paused step. `Step`'s own moduledoc says `:paused` means setup is
waiting on something Sam must do somewhere else — "register a TLD the API cannot
sell" is the example — and the domain step reaches exactly that state for a name
the Registrar API will not sell. So it needs no infrastructure at all, which is
why it is worth doing properly this time rather than deferring again.

**What changed since the 2026-08-03 attempt.** All three issues that were open
on this story are resolved:

- `27749cc8` — a project set to `devops: :uat` no longer builds production.
  Watch for this during the run: with the fixture project at the default level
  both environments are expected, but a `-prod` box on a uat-only project would
  be a regression.
- `bb0e1b30` — a spex teardown that cannot read its inventory now raises instead
  of reporting an empty success.
- `fdfdfb67` — the per-step Run button goes through `run_step_async/3`, so a
  step no longer runs inside a LiveView event. Two confirmation buttons still do
  (`74b6e3a0`), which is open and known.

## Result Path

`.code_my_spec/qa/849/result.md`
