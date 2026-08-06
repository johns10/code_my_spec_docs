# QA Brief — Story 968: My files and backups live in my own bucket

## Tool

web

## Auth

Magic link as the owner (`johns10@gmail.com`) — the Hetzner S3 credentials are
stored per-project but the page needs his session.

    vibium cookies clear
    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "johns10@gmail.com"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

## Seeds

`QA Fixture Project` — `11111111-1111-4111-8111-111111111111`, with Hetzner S3
credentials already stored and `storage` + `backups` options enabled.

**Its `local_path` now points at the sandbox**, which is where the QA plan always
said it should be:

    /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox

It previously pointed at the CodeMySpec checkout itself (issue `b400d0d3`), which
meant "Generate deploy files" would have written `.github/workflows/build.yml`,
`Dockerfile`, `bin/`, `config/` and `envs/` into the live repository. Check this
before clicking that button.

Inspect buckets directly with the same credentials the app uses:

    set -a; . envs/.env; set +a
    export AWS_ACCESS_KEY_ID=$HETZNER_S3_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$HETZNER_S3_SECRET_ACCESS_KEY
    aws --endpoint-url https://fsn1.your-objectstorage.com s3 ls

## What To Test

URL: `http://127.0.0.1:4000/app/projects/<id>/provisioning`

- **The buckets are Sam's, in Sam's account (8011)** — run the storage step, then
  list buckets with his own S3 credentials. The bucket must appear there, not be
  reported only by our own record.
- **Test data never lands in the production bucket (8012)** — buckets are named
  `<project>-<environment>`. Add a second environment and run storage again; each
  must get its own bucket.
- **A file uploaded to the app comes back from the bucket (8013)** — needs a
  deployed app; not reachable until the deploy path works.
- **Last night's dump is there in the morning (8014)** — needs the backups step to
  complete. Blocked today by `07e95135` and `0251ea1a`.
- **A backup that stops running does not fail silently (8015)** — same gate.
- **Backups past the retention window are gone (8016)** — retention is a bucket
  lifecycle rule applied by the backups step *before* the first dump, so it needs
  the same gate.
- **A dump restores into a working database (8017)** — the step restores into a
  scratch database and counts rows; same gate.
- **Sam knows he has a backup, not just a file (8054)** — the `restore_proof`
  resource carries `rows=` and `proven_at=`; same gate.

To exercise the backup path once the issues above are fixed: create a throwaway
database with a couple of rows, store its connection string as `DATABASE_URL` for
the environment through the secret form, then run the backups step.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.

## Setup Notes

**The backups step is single-environment and defaults to `prod`** (`07e95135`),
while the storage step beside it fans out. On a project without a `prod`
environment it looks for a bucket nothing created and fails `NoSuchBucket`; on a
normal prod+uat project it reports done having dumped production only.

A fan-out fix is straightforward and mirrors the TLS fix in `69ca7625`, **but it
invalidates the recorded cassettes** for this story: the 968 spex were recorded
when the step used `prod`, and after the change they request `-uat` and miss.
Landing that fix means re-recording those cassettes against real object storage,
which creates `spex-story968-*` buckets — clean them with
`mix cms.provisioning_leaks`. I reverted my fix rather than leave three spex red.

**Even with the right bucket, the dump cannot read its credentials** (`0251ea1a`):
`script_env/1` has a `DATABASE_URL` slot nothing populates, and no `SOPS_AGE_KEY`
is passed, so `bin/backup`'s own `sops -d` fallback has no identity either.

**`mix test` wedges the running dev server**; `mix run` does not.
