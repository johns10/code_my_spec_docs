# QA Brief — Story 967: My secrets live encrypted in my own repo

## Tool

web

## Auth

Magic link as the owner (`johns10@gmail.com`).

    vibium cookies clear
    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "johns10@gmail.com"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

## Seeds

`QA Fixture Project` — `11111111-1111-4111-8111-111111111111`.

**Its `local_path` is this checkout** (issue `b400d0d3`), so everything the
secrets step writes lands in the real repo: `.sops.yaml` is a *tracked* file and
`envs/*.enc.env` are untracked. Plan to restore both when you finish.

`sops` and `age` must be installed (`brew install sops age`) or the secrets step
pauses rather than running.

Secrets live in `project_secrets`, keyed `age_private_key_<environment>`. Reading
one needs a scope with **`active_project_id`** set — `active_project` alone is not
enough, `ProjectSecretRepository.fetch/3` matches on the id field.

## What To Test

URL: `http://127.0.0.1:4000/app/projects/<id>/provisioning`

- **A new secret lands in the repo unreadable (7997)** — enter a key/value in
  `[data-test="secret-form"]`, pick an environment, save. The value in
  `envs/<env>.enc.env` must be `ENC[AES256_GCM,...]`, never the plaintext.
- **The repo alone is not enough (7998)** — `sops decrypt envs/<env>.enc.env`
  with no key must fail with "Failed to get the data key".
- **An agent working in the repo sees only ciphertext (8049)** — grep the whole
  tree for the plaintext value you just stored; it must appear nowhere outside
  `.git`.
- **A UAT key will not open production's secrets (8053)** — create a second
  environment, store a secret in each, then cross-decrypt with each private key.
  Each key must open its own file (exit 0) and fail on the other (exit 128).
  Use a non-`prod` name: `prod` maps to the domain apex (issue `ae37f523`).
- **A missing secret refuses the boot by name (8000)** — run the deploy step
  with an environment lacking required values. It must name them:
  "uat is missing SECRET_KEY_BASE, DATABASE_URL".
- **The deploy carries the key, Sam does not (7999)** — the age private key must
  appear neither in the rendered page HTML nor anywhere in the working tree.
- **Rotating a key is a re-encrypt and a redeploy (8001)** — delete the stored
  `age_private_key_<env>` row and the `.enc.env` file, then store a secret. A new
  recipient must be generated *and* written into `.sops.yaml` in the same pass.
- **One set of files serves the laptop and the server (8002)** — the same
  `envs/*.enc.env` are what the deploy ships; there is no second store.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.

## Setup Notes

**Restore both halves of the key pair together, or not at all.** The recipient
lives in tracked `.sops.yaml` and the private key in the database. Reverting one
without the other silently breaks every decrypt, the secrets step keeps reporting
`done`, and the failure surfaces two steps later in deploy (issue `7a6a5d6f` — I
caused exactly this with a stray `git checkout` during unrelated recovery).

Cleanup that leaves no half-pair:

    psql -d code_my_spec_dev -c "delete from project_secrets where project_id='...' and key like 'age_private_key_%';"
    rm -f envs/*.enc.env
    git checkout -- .sops.yaml

**A plaintext file at the `.enc.env` path used to be accepted forever**
(issue `536e9691`, fixed in `64341808`). If you see "sops metadata not found",
check whether the file is genuinely encrypted before assuming a key problem.

**`mix run` is safe against the live dev server; `mix test` is not** — the
TestAdapter recompiles the dev environment and every route then 500s until the
server is restarted.
