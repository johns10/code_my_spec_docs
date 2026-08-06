# QA Brief — Story 963: Setup runs as a routine I can watch

## Tool

web

## Auth

The password form has been removed from `/users/log-in` — it now renders a single
magic-link form. Password login no longer works; use the mailbox flow.

The seeded fixture user must be confirmed first, or the magic link raises a 500
(see issue `58d4ec98`). One-time fix already applied to the dev DB:

    psql -d code_my_spec_dev -c "update users set confirmed_at = now() where email = 'qa@codemyspec.local' and confirmed_at is null;"

Then, verbatim:

    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "qa@codemyspec.local"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

The QA Fixture Project belongs to the **Code My Spec** account, not the account the
fixture user lands in. Switch before navigating, or the provisioning route bounces to
`/app/projects` with "That project is not yours, or does not exist":

    vibium go "http://127.0.0.1:4000/app/accounts/picker"
    vibium eval "(()=>{const els=Array.from(document.querySelectorAll('[phx-click=\"account-selected\"]')); const t=els.find(e=>e.textContent.includes('Code My Spec')&&!e.textContent.includes('QA')); t.click(); return 'ok';})()"

## Seeds

Base fixture is already present — do not re-run `mix run priv/repo/qa_seeds.exs` while
the dev server is up (it takes the dev compile lock and 500s the running server).

Entities:

- User `qa@codemyspec.local`
- Project `QA Fixture Project`, id `11111111-1111-4111-8111-111111111111`
- Account `Code My Spec` (`0f27281c-240b-4d6d-8e52-9c5972329522`)

The project has no `code_repo`, no `domain`, and no rows in
`provisioning_environments`. That is the intended starting state for "before anything
runs" — do not provision it as a side effect of another story's QA.

## What To Test

URL: `http://127.0.0.1:4000/app/projects/11111111-1111-4111-8111-111111111111/provisioning`

Observable without provider credentials:

- **Sam sees the whole plan before anything runs (7959)** — every step renders with
  `data-state="not_started"` before any run. Expect 15: repository, server, secrets,
  domain, dns, tls, deploy, email, inbound, storage, backups, content, widget,
  callback_credential, monitoring.
- **An option turned off never appears in the run (7968)** — untick
  `options[domain]` in `[data-test="setup-options-form"]`; the plan must drop
  `domain`, and also `dns` and `tls`, since neither means anything without a domain.
  Re-tick and confirm 15 steps return.
- **Setup refuses to start while a credential is missing** — `[data-test="credentials-incomplete"]`
  names each one. This is 964's criterion, but it gates every run here, so confirm it
  before concluding a run "did nothing".

Requires real provider credentials on the fixture project, and creates real
infrastructure:

- A step's state changes under Sam's eyes (7960)
- A failing step halts the run instead of pressing on (7961)
- The provider's own error reaches the agent session (7962)
- A re-run picks up where it stopped (7963)
- A resource deleted behind setup's back is rebuilt, not skipped (7964)
- Running a step twice leaves one of everything (7965)
- The domain purchase round-trip resumes on return (7966)
- Coming back without doing the thing keeps setup paused (7967)
- Sam reads back what he now owns (7969)
- A step's state is checked against the provider, not remembered (7970)
- Sam retries one errored step without re-running the rest (7971)

Each needs a run that reaches a provider. See Setup Notes before doing that.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`; this
directory holds screenshots only (`4000_963_provisioning.png`).

## Setup Notes

**The dev server wedges if anything compiles `_build/dev` underneath it.** Running
`mix test` triggers the TestAdapter's "compiling dev environment for static analysis"
pass, which invalidates `_build/dev/lib/code_my_spec/.mix/compile.lock`; every route
then 500s with a `CompileError` telling you to restart. Recovery:

    kill <varlock pid>; varlock run -- mix compile; nohup varlock run -- mix phx.server &

Batch test runs away from QA, or expect to restart the server between them.

**The eleven run-dependent criteria create real, billable infrastructure** — a Hetzner
server, a GitHub repository, DNS records, and (for 7966) a domain *purchase*, which is
not refundable. The spex cover these in-process with recorded cassettes and tear down
what they make. Before running them here, decide:

- which account and domain the run targets (never `codemyspec.com`),
- whether the domain step is turned off, since a purchase is irreversible,
- who tears the resulting resources down.

`mix cms.provisioning_leaks` lists and deletes leftover `spex-` prefixed Hetzner
servers, buckets and SSH keys, and is the cleanup path if a run dies part-way.
