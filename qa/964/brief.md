# QA Brief — Story 964: My provider credentials go in once and get checked

## Tool

web

## Auth

Magic link only — the password form no longer exists (issue `6deeee2c`). The user
must already be confirmed or the link 500s (issue `58d4ec98`).

Log in as the **owner**, not the QA fixture user: provider integrations are
user-scoped (`integrations.user_id`), and only `johns10@gmail.com` has GitHub,
Cloudflare and Resend connected. The fixture user has none, so on that account
every credential reads "not connected" and nothing about this story is testable.

    vibium cookies clear
    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "johns10@gmail.com"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

## Seeds

No seed run needed; the projects below already exist. Do not run
`mix run priv/repo/qa_seeds.exs` while the dev server is up — it takes the dev
compile lock and 500s the running server.

- `QA Fixture Project` — `11111111-1111-4111-8111-111111111111`, has real Hetzner
  credentials stored (used as the "populated" side of the isolation check)
- `Todo` — `502cac9f-3809-46f3-8644-89d9769f7a96`, a real project with no Hetzner
  credentials (the "empty" side)

Real credential values come from `envs/.env`. Fill them with output suppressed
(`vibium fill ... >/dev/null 2>&1`) so secrets never reach a transcript.

For anything that needs a disposable project, create one at `/app/projects/new`
and delete it afterwards from `/app/projects` — the Delete button opens a modal by
adding `modal-open` to `#confirm-delete-project-<id>`; click the modal's own
Delete, not the row's.

## What To Test

URL: `http://127.0.0.1:4000/app/projects/<id>/provisioning`

- **One sitting covers every credential (7981)** — `[data-test="provider-credentials"]`
  lists every credential the enabled options need, each with `data-state` and its own
  `[data-test="credential-directions"]`. No second page, no per-provider detour.
- **An option turned off does not ask for its credential (7982)** — untick `storage`,
  `backups`, `content`, `widget`; **reload**; the `hetzner_s3_*` fields must be gone.
  Reloading is required, which is itself the defect in `e881966a` — the panel does not
  re-render on toggle.
- **A credential is proven by a real call (7983)** — paste a syntactically plausible but
  invalid Hetzner token and save. Expect `data-state="rejected"` and a
  `[data-test="credential-rejection"]` naming the permission, not a format complaint.
- **An under-scoped token names the permission it lacks (7984)** — needs a genuinely
  read-only Hetzner token to test properly. An invalid token produces the right shape of
  message ("Missing: Read & Write on Hetzner Cloud") but does not prove the under-scoped
  path.
- **A missing credential stops the run before it starts (7985)** — on a project with no
  Hetzner token, click `[data-test="start-setup"]`. Every step must remain
  `not_started`. Do this on a disposable project, never a real one: if the gate ever
  fails, the click provisions real infrastructure.
- **The console-only key pair is asked for with directions (7986)** — the
  `hetzner_s3_*` fields must carry directions naming the console path, since these keys
  cannot be minted through an API.
- **The repo stays clean of credential values (7987)** — grep the project's `local_path`
  working copy for the actual token values from `envs/.env`.
- **Credentials follow the project (8050)** — values live in `project_secrets` keyed by
  `project_id`, so any agent resolving that project sees them.
- **Another project's credentials are not reachable (8051)** — with credentials stored on
  the fixture project, open Todo's provisioning page: `hetzner_api_token` must read
  `data-stored="false" data-state="missing"`, and the stored value must not appear
  anywhere in the page HTML. GitHub/Cloudflare/Resend reading `stored=true` on both is
  correct — those are user-level OAuth, not project credentials.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.
This directory holds screenshots only.

## Setup Notes

**Clean up after yourself on real projects.** Testing 7983 requires pasting a bad
credential; do it on a project you can restore. If you use a real one, delete the row
afterwards (`delete from project_secrets where project_id = ... and key = ...`) and
re-tick any options you turned off — back the table up to
`~/.codemyspec/db_backups/` first.

**`mix test` wedges the running dev server** — the TestAdapter compiles the dev
environment for static analysis, invalidating `_build/dev/lib/code_my_spec/.mix/compile.lock`,
after which every route 500s with a `CompileError`. Recover with
`kill <varlock pid>; varlock run -- mix compile; nohup varlock run -- mix phx.server &`.
Batch test runs away from browser QA.

**The credential panel goes stale** (`e881966a`). When a reading looks wrong after you
have changed options, reload before concluding anything — I filed a wrong diagnosis
(`e9b6c32a`, since dismissed) by trusting a stale panel across several interactions.
