# QA Brief — Story 966: My app answers on my own server over HTTPS

## Tool

web

## Auth

Browser session against the hosted endpoint on port 4000. Log in through the
UI — this is a `:browser` pipeline route behind `:require_authenticated`, so
curl with a cookie is not an option.

**Passwordless.** The plan's `qa-password-123!` is dead — there is no password
field (filed as `3acee570`). Magic link instead:

1. `http://127.0.0.1:4000/users/log-in` → fill `input[name="user[email]"]`
   with `qa@codemyspec.local` → click "Email me a login link".
2. `http://127.0.0.1:4000/dev/mailbox` → read the message.
3. The link is minted as `https://dev.codemyspec.com/users/log-in/<token>`.
   **Rewrite the origin to `http://127.0.0.1:4000`** before navigating.
4. Lands on `/app` with the fixture project active. Token is single-use.

The account is `qa-account` and the user is stamped `Member{role: :owner}`, so
no further elevation is needed.

## Seeds

Already applied — verify rather than re-run, because the dev server on 4000
holds the compile lock and a `mix run` under `MIX_ENV=dev` will 500 the app
mid-session.

Verify with psql directly:

```
psql -qtA code_my_spec_dev -c "select email from users where email='qa@codemyspec.local';"
psql -qtA code_my_spec_dev -c "select id, name from projects where id='11111111-1111-4111-8111-111111111111';"
psql -qtA code_my_spec_dev -c "select key, state from provisioning_steps where project_id='11111111-1111-4111-8111-111111111111' order by key;"
```

If the user or project row is missing, stop the dev server first, then run
`mix run priv/repo/qa_seeds.exs`, then restart it.

Project under test: `11111111-1111-4111-8111-111111111111` ("QA Fixture
Project"). Page: `http://127.0.0.1:4000/app/projects/11111111-1111-4111-8111-111111111111/provisioning`

The fixture already carries a mixed provisioning state, which is what makes it
worth testing rather than a blank project:

| state | steps |
|---|---|
| `done` | callback_credential, domain, server, storage |
| `errored` | backups, content, deploy, email, repository, tls |
| `not_started` | dns, inbound, secrets |
| no row at all | monitoring |

## What To Test

Selectors are taken from the story's own spex, so a rename breaks QA and the
BDD layer together rather than silently passing here: `setup-step`,
`run-step`, `deploy-phase`, `live-version`, `deployed-version`,
`deploy-failure`, `deploy-downtime`, `uptime-monitor`, `environment`,
`environment-verification`, `provisioned-resource`, `firewall-scope`,
`firewall-rule`, `start-setup`, `add-environment-form`.

- **Page loads and reports true state.** Visit the provisioning URL. Every
  step in the table above renders with `data-state` matching what psql says.
  A step the DB calls `errored` must not render as anything else. Screenshot.
- **The server shows up (criterion 8003).** *Corrected after execution:* the
  step is not `done` by the time the page renders. `mount/3` calls
  `Provisioning.reverify/3`, which asks Hetzner, finds the box gone (an
  earlier drill tore it down) and downgrades the row to `not_started` during
  the page load. So the DB snapshot taken before loading the page does not
  match the DB after — that is correct behaviour (criteria 7964, 7970), not a
  bug, and the reverify is worth expecting rather than being surprised by.
  What is testable here is the negative: the page must not keep claiming a
  server that no longer answers. It does stop claiming the state, but it
  still lists the vanished resource (filed as `7ba220b6`).
- **Database is not reachable from outside (8004).** Look for
  `firewall-scope` / `firewall-rule` on the server step's resources. Assert
  the rule set is rendered and that it scopes Postgres to something narrower
  than the public internet.
- **Deployed image is the one the repo built (8005).** The `deploy` step is
  `errored`, so check the negative: `deployed-version` must NOT claim a live
  version, and `deploy-failure` must be present and legible. An errored deploy
  that still shows a live version is the bug.
- **Valid certificate (8006).** `tls` is `errored`. Confirm the page says so
  and gives a reason rather than a bare red state. Note that `tls` follows
  `deploy` in the sequence — a tls failure downstream of a failed deploy
  should read as blocked-by, not as an independent certificate problem.
- **Migrations land before the swap (8007) / failed migration leaves the old
  version serving (8008) / unhealthy deploy does not go live (8009).** These
  are `deploy-phase` orderings. With deploy errored, assert the phases render
  in sequence and that no phase after the failure is marked complete.
  `deploy-downtime` should not claim zero downtime for a run that failed.
- **Sam finds out when the site stops answering (8010).** `monitoring` has no
  row at all. *Corrected after execution:* the step is legitimately absent
  from the page because the `monitoring` option is off, which is criterion
  7968's documented behaviour ("steps his options exclude are absent, not
  present-and-skipped"). `widget` is off and absent for the same reason. The
  assertion is therefore the opposite of what this bullet first said: with the
  option off, absence is correct. To exercise 8010, turn `monitoring` on first
  and confirm the step then appears as `not_started`.
- **UAT stands alone, prod on its own box (8156).** Check `environment` rows
  and `environment-verification`. Add a `prod` environment via
  `add-environment-form` and confirm it appears without disturbing the
  existing `uat` server. Remove it again afterwards.
- **Explore.** Reload mid-state, try `run-step` on an errored step and confirm
  the button is offered with a retry affordance, and check the page does not
  fire provider calls on every render (watch for latency spikes or errors in
  the console).

Do not click `start-setup`. A full run provisions real infrastructure on live
provider accounts and is a drill, not a QA pass.

## Result Path

Findings are filed via `create_issue` as they are found, and the run ends with
`submit_qa_result` on task `f2ed8527-665d-4313-9321-23d14366a408`. Screenshots
go to `.code_my_spec/qa/966/screenshots/`.

## Setup Notes

**Scope boundary, stated up front so the result is not oversold.** Four of the
nine criteria assert outcomes in the world — a box in Hetzner's console, a
closed Postgres port, a certificate a browser accepts, an alert that fires.
The running app cannot be made to prove those from a browser session; the spex
prove them against real providers, and the drills prove them end to end. What
QA can hold this page to is that it reports those outcomes truthfully and does
not claim success it has no evidence for. Every scenario above is written as
that second thing.

Where a criterion cannot be exercised without a live run, the scenario is
recorded `partial` with the reason, not passed on the strength of the spex.

Servers `fuellytics` and `fuellytics-prod` are real and must never be deleted.
Nothing in this brief touches them, and nothing here targets codemyspec.com.
