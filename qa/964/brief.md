# QA Brief — Story 964: My provider credentials go in once and get checked

## Tool

web

## Auth

Browser session against port 4000, `:browser` pipeline behind
`:require_authenticated`.

**Passwordless** — the plan's old `qa-password-123!` does not exist (filed
`3acee570`, plan since corrected):

1. `http://127.0.0.1:4000/users/log-in` → fill `input[name="user[email]"]`
   with `qa@codemyspec.local` → click "Email me a login link".
2. `http://127.0.0.1:4000/dev/mailbox` → read the message.
3. The link is minted as `https://dev.codemyspec.com/users/log-in/<token>`.
   **Rewrite the origin to `http://127.0.0.1:4000`.**
4. Lands on `/app`. Single-use token.

## Seeds

Already applied. Verify with psql — do not run `mix run` while the dev server
on 4000 holds the compile lock.

```
psql -qtA code_my_spec_dev -c "select setup_options from projects where id='11111111-1111-4111-8111-111111111111';"
psql -qtA code_my_spec_dev -c "select key from project_secrets where project_id='11111111-1111-4111-8111-111111111111' order by key;"
```

Project: `11111111-1111-4111-8111-111111111111`
Page: `http://127.0.0.1:4000/app/projects/11111111-1111-4111-8111-111111111111/provisioning`

Expected fixture state — options `backups content domain email inbound
storage`; stored secrets include `hetzner_api_token`,
`hetzner_s3_access_key_id`, `hetzner_s3_secret_access_key`; GitHub, Cloudflare
and Resend are account-level connections and are **not** connected.

So a correct page shows **six** credential rows, three of them stored and
three missing.

For the isolation test you need a project in an account the QA user is not a
member of. `47d78148-6b92-4d9c-bfa9-6dbed5057ddd` ("Week View", account
`acme-salons`) works. Do **not** use `ee33ba64-...` (`devops-drill`) — it is in
`code-my-spec`, which the QA user *is* a member of, so it is legitimately
visible and proves nothing.

## What To Test

Selectors from the story's spex: `credentials-form`, `credential-field`,
`credential-directions`, `check-credentials`, `start-setup`, `project-form`,
`project-row`, `setup-step`. Read `data-credential`, `data-state` and
`data-stored` off each field rather than matching on label text.

- **7981 — one sitting covers every credential.** On a *fresh* mount, assert
  all six rows render. **Then toggle any option and re-count.** Testing only
  the fresh load misses the defect entirely; the count is the assertion.
- **7982 — an option turned off does not ask for its credential.** Turn
  `storage` off and assert the two S3 rows go, then turn it back on and assert
  they **return**. The return leg is the one that matters — the current
  implementation only ever filters the list down, so it cannot restore a row.
- **7983 — proven by a real call, not by looking right.** Click
  `check-credentials`. Stored credentials should move `unchecked` → `verified`
  and missing ones stay missing. Read-only calls; safe to run.
- **7984 — an under-scoped token names the permission it lacks.** Needs a
  deliberately under-scoped Hetzner token. Not obtainable without minting one
  in the console; record `partial` rather than inventing a pass.
- **7985 — a missing credential stops the run before it starts.** Safe to
  exercise: with GitHub/Cloudflare/Resend missing, snapshot every step's
  `updated_at`, click `start-setup`, wait, and diff. Nothing should move. This
  is the one `start-setup` click that is safe, because the guard refuses
  before `run_async` is reached.
- **7986 — the console-only key pair is asked for with directions.** The two
  S3 rows must carry `credential-directions` explaining that the pair exists
  only in the Hetzner console and the secret half is shown once. Check they
  are present *and* that they survive an option toggle.
- **7987 — the repo stays clean of credential values.** In
  `code_my_spec_test_repos/qa_sandbox`, assert `envs/*.enc.env` values are
  `ENC[AES256_GCM,...]`. The `age1...` string in `.sops.yaml` is a **public**
  recipient and is supposed to be committed — do not report it.
- **8050 — credentials follow the project wherever the agent runs.** Secrets
  are per-project (`project_secrets`), connections per-account. Fully proving
  the "wherever the agent runs" half needs the CLI surface; record `partial`.
- **8051 — another project's credentials are not reachable.** Navigate to the
  `acme-salons` project's provisioning URL as the QA user. Expect a redirect
  to `/app/projects` with zero steps and zero credential fields.

**Do not click `start-setup` with credentials complete.** The only sanctioned
click is the 7985 guard test above, which cannot start a run.

## Result Path

Findings via `create_issue` as found; ends with `submit_qa_result` on task
`e9fe9786-373c-4086-be79-04b008f5f079`. Screenshots to
`.code_my_spec/qa/964/screenshots/`.

## Setup Notes

This story is mostly surface, so unlike 966 and 963 it does not need a live
provisioning run — seven of nine criteria are fully checkable from a browser.

One trap, learned the hard way: **the credential list goes stale after an
option toggle** (filed `6b22ed0a`). If you arrive at the page mid-session and
see two rows instead of six, you are looking at a corrupted list, not the
fixture. Navigate away and back to get a clean mount before asserting
anything. That staleness is itself the story's biggest defect, so reproduce it
deliberately rather than working around it.
