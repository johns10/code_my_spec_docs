# QA Brief — Story 963: Setup runs as a routine I can watch

## Tool

web

## Auth

Browser session against the hosted endpoint on port 4000. `:browser` pipeline
behind `:require_authenticated`, so curl with a cookie is not an option.

**Passwordless** — the plan's old `qa-password-123!` does not exist (filed as
`3acee570`, plan since corrected):

1. `http://127.0.0.1:4000/users/log-in` → fill `input[name="user[email]"]`
   with `qa@codemyspec.local` → click "Email me a login link".
2. `http://127.0.0.1:4000/dev/mailbox` → read the message.
3. The link is minted as `https://dev.codemyspec.com/users/log-in/<token>`.
   **Rewrite the origin to `http://127.0.0.1:4000`** before navigating.
4. Lands on `/app`. Token is single-use.

## Seeds

Already applied. Verify with psql rather than re-running — the dev server on
4000 holds the compile lock and `mix run` under `MIX_ENV=dev` will 500 the app
mid-session.

```
psql -qtA code_my_spec_dev -c "select key, state, coalesce(left(provider_error,60),'-') from provisioning_steps where project_id='11111111-1111-4111-8111-111111111111' order by key;"
```

Project: `11111111-1111-4111-8111-111111111111`
Page: `http://127.0.0.1:4000/app/projects/11111111-1111-4111-8111-111111111111/provisioning`

This fixture is unusually good for *this* story, because it is a real halted
run rather than a blank slate. Six steps carry genuine provider errors:

| step | state | recorded reason |
|---|---|---|
| repository | errored | push rejected — not empty |
| server | not_started | *was* done; reverify found the box gone |
| deploy | errored | uat missing SECRET_KEY_BASE, DATABASE_URL |
| tls | errored | uat.astralbi.com did not answer over HTTPS |
| email | errored | sending domain did not verify |
| backups | errored | pg_dump failed (exit 1) |
| content | errored | publishing not configured |
| domain / storage / callback_credential | done | — |
| secrets / dns / inbound | not_started | — |

Options: `domain email inbound storage backups content` on; `widget monitoring`
off.

## What To Test

Selectors from the story's own spex: `setup-step`, `start-setup`, `run-step`,
`retry-step`, `resume-setup`, `escalation`, `paused-instructions`,
`provisioned-resource`, `setup-record`. Note the step key attribute is
`data-step`, not `data-key`.

- **7959 — the whole plan before anything runs.** Every enabled step renders
  with its label, `why` line and `data-position`, including steps that have
  never run. Assert positions are contiguous and ordered, and that
  `not_started` steps are present rather than hidden.
- **7968 — an option turned off never appears.** `widget` and `monitoring` are
  off; assert no `setup-step` carries those keys. Then toggle `monitoring` on
  and assert it appears as `not_started`, and toggle it back off. This is the
  criterion, both directions — testing only the "absent" half would pass on a
  page that never renders the step at all.
- **7961 — a failing step halts rather than pressing on.** `repository` is
  errored at position 0. Assert the page presents the run as stopped there
  rather than showing later steps as skipped-but-fine.
- **7962 — the provider's own error reaches the session.** Each errored step's
  `escalation` must carry the provider's actual words, not a generic
  "step failed". Check all six against the `provider_error` column above —
  the page text should match what psql holds.
- **7969 — Sam reads back what he now owns.** `provisioned-resource` entries
  under done steps name real things (bucket, repository, commit sha, firewall,
  ssh key fingerprint). A done step with no resource is the failure.
- **7970 — state is checked against the provider, not remembered.** Already
  observed during 966 QA: `mount/3` calls `Provisioning.reverify/3`, and the
  `server` step went `done` → `not_started` mid-load once Hetzner reported the
  box gone. Re-confirm by comparing `updated_at` before and after a reload.
- **7964 — a deleted resource is rebuilt, not skipped.** Same server row: it
  is `not_started` with its resources still recorded, so a re-run would
  rebuild rather than skip. Assert the step offers `run-step` rather than
  presenting as complete.
- **7971 — retry one errored step without re-running the rest.** Click
  `retry-step` on **tls only**. Chosen deliberately: its work is an outbound
  HTTPS probe to `uat.astralbi.com`, which will refuse the connection and
  change nothing anywhere. Before clicking, snapshot every step's state and
  `updated_at`; after, assert only `tls` moved.
- **Explore.** Reload and confirm state survives. Check `setup-record`.
  Confirm `paused-instructions` / `resume-setup` render only where a step is
  actually paused.

**Do not click `start-setup`.** A full run provisions real infrastructure on
live provider accounts. That is a drill, not a QA pass.

## Result Path

Findings filed via `create_issue` as found; run ends with `submit_qa_result`
on task `25841e41-9b1c-48b5-bc6f-eb05856606ef`. Screenshots to
`.code_my_spec/qa/963/screenshots/`.

## Setup Notes

Unlike story 966, most of this story's criteria are claims about the page
itself — what it shows, in what order, and whether it keeps telling the truth
about a run that stopped. Those are exactly what a browser session can hold it
to, so this story is expected to reach a real pass rather than a partial.

The three criteria that genuinely need a live run are 7960 (state changing
under Sam's eyes), 7963 (a re-run picking up where it stopped) and 7966/7967
(the domain purchase round-trip). Their spex cover them against recorded
providers. Record those `partial` with the reason rather than passing them on
the strength of the spex.

Servers `fuellytics` and `fuellytics-prod` are real and must never be touched.
Nothing here targets codemyspec.com.
