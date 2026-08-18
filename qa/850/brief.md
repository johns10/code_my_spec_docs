# QA Brief — Story 850: My provider credentials go in once and get checked

## Tool

web

## Auth

Two logins are needed this cycle — one for the ordinary panel checks, one for
the rejection test. The dev mailbox is shared, so confirm the message you open
is addressed to the user you asked for before clicking it.

**Owner (for the panel, and for anything touching the real Code My Spec account):**

1. `http://127.0.0.1:4000/users/log-in`
2. Fill `input[name="user[email]"]` with `johns10@gmail.com`
3. Click **Email me a login link** (the submit button is `form button.btn-secondary`)
4. `http://127.0.0.1:4000/dev/mailbox` — open the message addressed to that user
5. The link is issued for `dev.codemyspec.com`; swap the host to `127.0.0.1:4000`

**QA user (for the rejection test — see Setup Notes for why it must be a
different account):** same flow with `qa@codemyspec.local`. Its accounts are
`QA Team 605`, `QA Second Account` and `QA Team 605 Scope Test`, none of which
hold a real Hetzner token.

If the email field renders `readonly`, a session is already open — log out via
the `a[href="/users/log-out"]` link (it is `data-method="delete"`, so navigating
to the URL does nothing) and start again.

Switch accounts at `/app/accounts/picker`; the entries are
`a[phx-value-account-id=...]`.

## Seeds

No story-specific seeding.

- QA Fixture Project: `11111111-1111-4111-8111-111111111111`, in the
  `Code My Spec` account (`0f27281c-240b-4d6d-8e52-9c5972329522`)
- Provisioning page:
  `http://127.0.0.1:4000/app/projects/<project_id>/provisioning`
- For the rejection test, create a throwaway project under a QA account via
  `/app` → **Create project**

## What To Test

- **One sitting covers every credential the run will need (7981).** One
  `[data-test="provider-credentials"]` panel listing every credential the
  enabled options need, each with `data-credential`, `data-credential-kind`,
  `data-stored` and `data-state`. No second page, no per-provider detour.
- **An option turned off does not ask for its credential (7982).** Untick
  storage: the `hetzner_s3_*` fields should stay, because backups and content
  also consume object storage. Untick the last consumer and they should
  disappear **without a reload**. Re-tick and they return.
- **A credential is proven by a real call, not by looking right (7983).** On a
  throwaway project under a QA account, paste a syntactically plausible but
  invalid Hetzner API token and save. Expect `data-state="rejected"` naming the
  permission, not `verified`. This is the criterion that failed last cycle
  (`bcd2b2b4`) — read Setup Notes before running it.
- **An under-scoped token names the permission it lacks (7984).** Accepted as
  structurally verified on the owner's decision of 2026-08-17. Proving it needs
  a genuinely read-only Hetzner token, which only the owner can mint. Do not
  mint one; record it as structural.
- **A missing credential stops the run before it starts (7985).** On a project
  missing credentials, the gate should name what is still needed, and clicking
  `[data-test="start-setup"]` should start nothing — verify server-side by
  confirming no step enters `running` and the done count is unchanged, not just
  by reading the page.
- **The console-only key pair is asked for with directions (7986).** The
  `hetzner_s3_*` fields should carry the console path in their own text, and the
  API token field should name the read-only trap.
- **The repo stays clean of credential values (7987).** Grep the working copy
  for the literal values from `envs/.env`, excluding `.git`, `_build`, `deps`
  and `node_modules`. Print filenames only — never the values.
- **Credentials follow the project, wherever the agent runs (8050).** Call
  `devops_status` through the local MCP endpoint scoped to two different harness
  ids that resolve the same project, and compare the responses.
- **Another project's credentials are not reachable (8051).** Must be tested
  **cross-account** — see Setup Notes.

## Setup Notes

**The Hetzner API token is account-grain now, and that changes two tests.**
`Credentials` marks `hetzner_api_token` as `grain: :account`; the S3 pair stays
project-grain because `Storage.credentials/2` reads it there.

- **7983 needs a disposable *account*, not just a disposable project.** Pasting a
  bad token under `Code My Spec` would overwrite the owner's real Hetzner token
  for every project in that account. Use a QA account, which holds none.
- **8051 means cross-account.** An account-grain credential is reachable from
  every project in its account by design — that is what account grain means. The
  isolation claim is that another *account* cannot reach it. Confirmed with the
  owner on 2026-08-17.

**What changed since the failing attempt.**

- `bcd2b2b4` is resolved. The check resolved the account credential while the
  field being typed into was the project one, so a garbage value read as
  `verified` — the value under test was never sent anywhere. The catalogue is
  grain-aware now and a migration lifted the stray project-grain rows.
- `b1d87f01` is partly addressed. The two cassettes carrying live S3 keys are
  gone with the whole cassette directory, and the working copy is verified clean.
  The values remain in git history at `5a85216b` and `0cc186d0`, so the key pair
  should still be treated as exposed until rotated — console-only, owner's
  action. Report 7987 on the working-copy standard both prior attempts used, and
  state the history exposure explicitly rather than letting a pass imply it is
  gone.
- `85e91bf8` stays open only for whether the refusal flash reaches someone who
  presses the header button. Do **not** disable `[data-test="start-setup"]` — the
  964/7985 spex clicks it to prove the refusal is enforced server-side, and
  disabling it breaks that proof.

## Result Path

`.code_my_spec/qa/850/result.md`
